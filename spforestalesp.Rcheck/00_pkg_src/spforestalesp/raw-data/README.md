# especiesforestalesPE

Lista Oficial de Especies Forestales del Perú (SERFOR, 2023) como conjunto de datos para R.

## Descripción

Este paquete contiene la **Lista Oficial de Especies Forestales** aprobada por el
Servicio Nacional Forestal y de Fauna Silvestre (SERFOR) del Perú mediante la
**Resolución de Dirección Ejecutiva N° D000163-2023-MIDAGRI-SERFOR-DE**
(Magdalena del Mar, 18 de julio de 2023).

La lista incluye **734 especies forestales** con su nombre científico (con autoría),
familia botánica, nombres comunes y nombre comercial de la madera aserrada.

## Contexto normativo

- **Objetivo:** estandarizar las denominaciones de las especies forestales para
  un mejor registro y monitoreo en el Sistema Nacional de Información Forestal y
  de Fauna Silvestre (SNIFFS) y para la gestión de los recursos forestales a nivel nacional.
- **Reemplaza** a la lista aprobada por la RDE N° 118-2019-MINAGRI-SERFOR-DE,
  que queda sin efecto (art. 5).
- **Actualización:** el SERFOR debe actualizar la lista como mínimo cada cuatro (04) años (art. 4).
- **Alcance legal:** la lista no otorga derechos de acceso ni de aprovechamiento
  sostenible de recursos forestales, ni modifica las prohibiciones o restricciones
  de la legislación vigente (art. 3).
- **Control forestal en el transporte (art. 2):** ante la duda en la identificación
  de la especie transportada, las Autoridades Regionales Forestales y de Fauna
  Silvestre deben considerar de manera excepcional la coincidencia a nivel de género
  para los siguientes géneros, lo que permite continuar con el transporte de los
  productos maderables transformados: *Aniba* (excepto *Aniba rosaeodora*),
  *Brosimum*, *Ficus*, *Iryanthera*, *Nectandra*, *Ocotea*, *Otoba*, *Ormosia*,
  *Parkia*, *Pouteria*, *Protium*, *Schizolobium* y *Virola*.

## Instalación

```r
# install.packages("remotes")
remotes::install_github("usuario/especiesforestalesPE")
```

## Contenido

El objeto `especies_forestales` es un `data.frame` con 734 filas y las columnas:

| Columna | Descripción |
| --- | --- |
| `n` | Número de orden en la lista oficial (1 a 734). |
| `especie` | Nombre científico con autoría. |
| `familia` | Familia botánica. |
| `nombre_comun` | Nombres comunes registrados, separados por comas. |
| `nombre_comercial` | Nombre comercial de la madera aserrada. |

Convenciones de la fuente:

- `S.I.`: sin información.
- `N.D.`: no se ha determinado un nombre comercial para la madera aserrada de la especie.
- `No registra`: la especie no tiene nombre común registrado.

## Uso

```r
library(especiesforestalesPE)

head(especies_forestales)

# Especies de la familia Meliaceae
subset(especies_forestales, familia == "Meliaceae")

# Buscar por nombre común
especies_forestales[grepl("shihuahuaco", especies_forestales$nombre_comun,
                          ignore.case = TRUE), ]

# Géneros del art. 2 (control forestal en el transporte)
generos_art2()
```

## Fuente

SERFOR. *Resolución de Dirección Ejecutiva N° D000163-2023-MIDAGRI-SERFOR-DE* y su Anexo
«Lista Oficial de Especies Forestales». Portal institucional: <https://www.serfor.gob.pe>.

## Aviso

Este paquete es una transcripción de un documento oficial con fines de consulta y
análisis. No es un producto oficial del SERFOR. Ante cualquier discrepancia, prevalece
el texto publicado por el SERFOR y en el Diario Oficial El Peruano.

## Licencia

Ver el campo `License` en `DESCRIPTION`.
