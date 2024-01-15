import express from 'express';
import { getAvailableMessagesCount, sendMessageBatchToSQS, sendMessageToSQS } from './sqs-service';


const app = express();

// Middleware to parse json
app.use(express.json());

// Routes
app.post('/message', async (req: express.Request, res: express.Response) => {
  const message = req.body.message
  const responseFromSQS = await sendMessageToSQS(message)
  console.log(responseFromSQS)
  res.status(200).send('Message received!');
});

app.post('/message-batch', async (req: express.Request, res: express.Response) => {
  const messages = req.body.messages
  const responseFromSQS = await sendMessageBatchToSQS(messages)
  console.log(responseFromSQS)
  res.status(200).send('Messages received!');
})

app.get('/health', (req, res) => res.status(200).send('OK'))

app.get('/total-messages', async (req: express.Request, res: express.Response) => {
  const totalMessages = await getAvailableMessagesCount()
  res.status(200).send(`Total messages available: ${totalMessages}`);
})

app.listen(80, () => {
  console.log('Server listening on port 80');
});

