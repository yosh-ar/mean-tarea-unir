const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const tareasRouter = require('./routes/tareas');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/tareas';
const PORT = 3000;

const ESTADOS_MONGO = ['desconectado', 'conectado', 'conectando', 'desconectando'];

mongoose.connect(MONGO_URI).catch((err) => {
  console.error('Error al conectar a MongoDB:', err.message);
});

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/tareas', tareasRouter);

app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    mongo: ESTADOS_MONGO[mongoose.connection.readyState] || 'desconocido'
  });
});

app.listen(PORT, () => {
  console.log(`API escuchando en el puerto ${PORT}`);
});
