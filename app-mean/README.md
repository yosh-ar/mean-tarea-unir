# app-mean

App MEAN mínima (MongoDB + Express + Angular + Node) para probar un despliegue en AWS. Sin autenticación, sin tests, sin Docker.

## Estructura

```
app-mean/
  backend/    Node 20 + Express + Mongoose, API REST en /api/tareas
  frontend/   Angular standalone, una sola página
  nginx.conf  Config de ejemplo para servir el frontend y proxear /api/
```

## Requisitos

- Node 20+
- MongoDB corriendo localmente (o accesible vía `MONGO_URI`)
- Angular CLI (`npm install -g @angular/cli`) para correr el frontend en desarrollo

## Backend

```bash
cd backend
npm install
npm start
```

Escucha en `http://localhost:3000`. La conexión a Mongo usa la variable de entorno `MONGO_URI` (fallback: `mongodb://localhost:27017/tareas`):

```bash
MONGO_URI="mongodb://localhost:27017/tareas" npm start
```

Endpoints:

- `GET /api/health` — estado de la API y de la conexión a Mongo
- `GET /api/tareas` — lista todas las tareas
- `POST /api/tareas` — crea una tarea (`{ "titulo": "..." }`)
- `PUT /api/tareas/:id` — actualiza una tarea (`{ "titulo": "...", "completada": true }`)
- `DELETE /api/tareas/:id` — borra una tarea

## Frontend

```bash
cd frontend
npm install
npm start
```

Sirve en `http://localhost:4200` y proxea las llamadas a `/api` hacia `http://localhost:3000` (ver `proxy.conf.json`), así que el backend debe estar corriendo en paralelo.

Para generar el build de producción (el que sirve Nginx desde `/var/www/html`):

```bash
npm run build
```

El resultado queda en `frontend/dist/frontend/browser`.

## Nginx (producción)

`nginx.conf` sirve el build de Angular desde `/var/www/html` y hace proxy de `/api/` hacia `http://localhost:3000`, donde corre el backend. Copiar el contenido de `frontend/dist/frontend/browser` a `/var/www/html` y el archivo a `/etc/nginx/sites-available/` (o `conf.d/`), luego recargar Nginx.
