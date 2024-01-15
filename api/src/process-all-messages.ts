import { SQSClient, SendMessageCommand, ReceiveMessageCommand, GetQueueAttributesCommand, DeleteMessageCommand } from "@aws-sdk/client-sqs"
import { config } from './config'

const sqsClient = new SQSClient({ region: config.AWS_SQS_REGION })

const queueUrl: string = config.SQS_URL

const batchSize = 100

const getQueueAttributesCommand = new GetQueueAttributesCommand({
  QueueUrl: queueUrl,
  AttributeNames: ["ApproximateNumberOfMessages"],
})

const receiveMessageCommand = new ReceiveMessageCommand({
  QueueUrl: queueUrl,
  MaxNumberOfMessages: batchSize,
});


async function processAllMessages() {
  const { Attributes } = await sqsClient.send(getQueueAttributesCommand)
  const totalAvailableMessages = parseInt(Attributes?.ApproximateNumberOfMessages ?? '0')

  if (!totalAvailableMessages) {
    console.log("No messages to process")
    return
  }

  console.log(`Total available messages: ${totalAvailableMessages}`)
  while (totalAvailableMessages > 0) {
    const { Messages } = await sqsClient.send(receiveMessageCommand);
    if (Messages && Messages.length > 0) {
      for (const message of Messages) {
        console.log(`Message: ${message.Body}`);

        const deleteMessageCommand = new DeleteMessageCommand({
          QueueUrl: queueUrl,
          ReceiptHandle: message.ReceiptHandle,
        });

        await sqsClient.send(deleteMessageCommand);
      }
    }
  }
  
}

processAllMessages()
