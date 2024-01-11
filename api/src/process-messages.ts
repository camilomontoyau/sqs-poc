import { readMessagesFromSQS, getAvailableMessagesCount } from "./sqs-service"


const processMessages = async () => {
  const availableMessagesCount = await getAvailableMessagesCount()
  console.log(`There are ${availableMessagesCount} messages available to process`)
  if (!availableMessagesCount) {
    return
  }
  const messages = await readMessagesFromSQS()
  console.log(messages)
}

processMessages()

export default {}