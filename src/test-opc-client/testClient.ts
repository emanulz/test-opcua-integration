/**
 * @file testClient.ts
 * @module testClient
 *
 * @remarks
 * This is a simple OPC UA client using node-opcua to connect to the OPC UA server,
 * browse the address space, and print out some basic information.
 */

import { OPCUAClient } from 'node-opcua';

async function main(): Promise<void> {
  // Update the endpoint if necessary
  const endpointUrl = 'opc.tcp://opcuaserver.com:48010';
  const client = OPCUAClient.create({ endpoint_must_exist: false });
  try {
    console.log('Connecting to OPC UA Server at', endpointUrl);
    await client.connect(endpointUrl);
    console.log('Connected!');

    // Create a session to browse the server.
    const session = await client.createSession();
    console.log('Session created.');

    // Browse the root folder ("Objects" folder)
    const browseResult = await session.browse('ObjectsFolder');
    console.log('Browsing ObjectsFolder:');
    browseResult.references?.forEach((ref) => {
      console.log(
        `\t${ref.browseName.toString()} (NodeId: ${ref.nodeId.toString()})`
      );
    });

    // Clean up
    await session.close();
    await client.disconnect();
    console.log('Disconnected.');
  } catch (err) {
    console.error('Error:', err);
  }
}

main();
