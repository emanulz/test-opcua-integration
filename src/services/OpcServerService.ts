/**
 * @file OpcServerService.ts
 * @description Service for interacting with an OPC server. Keeps the reconnect logic.
 */

import {
  AttributeIds,
  ClientMonitoredItem,
  ClientSession,
  ClientSubscription,
  DataValue,
  OPCUAClient,
  StatusCode,
  StatusCodes,
  TimestampsToReturn,
} from 'node-opcua';
import { envConfig } from '../configs/envConfig';
import { IOpcServerService } from '../interfaces/IOpcServerService';

export class OpcServerService implements IOpcServerService {
  private client = OPCUAClient.create({ endpoint_must_exist: false });
  private session: ClientSession | null = null;
  private subscription: ClientSubscription | null = null;
  private reconnectDelay = 5000;
  private isConnected = false;
  private currentStateCallback: ((newState: string) => void) | null = null;

  /**
   * Check if the OPC server is currently connected
   */
  isOpcServerConnected(): boolean {
    return this.isConnected;
  }

  async connect(): Promise<void> {
    try {
      console.log('Connecting to OPC server at', envConfig.OPC_ENDPOINT);
      await this.client.connect(envConfig.OPC_ENDPOINT);
      this.session = await this.client.createSession();
      console.log('OPC UA session created');
      this.isConnected = true;

      // Setup session error handling
      this.setupSessionErrorHandling();

      // If we already have a callback for the state node, initialize subscription
      if (this.currentStateCallback) {
        await this.initializeSubscription(this.currentStateCallback);
      }
    } catch (error) {
      console.error('Error connecting to OPC UA server:', error);
      this.isConnected = false;
      setTimeout(() => this.reconnect(), this.reconnectDelay);
    }
  }

  subscribeToStateChanges(callback: (newState: string) => void): void {
    this.currentStateCallback = callback;
    if (!this.isConnected) {
      console.warn('OPC server not connected yet; subscription will be initialized after connection.');
      return;
    }
    this.initializeSubscription(callback).catch((err) => {
      console.error('Error initializing state subscription:', err);
    });
  }

  async readValue(nodeId: string): Promise<string | number | null> {
    if (!this.session) {
      throw new Error('OPC UA session not established.');
    }
    try {
      const dataValue = await this.session.read({
        nodeId,
        attributeId: AttributeIds.Value,
      });
      return dataValue.value?.value ?? null;
    } catch (error) {
      console.error(`Failed to read node ${nodeId}:`, error);
      throw error;
    }
  }

  async writeValue(nodeId: string, value: unknown): Promise<void> {
    if (!this.session) {
      throw new Error('OPC UA session not established.');
    }

    // Handle array values
    if (Array.isArray(value)) {
      const writeResult: StatusCode = await this.session.write({
        nodeId,
        attributeId: AttributeIds.Value,
        value: { value: { dataType: 'String', arrayType: 'Array', value } },
      });

      if (writeResult.equals(StatusCodes.Good)) {
        console.log(`Wrote array to node ${nodeId} successfully.`);
      } else {
        console.error(`Failed to write array to node ${nodeId}:`, writeResult.toString());
      }
      return;
    }

    // Handle single values
    const writeResult: StatusCode = await this.session.write({
      nodeId,
      attributeId: AttributeIds.Value,
      value: { value: { dataType: 'String', value: String(value) } },
    });

    if (writeResult.equals(StatusCodes.Good)) {
      console.log(`Wrote "${value}" to node ${nodeId} successfully.`);
    } else {
      console.error(`Failed to write "${value}" to node ${nodeId}:`, writeResult.toString());
    }
  }

  // -----------------------
  // Private Methods
  // -----------------------

  private async initializeSubscription(callback: (state: string) => void): Promise<void> {
    if (!this.session) {
      throw new Error('OPC UA session is not established.');
    }

    // If a subscription exists, terminate it first
    if (this.subscription) {
      await this.subscription.terminate();
      this.subscription = null;
    }

    // Create subscription
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

    this.subscription.on('terminated', () => {
      console.error('OPC UA subscription terminated. Attempting to reconnect...');
      this.handleConnectionLoss();
    });

    // Monitor the "state" node for changes
    const monitoredItem: ClientMonitoredItem = await this.subscription.monitor(
      {
        nodeId: envConfig.STATE_NODE_ID,
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
      const newState = dataValue.value.value;
      console.log('OPC UA state changed:', newState);
      callback(String(newState));
    });
  }

  private setupSessionErrorHandling(): void {
    if (!this.session) return;
    this.session.on('session_closed', (statusCode: any) => {
      console.error('OPC UA session closed:', statusCode.toString());
      this.handleConnectionLoss();
    });
  }

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

  private async reconnect(): Promise<void> {
    console.log(`Attempting to reconnect to OPC UA server at ${envConfig.OPC_ENDPOINT}...`);
    try {
      await this.connect();
      if (this.currentStateCallback) {
        await this.initializeSubscription(this.currentStateCallback);
      }
      console.log('✅ OPC UA server reconnected successfully! State monitoring is active.');
    } catch (error) {
      console.error(`❌ Reconnection attempt failed. Will retry in ${this.reconnectDelay / 1000} seconds...`);
      setTimeout(() => this.reconnect(), this.reconnectDelay);
    }
  }
}
