import { DynamoDBClient, BatchGetItemCommand } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  PutCommand,
  GetCommand,
  DeleteCommand,
  BatchWriteCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

const dynamo = DynamoDBDocumentClient.from(client);

const tableName = "http-crud-items";

export function* chunkArray(arr, stride = 1) {
  for (let i = 0; i < arr.length; i += stride) {
    yield arr.slice(i, Math.min(i + stride, arr.length));
  }
};

export const handler = async (event, context) => {
  let body;
  let statusCode = 200;
  const headers = {
    "Content-Type": "application/json",
  };
  console.log(JSON.stringify(event));
  try {
    switch (event.routeKey) {
      case "DELETE /items/{id}":
        await dynamo.send(
          new DeleteCommand({
            TableName: tableName,
            Key: {
              id: event.pathParameters.id,
            },
          })
        );
        body = `Deleted item ${event.pathParameters.id}`;
        break;
      case "GET /items/{id}":
        body = await dynamo.send(
          new GetCommand({
            TableName: tableName,
            Key: {
              id: event.pathParameters.id,
            },
          })
        );
        body = body.Item;
        break;
      case "GET /items":
        body = await dynamo.send(
          new ScanCommand({ TableName: tableName })
        );
        body = body.Items;
        break;
      case "GET /bulkitems":
        let getInput = JSON.parse(event.body);
        const input = getInput ;
        const command = new BatchGetItemCommand(input);
        const response = await client.send(command);
        body = response ;
        break;
      case "POST /bulkitems":
        let lambdaInput = JSON.parse(event.body);
        const bulkitems = lambdaInput['list'] ;  
        const itemChunks = chunkArray(bulkitems, 25);
        for (const chunk of itemChunks) {
          const putRequests = chunk.map((bulkitem) => ({
            PutRequest: {
              Item: bulkitem,
            },
          }));
          const command = new BatchWriteCommand({
            RequestItems: {
              [tableName]: putRequests,
            },
          });
          console.log(JSON.stringify(command));
          await dynamo.send(command);
          console.log("Uploaded a batch of items");
        }
        body = `Put bulk items`;
        break;
      case "PUT /items":
        let requestJSON = JSON.parse(event.body);
        await dynamo.send(
          new PutCommand({
            TableName: tableName,
            Item: {
              id: requestJSON.id,
              price: requestJSON.price,
              name: requestJSON.name,
            },
          })
        );
        body = `Put item ${requestJSON.id}`;
        break;
      default:
        throw new Error(`Unsupported route: "${event.routeKey}"`);
    }
  } catch (err) {
    statusCode = 400;
    body = err.message;
  } finally {
    body = JSON.stringify(body);
  }
  
  console.log("STATUS CODE" + JSON.stringify(statusCode, null,2));
  console.log("BODY" + JSON.stringify(body, null,2));
  console.log("HEADERS" + JSON.stringify(headers, null,2));
  return {
    statusCode,
    body,
    headers,
  };
};

