# Despliegue de aplicación MEAN en AWS con Terraform

Infraestructura como código para desplegar una aplicación MEAN (MongoDB, Express,
Angular, Node) en AWS. La infraestructura se define en Terraform con cuatro módulos
(`red`, `seguridad`, `computo`, `balanceador`) y la aplicación se despliega
automáticamente en el primer arranque de las instancias mediante `user_data`.

Proyecto de la asignatura Herramientas DevOps (UNIR) — Actividad grupal.

## Arquitectura

```
                        Internet
                           │
                     ┌─────┴─────┐
                     │    ALB    │  HTTP :80 (público)
                     └─────┬─────┘
        ┌──────────────────┴──────────────────────┐
        │ VPC 10.0.0.0/16 (us-east-2)             │
        │                                          │
        │  ┌─ pública 1 (2a) ─┐ ┌─ pública 2 (2b)┐│
        │  │ 10.0.1.0/24      │ │ 10.0.2.0/24    ││
        │  │  · EC2 app       │ │  (solo ALB)    ││
        │  │    Nginx + Node  │ │                ││
        │  │  · NAT Gateway   │ │                ││
        │  └───────┬──────────┘ └────────────────┘│
        │          │ :27017 / :22 (bastión)        │
        │  ┌───────┴──────────┐                    │
        │  │ privada (2a)     │                    │
        │  │ 10.0.10.0/24     │                    │
        │  │  · EC2 MongoDB   │  sin IP pública    │
        │  └──────────────────┘                    │
        └──────────────────────────────────────────┘
```

Flujo de una petición: el usuario entra por el DNS del ALB → el ALB reenvía al
puerto 80 de la instancia de app → Nginx sirve el frontend de Angular y proxea
`/api/` al backend Node (puerto 3000, localhost) → el backend se conecta a
MongoDB por su IP privada (27017).

Seguridad en capas: cada security group solo acepta tráfico del escalón anterior
(Internet → ALB → app → mongo). MongoDB no tiene IP pública; su única salida a
Internet (para instalar paquetes) es el NAT Gateway, y el único camino SSH hacia
ella es saltando por la instancia de app (patrón bastión).

## Estructura del repositorio

```
infra/                    Terraform (módulo raíz)
  main.tf                 Providers y composición de los 4 módulos
  variables.tf            region, nombre_proyecto, repo_url, key_name
  outputs.tf              IPs, DNS del ALB
  modules/
    red/                  VPC, subredes, IGW, NAT, tablas de rutas (ver su README)
    seguridad/            Security groups del ALB, app y mongo
    computo/              Instancias EC2 + scripts de user_data
    balanceador/          ALB, target group, listener HTTP
app-mean/                 Código de la aplicación (ver su README)
  backend/                Node 20 + Express + Mongoose
  frontend/               Angular 18 (incluye dist/ compilado)
  nginx.conf              Sirve el frontend y proxea /api/ a Node
docs/                     Capturas de la infraestructura desplegada
logs/                     Evidencias de los plan/apply de cada módulo
```

## Requisitos previos

1. **Terraform >= 1.7** y **AWS CLI** con credenciales configuradas
   (`aws configure` o variables de entorno) sobre una cuenta con permisos de
   VPC, EC2 y ELB.

2. **Key pair de EC2 existente en la región** (`us-east-2` por defecto). El
   nombre se pasa en la variable `key_name` (default: `devops-unir`). Terraform
   no lo crea:

   ```bash
   aws ec2 create-key-pair --key-name devops-unir --region us-east-2 \
     --query 'KeyMaterial' --output text > devops-unir.pem
   chmod 400 devops-unir.pem
   ```

3. **AMI base construida con Packer** disponible en la cuenta, con nombre
   `nodejs-nginx-*`. Debe traer Ubuntu 22.04, Node 20, Nginx y un unit de
   systemd llamado `app`. El módulo `computo` la busca con un data source
   (`owners = ["self"]`) y **el plan falla si no existe**. Verificar con:

   ```bash
   aws ec2 describe-images --owners self --region us-east-2 \
     --filters "Name=name,Values=nodejs-nginx-*" \
     --query 'Images[].{Name:Name,Id:ImageId}'
   ```

4. **Repositorio de la app accesible por HTTPS sin credenciales.** La variable
   `repo_url` apunta al repo que `user_data` clona en la instancia de app. El
   repo debe incluir el frontend ya compilado en
   `app-mean/frontend/dist/frontend/browser/` (este repositorio ya lo incluye).

## Despliegue

```bash
cd infra
terraform init
terraform plan
terraform apply
```

Variables que se pueden ajustar sin tocar código (por CLI o `terraform.tfvars`):

| Variable          | Default                                            | Descripción                              |
| ----------------- | -------------------------------------------------- | ---------------------------------------- |
| `region`          | `us-east-2`                                        | Región de despliegue (*)                 |
| `nombre_proyecto` | `mean`                                             | Prefijo de nombre de todos los recursos  |
| `key_name`        | `devops-unir`                                      | Key pair para SSH                        |
| `repo_url`        | `https://github.com/yosh-ar/mean-tarea-unir.git`   | Repo con el código de la app             |

(*) Si se cambia la región hay que ajustar también las AZ del módulo `red`
(variable `azs`) y reconstruir la AMI en esa región.

El apply crea unos 20 recursos y tarda alrededor de 5 minutos (el NAT Gateway y
el ALB son lo más lento). Al terminar muestra los outputs:

```
dns_balanceador      = "mean-alb-xxxxxxxxx.us-east-2.elb.amazonaws.com"
ip_publica_app       = "x.x.x.x"
ip_privada_app       = "10.0.1.x"
ip_privada_mongo     = "10.0.10.x"
ip_publica_nat_mongo = "x.x.x.x"
```

## Verificación

El `user_data` de ambas instancias sigue ejecutándose unos minutos después de
que Terraform termine; dar margen antes de probar.

```bash
# Frontend por el balanceador (punto de entrada oficial)
curl -I http://$(terraform output -raw dns_balanceador)

# API y estado de la conexión a Mongo
curl http://$(terraform output -raw dns_balanceador)/api/health

# Crear y listar tareas
curl -X POST http://$(terraform output -raw dns_balanceador)/api/tareas \
  -H 'Content-Type: application/json' -d '{"titulo":"probar despliegue"}'
curl http://$(terraform output -raw dns_balanceador)/api/tareas
```

En la consola de AWS, el target group `mean-tg` debe mostrar la instancia
`healthy` (health check a `/` esperando HTTP 200 cada 30 s).

## Acceso SSH

```bash
# Instancia de app (directa, tiene IP pública)
ssh -i devops-unir.pem ubuntu@$(terraform output -raw ip_publica_app)

# MongoDB, usando la app como bastión (agent forwarding o ProxyJump)
ssh -i devops-unir.pem -J ubuntu@$(terraform output -raw ip_publica_app) \
  ubuntu@$(terraform output -raw ip_privada_mongo)
```

## Diagnóstico de problemas

| Síntoma | Dónde mirar |
| ------- | ----------- |
| `terraform plan` falla en `data.aws_ami.app` | No existe la AMI `nodejs-nginx-*` en la cuenta/región (requisito 3) |
| Target `unhealthy` en el ALB | `/var/log/user-data.log` en la instancia de app; luego `systemctl status nginx app` |
| Frontend carga pero `/api` da 502 | El backend no arrancó: `journalctl -u app` en la instancia de app |
| `/api/health` reporta Mongo desconectado | `user_data` de mongo aún corriendo o falló: entrar por bastión y revisar `/var/log/user-data.log` y `systemctl status mongod` |

## Costes y limpieza

La infraestructura genera coste mientras esté levantada aunque no se use: el NAT
Gateway y el ALB cobran por hora, más las dos instancias `t3.micro` y la EIP.
Para destruir todo:

```bash
cd infra
terraform destroy
```

La AMI de Packer y el key pair no los gestiona Terraform, así que sobreviven al
destroy (la AMI y sus snapshots también facturan almacenamiento si se dejan).

## Notas de seguridad

- `cidr_ssh` (módulo `seguridad`) por defecto deja SSH abierto a `0.0.0.0/0`
  para facilitar la práctica. Para cualquier otro uso, restringirlo a la IP de
  administración.
- Solo hay listener HTTP (80); no hay TLS. Añadir un certificado ACM y un
  listener 443 sería el siguiente paso natural.
- El estado de Terraform es local (sin backend remoto). Para trabajo en equipo,
  migrarlo a S3.
