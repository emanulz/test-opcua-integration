/**
 * @file opcWrite.ts
 * @description Example: writes a value to an OPC UA node specified via command-line arguments.
 *
 * Usage:
 *   yarn ts-node opcWrite.ts "ns=2;s=StateMachineNode" "DONE"
 * or (after building)
 *   node dist/opcWrite.js "ns=2;s=StateMachineNode" "DONE"
 */

import { OPCUAClient, AttributeIds, DataType, WriteValueOptions, StatusCodes } from 'node-opcua';

const ENDPOINT_URL = 'opc.tcp://localhost:4840/UA/TestServer';

// Grab nodeId & newValue from CLI arguments
const nodeId = process.argv[2] || 'ns=2;s=StateMachineNode';
const newValue = process.argv[3] || 'START';

async function main(): Promise<void> {
  const client = OPCUAClient.create({ endpoint_must_exist: false });
  try {
    console.log(`Connecting to ${ENDPOINT_URL}...`);
    await client.connect(ENDPOINT_URL);
    console.log('Connected!');

    // Create a session
    const session = await client.createSession();
    console.log('Session created.');

    // Prepare the write
    const nodeToWrite: WriteValueOptions = {
      nodeId,
      attributeId: AttributeIds.Value,
      value: {
        value: {
          dataType: DataType.String,
          value: newValue,
        },
      },
    };

    console.log(`Writing "${newValue}" to node "${nodeId}"...`);
    const writeResults = await session.write(nodeToWrite);

    if (writeResults.isGood()) {
      console.log(`Write operation succeeded! (${writeResults.toString()})`);
    } else {
      console.error(`Write operation failed: ${writeResults.toString()}`);
    }

    // (Optional) Read back the node to confirm
    const dataValue = await session.read({
      nodeId,
      attributeId: AttributeIds.Value,
    });
    console.log(`Read back node "${nodeId}" value:`, dataValue.value.value);

    // Clean up
    await session.close();
    await client.disconnect();
    console.log('Disconnected.');
  } catch (err) {
    console.error('Error:', err);
  }
}

main();
