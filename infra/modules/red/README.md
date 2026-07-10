# Módulo `red`

Módulo de red base sobre AWS. Crea una VPC con topología pública/privada en dos
zonas de disponibilidad, pensada para alojar cargas web accesibles desde Internet
(subredes públicas) junto a servicios sin exposición directa (subred privada) con
salida a Internet controlada mediante NAT.

## Topología

```
                         Internet
                            │
                    ┌───────┴────────┐
                    │ Internet GW    │
                    └───────┬────────┘
        ┌───────────────────┴───────────────────┐
        │ VPC (10.0.0.0/16)                      │
        │                                        │
        │  ┌── AZ a ──────┐   ┌── AZ b ───────┐  │
        │  │ pública 1    │   │ pública 2     │  │
        │  │ 10.0.1.0/24  │   │ 10.0.2.0/24   │  │
        │  │  · NAT GW     │   │               │  │
        │  └──────┬───────┘   └───────────────┘  │
        │         │ (salida)                      │
        │  ┌──────┴───────┐                       │
        │  │ privada      │                       │
        │  │ 10.0.10.0/24 │                       │
        │  └──────────────┘                       │
        └────────────────────────────────────────┘
```

- Las **subredes públicas** enrutan `0.0.0.0/0` al Internet Gateway y asignan IP
  pública automáticamente a las instancias que se lancen en ellas.
- La **subred privada** enruta `0.0.0.0/0` al NAT Gateway: puede iniciar
  conexiones salientes (actualizaciones, llamadas a APIs) pero no es alcanzable
  directamente desde Internet.

## Entradas

| Variable          | Tipo           | Default                            | Descripción                                              |
| ----------------- | -------------- | ---------------------------------- | -------------------------------------------------------- |
| `nombre_proyecto` | `string`       | —  (obligatoria)                   | Prefijo aplicado a la etiqueta `Name` de cada recurso.   |
| `vpc_cidr`        | `string`       | `10.0.0.0/16`                      | Rango CIDR principal de la VPC.                          |
| `azs`             | `list(string)` | `["us-east-2a","us-east-2b"]`      | Zonas de disponibilidad en las que se reparten subredes. |
| `cidrs_publicas`  | `list(string)` | `["10.0.1.0/24","10.0.2.0/24"]`    | CIDR de cada subred pública (una por AZ).                |
| `cidr_privada`    | `string`       | `10.0.10.0/24`                     | CIDR de la subred privada.                               |

## Salidas

| Output                 | Tipo           | Descripción                                        |
| ---------------------- | -------------- | -------------------------------------------------- |
| `vpc_id`               | `string`       | ID de la VPC creada.                               |
| `subnets_publicas_ids` | `list(string)` | IDs de las subredes públicas.                      |
| `subnet_privada_id`    | `string`       | ID de la subred privada.                           |
| `nat_public_ip`        | `string`       | IP pública (EIP) asociada al NAT Gateway.          |
| `igw_id`               | `string`       | ID del Internet Gateway.                           |

## Uso

```hcl
module "red" {
  source          = "./modules/red"
  nombre_proyecto = "libreria"
  # el resto de variables usa sus valores por defecto
}
```

El módulo no declara `provider` ni `backend`: hereda el provider AWS configurado
en el módulo raíz. La restricción de versión es laxa (`>= 6.0`) para que sea la
raíz quien fije la versión exacta del provider.

## Decisiones de diseño

- **Dos AZ para las subredes públicas.** Repartir las subredes públicas en dos
  zonas de disponibilidad es la base para alta disponibilidad: permite distribuir
  instancias o un balanceador entre zonas y tolerar la caída de una de ellas.

- **Una sola subred privada / un solo NAT Gateway.** Se opta por un único NAT en
  la primera AZ para reducir coste (cada NAT Gateway y su EIP tienen coste fijo).
  Es un compromiso consciente: la salida de la subred privada depende de esa AZ.
  Para HA plena se replicaría un NAT por zona; queda fuera del alcance de este
  módulo por criterio de coste.

- **`depends_on` explícito en el NAT Gateway.** Un NAT Gateway necesita que el
  Internet Gateway ya esté adjunto a la VPC para tener salida. Terraform no
  siempre infiere ese orden a partir de las referencias, así que se declara la
  dependencia de forma explícita para evitar errores de creación intermitentes.

- **`map_public_ip_on_launch = true` solo en las públicas.** Las instancias de las
  subredes públicas obtienen IP pública automáticamente; la subred privada nunca,
  reforzando que su único camino a Internet es el NAT.

- **`aws_eip` con `domain = "vpc"`.** Se usa el argumento `domain` en lugar del
  atributo `vpc = true`, deprecado desde el provider AWS 4.x.

- **`count` para las subredes públicas.** Se generan a partir de las listas `azs`
  y `cidrs_publicas`, de modo que el número de subredes públicas se ajusta a la
  longitud de la lista sin duplicar bloques de recurso.

- **Etiquetado uniforme `Name = "<nombre_proyecto>-<recurso>"`.** Da trazabilidad
  y facilita identificar los recursos del proyecto en la consola de AWS y en la
  facturación.
