/**
 * @file GenericOpcuaAdapter.ts
 * @module adapters/plc/GenericOpcuaAdapter
 */

import 'dotenv/config';
import {
  AttributeIds,
  ClientMonitoredItem,
  ClientSubscription,
  DataValue,
  OPCUAClient,
  StatusCodes,
  TimestampsToReturn,
} from 'node-opcua';
import { IPlcPort } from '../../ports/IPlcPort';

/**
 * Read configuration from environment variables.
 * Make sure to have a .env file with the following variables:
 * - OPCUA_ENDPOINT
 * - OPCUA_EVENT_NODE_ID
 * - OPCUA_RESPONSE_NODE_ID
 */
const OPCUA_ENDPOINT = process.env.OPCUA_ENDPOINT;
const EVENT_NODE_ID = process.env.OPCUA_EVENT_NODE_ID;
const RESPONSE_NODE_ID = process.env.OPCUA_RESPONSE_NODE_ID;

/**
 * GenericOpcuaAdapter implements the IPlcPort interface using the node-opcua library.
 *
 * @remarks
 * This adapter connects to a generic OPC UA server, subscribes to changes on a specified tag,
 * and writes responses back.
 */
export class GenericOpcuaAdapter implements IPlcPort {
  private client = OPCUAClient.create({ endpoint_must_exist: false });
  private session: any = null;
  private subscription: ClientSubscription | null = null;
  private reconnectDelay = 5000; // Delay (in milliseconds) before a reconnection attempt.
  private isConnected = false;
  private currentCallback: ((barcode: string) => void) | null = null;

  /**
   * Connects to the OPC UA server and creates a session.
   *
   * @returns A promise that resolves when the connection is established.
   */
  async connect(): Promise<void> {
    if (!OPCUA_ENDPOINT) {
      throw new Error('OPCUA_ENDPOINT environment variable is not set.');
    }

    try {
      console.log('Connecting to OPC UA Server...');
      await this.client.connect(OPCUA_ENDPOINT);
      this.session = await this.client.createSession();
      console.log('OPC UA session created');
      this.isConnected = true;

      // Setup session error handling.
      this.setupSessionErrorHandling();

      // Initialize subscription if a callback has already been provided.
      if (this.currentCallback) {
        await this.initializeSubscription(this.currentCallback);
      }
    } catch (error) {
      console.error('Error connecting to OPC UA Server:', error);
      this.isConnected = false;
      setTimeout(() => this.reconnect(), this.reconnectDelay);
    }
  }

  /**
   * Subscribes to changes on the OPC UA tag.
   *
   * @param callback - A function that is called with the barcode string when a change is detected.
   */
  subscribe(callback: (barcode: string) => void): void {
    this.currentCallback = callback;
    if (!this.isConnected) {
      console.warn('OPC UA server not connected yet; subscription will be initialized after connection.');
      return;
    }
    this.initializeSubscription(callback).catch((err) => {
      console.error('Error initializing subscription:', err);
    });
  }

  /**
   * Writes the API response back to the OPC UA server.
   *
   * @param response - The response value from the external API.
   * @returns A promise that resolves when the write operation is complete.
   */
  async writeResponse(response: number): Promise<void> {
    if (!this.session) {
      throw new Error('OPC UA session is not established.');
    }
    const writeResult = await this.session.write({
      nodeId: RESPONSE_NODE_ID,
      attributeId: AttributeIds.Value,
      value: { value: { dataType: 'Double', value: response } },
    });

    if (writeResult.statusCode && writeResult.statusCode.equals(StatusCodes.Good)) {
      console.log('Successfully wrote response back to OPC UA server.');
    } else {
      console.error('Failed to write response to OPC UA server:', writeResult.statusCode.toString());
    }
  }

  /**
   * Initializes the OPC UA subscription.
   *
   * @param callback - A function that is called when a change is detected.
   * @returns A promise that resolves when the subscription is created.
   */
  private async initializeSubscription(callback: (barcode: string) => void): Promise<void> {
    this.currentCallback = callback;
    if (!this.session) {
      throw new Error('OPC UA session is not established.');
    }

    // Terminate any existing subscription before creating a new one.
    if (this.subscription) {
      await this.subscription.terminate();
      this.subscription = null;
    }

    // Create a new subscription.
    this.subscription = ClientSubscription.create(this.session, {
      requestedPublishingInterval: 500,
      requestedLifetimeCount: 100,
      requestedMaxKeepAliveCount: 10,
      maxNotificationsPerPublish: 10,
      publishingEnabled: true,
      priority: 10,
    });

    this.subscription.on('started', () => {
      console.log('OPC UA subscription started - ID:', this.subscription?.subscriptionId);
    });

    this.subscription.on('keepalive', () => {
      console.log('OPC UA subscription keepalive');
    });

    // Handle subscription termination (e.g., due to connection loss).
    this.subscription.on('terminated', () => {
      console.error('OPC UA subscription terminated. Attempting to reconnect...');
      this.handleConnectionLoss();
    });

    const monitoredItem: ClientMonitoredItem = await this.subscription.monitor(
      {
        nodeId: EVENT_NODE_ID,
        attributeId: AttributeIds.Value,
      },
      {
        samplingInterval: 100,
        discardOldest: true,
        queueSize: 10,
      },
      TimestampsToReturn.Both
    );

    monitoredItem.on('changed', (dataValue: DataValue) => {
      console.log('OPC SERVER CHANGED VALUE--->:', dataValue);
      console.log('IRRR A TOMAR!!');
      const barcode = dataValue.value.value;
      console.log('OPC UA event detected:', barcode);
      if (barcode && this.currentCallback) {
        this.currentCallback(String(barcode));
      }
    });
  }

  /**
   * Sets up error handling for the OPC UA session.
   */
  private setupSessionErrorHandling(): void {
    if (!this.session) return;
    this.session.on('session_closed', (statusCode: any) => {
      console.error('OPC UA session closed with status code:', statusCode.toString());
      this.handleConnectionLoss();
    });
  }

  /**
   * Handles connection loss by cleaning up the session and subscription,
   * then attempting to reconnect.
   */
  private handleConnectionLoss(): void {
    this.isConnected = false;
    if (this.subscription) {
      this.subscription.removeAllListeners();
      this.subscription = null;
    }
    if (this.session) {
      try {
        this.session.close();
      } catch (error) {
        console.error('Error closing session:', error);
      }
      this.session = null;
    }
    this.client.disconnect().catch((err) => {
      console.error('Error during client disconnect:', err);
    });
    setTimeout(() => this.reconnect(), this.reconnectDelay);
  }

  /**
   * Attempts to reconnect to the OPC UA server and reinitialize the subscription.
   */
  private async reconnect(): Promise<void> {
    console.log('Attempting to reconnect to OPC UA Server...');
    try {
      await this.connect();
      if (this.currentCallback) {
        await this.initializeSubscription(this.currentCallback);
      }
      console.log('Reconnected successfully!');
    } catch (error) {
      console.error('Reconnection attempt failed:', error);
      setTimeout(() => this.reconnect(), this.reconnectDelay);
    }
  }
}
