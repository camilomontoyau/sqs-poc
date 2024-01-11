import { readMessagesFromSQS } from "./sqs-service"


const processMessages = async () => {
  const messages = await readMessagesFromSQS()
  console.log(messages)
}

processMessages()

export default {}