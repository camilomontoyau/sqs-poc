export const config = {
  SQS_ARN: process.env.SQS_ARN || '',
  SQS_MESSAGE_NUMBER: process.env.SQS_MESSAGE_NUMBER || 10,
  SQS_WAIT_TIME: process.env.SQS_WAIT_TIME || 5, // seconds
}