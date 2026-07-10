const { Schema, model } = require('mongoose');

const tareaSchema = new Schema({
  titulo: { type: String, required: true },
  completada: { type: Boolean, default: false }
});

module.exports = model('Tarea', tareaSchema);
