/**
 * @file testServer.ts
 * @description A basic OPC UA server for local testing.
 *
 * To run:
 *   1. yarn install (or npm install)
 *   2. yarn build (or npm run build)
 *   3. yarn start (or npm start)
 */

import { DataType, OPCUAServer, StatusCodes, Variant } from 'node-opcua';

async function main() {
  // Create an OPC UA server instance
  const server = new OPCUAServer({
    port: 4840, // default OPC UA port
    resourcePath: '/UA/TestServer', // optional path segment
    buildInfo: {
      productName: 'LocalTestOPCUAServer',
      buildNumber: '1',
      buildDate: new Date(),
    },
  });

  // 1. Initialize the server
  await server.initialize();
  console.log('OPC UA Server initialized');

  const addressSpace = server.engine.addressSpace;
  if (!addressSpace) {
    throw new Error('Address space is not initialized!');
  }

  // 2. Create a namespace for our custom nodes
  const namespace = addressSpace.getOwnNamespace();
  const nsIndex = namespace.index;

  const folder = namespace.addFolder(addressSpace.rootFolder.objects, { browseName: 'MyTestNodes' });

  /**
   * For simplicity, we’ll store node values in memory. Typically, we use "get/set" callbacks,
   * but here we’ll just manage them via "bindVariable" to track reads/writes.
   */
  let stateValue = 'IDLE'; // e.g. "START", "DONE", etc.
  let itemIdValue = ''; // default item ID
  let resultValue = ''; // value for the result node

  // 3. Add the State node
  namespace.addVariable({
    componentOf: folder,
    browseName: 'StateMachineNode',
    nodeId: `ns=${nsIndex};s=StateMachineNode`,
    dataType: 'String',
    minimumSamplingInterval: 1000,
    value: {
      get: () => {
        console.log(`>>> [READ] StateNode = "${stateValue}"`);
        return new Variant({ dataType: DataType.String, value: stateValue });
      },
      set: (variant: any) => {
        stateValue = variant.value;
        console.log(`>>> [WRITE] StateNode set to "${stateValue}"`);
        return StatusCodes.Good;
      },
    },
    // (Optional) you can add minimumSamplingInterval if the warning bugs you:
    // minimumSamplingInterval: 1000,
  });

  // 4. Add the ItemID node
  namespace.addVariable({
    componentOf: folder,
    browseName: 'ItemIdNode',
    nodeId: `ns=${nsIndex};s=ItemIdNode`,
    dataType: 'String',
    minimumSamplingInterval: 1000,
    value: {
      get: () => {
        console.log(`>>> [READ] ItemIdNode = "${itemIdValue}"`);
        return new Variant({ dataType: DataType.String, value: itemIdValue });
      },
      set: (variant: any) => {
        itemIdValue = variant.value;
        console.log(`>>> [WRITE] ItemIdNode set to "${itemIdValue}"`);
        return StatusCodes.Good;
      },
    },
  });

  // 5. Add the Result node
  namespace.addVariable({
    componentOf: folder,
    browseName: 'ResultNode',
    nodeId: `ns=${nsIndex};s=ResultNode`,
    dataType: 'String',
    minimumSamplingInterval: 1000,
    value: {
      get: () => {
        console.log(`>>> [READ] ResultNode = "${resultValue}"`);
        return new Variant({ dataType: DataType.String, value: resultValue });
      },
      set: (variant: any) => {
        resultValue = variant.value;
        console.log(`>>> [WRITE] ResultNode set to "${resultValue}"`);
        return StatusCodes.Good;
      },
    },
  });

  console.log('NODES CREATED:');
  console.log(`StateMachineNode: ns=${nsIndex};s=StateMachineNode`);
  console.log(`ItemIdNode: ns=${nsIndex};s=ItemIdNode`);
  console.log(`ResultNode: ns=${nsIndex};s=ResultNode`);

  // 6. Start the server
  await server.start();
  console.log(`OPC UA Server is now listening on port ${server.endpoints[0].port}`);
  console.log(`Endpoint URL: ${server.getEndpointUrl()}`);

  console.log(`
  To manually write to some node use a helper script, for example:
    yarn ts-node scripts/opcWrite.ts "ns=1;s=StateMachineNode" "DONE"
  `);
}

main().catch((err) => {
  console.error('Error starting OPC UA test server:', err);
});
