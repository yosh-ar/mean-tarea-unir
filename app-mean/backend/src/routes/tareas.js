const { Router } = require('express');
const Tarea = require('../models/Tarea');

const router = Router();

router.get('/', async (req, res) => {
  const tareas = await Tarea.find();
  res.json(tareas);
});

router.post('/', async (req, res) => {
  const tarea = await Tarea.create({
    titulo: req.body.titulo,
    completada: req.body.completada || false
  });
  res.status(201).json(tarea);
});

router.put('/:id', async (req, res) => {
  const tarea = await Tarea.findByIdAndUpdate(
    req.params.id,
    { titulo: req.body.titulo, completada: req.body.completada },
    { new: true }
  );
  if (!tarea) return res.status(404).json({ error: 'Tarea no encontrada' });
  res.json(tarea);
});

router.delete('/:id', async (req, res) => {
  const tarea = await Tarea.findByIdAndDelete(req.params.id);
  if (!tarea) return res.status(404).json({ error: 'Tarea no encontrada' });
  res.status(204).send();
});

module.exports = router;
