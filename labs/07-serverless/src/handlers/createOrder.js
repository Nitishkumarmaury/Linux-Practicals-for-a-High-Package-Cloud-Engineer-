const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const sqs = new AWS.SQS();

module.exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const userId = event.requestContext.authorizer.claims.sub;
    
    const order = {
      orderId: generateOrderId(),
      userId: userId,
      items: body.items,
      totalAmount: calculateTotal(body.items),
      status: 'PENDING',
      createdAt: new Date().toISOString()
    };

    // Save to DynamoDB
    await dynamodb.put({
      TableName: process.env.ORDER_TABLE,
      Item: order
    }).promise();

    // Send to SQS for processing
    await sqs.sendMessage({
      QueueUrl: process.env.QUEUE_URL,
      MessageBody: JSON.stringify(order),
      MessageAttributes: {
        OrderId: {
          DataType: 'String',
          StringValue: order.orderId
        }
      }
    }).promise();

    return {
      statusCode: 201,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        message: 'Order created successfully',
        orderId: order.orderId
      })
    };
  } catch (error) {
    console.error('Error creating order:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        message: 'Error creating order',
        error: error.message
      })
    };
  }
};

function generateOrderId() {
  return `ord_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

function calculateTotal(items) {
  return items.reduce((total, item) => total + (item.price * item.quantity), 0);
}