import express from 'express';
import { sendMessageToSQS } from './sqs-service';


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

app.get('/health', (req, res) => res.status(200).send('OK'))

app.listen(80, () => {
  console.log('Server listening on port 80');
});

