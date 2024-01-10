import express from 'express';


const app = express();

// Middleware to parse json
app.use(express.json());

// Routes



// Routes
app.post('/message', (req: express.Request, res: express.Response) => {
  res.status(200).send('Message received!');
});

app.get('/health', (req, res) => res.status(200).send('OK'))

app.listen(80, () => {
  console.log('Server listening on port 80');
});

