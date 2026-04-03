const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const apiRoutes = require('./routes/api');
const ingestData = require('./ingestOnStartup');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get('/test', (req, res) => res.send('Test Route works!'));
app.use('/api', apiRoutes);

async function startServer() {
  try {
    let MONGO_URI = process.env.MONGO_URI;
    
    if (!MONGO_URI) {
      console.log('No MONGO_URI provided in .env. Starting MongoDB in-memory server...');
      const { MongoMemoryServer } = require('mongodb-memory-server');
      const mongod = await MongoMemoryServer.create();
      MONGO_URI = mongod.getUri();
      console.log(`In-memory MongoDB started at: ${MONGO_URI}`);
    }

    await mongoose.connect(MONGO_URI);
    console.log('Connected to MongoDB');

    // Start Ingestion
    await ingestData();

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (err) {
    console.error('Server startup error:', err);
  }
}

startServer();

