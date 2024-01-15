import { SQSClient, SendMessageCommand, ReceiveMessageCommand, GetQueueAttributesCommand, SendMessageBatchCommand } from "@aws-sdk/client-sqs"
import { config } from './config'


const sqs = new SQSClient({ region: config.AWS_SQS_REGION })

export async function sendMessageToSQS(
  message: string
): Promise<void> {
  const params = {
    MessageBody: JSON.stringify(message),
    QueueUrl: config.SQS_URL
  }

  const command = new SendMessageCommand(params)

  try {
    await sqs.send(command);
    console.log('Message sent successfully')
  } catch (error) {
    console.error('Error sending message:', error)
    throw error
  }
}

export async function readMessagesFromSQS(): Promise<string[]> {
  const params = {
    QueueUrl: config.SQS_URL,
    MaxNumberOfMessages: config.SQS_MESSAGE_NUMBER as number,
    WaitTimeSeconds: config.SQS_WAIT_TIME as number
  }

  try {
    const command = new ReceiveMessageCommand(params)
    const response = await sqs.send(command)
    const messages = response.Messages || []
    const messageBodies = messages.map((message) => message.Body || '')
    return messageBodies
  } catch (error) {
    console.error('Error reading messages:', error)
    throw error
  }
}

export async function getAvailableMessagesCount(): Promise<number> {
  const params = {
    QueueUrl: config.SQS_URL,
    AttributeNames: ['ApproximateNumberOfMessages' as const]
  }

  try {
    const command = new GetQueueAttributesCommand(params)
    const response = await sqs.send(command)
    const attributes = response.Attributes || {}
    const numberOfMessages = parseInt(attributes.ApproximateNumberOfMessages || '0')
    return numberOfMessages
  } catch (error) {
    console.error('Error getting available messages count:', error)
    throw error
  }
}

export async function sendMessageBatchToSQS(
  messages: string[]
): Promise<void> {
  const entries = messages.map((message, index) => {
    return {
      Id: `${index}`,
      MessageBody: JSON.stringify(message)
    }
  })

  const params = {
    Entries: entries,
    QueueUrl: config.SQS_URL
  }

  try {
    const command = new SendMessageBatchCommand(params)
    await sqs.send(command)
    console.log('Messages sent successfully')
  } catch (error) {
    console.error('Error sending messages:', error)
    throw error
  }
}
