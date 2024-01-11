export const config = {
  SQS_URL: process.env.SQS_URL || '',
  SQS_MESSAGE_NUMBER: process.env.SQS_MESSAGE_NUMBER || 10,
  SQS_WAIT_TIME: process.env.SQS_WAIT_TIME || 5, // seconds
  AWS_SQS_REGION: process.env.AWS_SQS_REGION,
}