import { SQSClient, ReceiveMessageCommand, GetQueueAttributesCommand, DeleteMessageCommand } from "@aws-sdk/client-sqs"
import { config } from './config'

const sqsClient = new SQSClient({ region: config.AWS_SQS_REGION })

const queueUrl: string = config.SQS_URL

const getQueueAttributesCommand = new GetQueueAttributesCommand({
  QueueUrl: queueUrl,
  AttributeNames: ["ApproximateNumberOfMessages"],
})

const receiveMessageCommand = new ReceiveMessageCommand({
  QueueUrl: queueUrl,
  MaxNumberOfMessages: config.SQS_MESSAGE_NUMBER as number,
});

const countMessages = async () => {
  const { Attributes } = await sqsClient.send(getQueueAttributesCommand)
  const totalAvailableMessages = parseInt(Attributes?.ApproximateNumberOfMessages ?? '0')
  return totalAvailableMessages
}


async function processAllMessages() {
  let totalAvailableMessages = await countMessages()

  console.log(`Total available messages: ${totalAvailableMessages}`)

  if (!totalAvailableMessages) {
    console.log("No messages to process")
    return
  }

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
    totalAvailableMessages = await countMessages()
  }
  
}

processAllMessages()
