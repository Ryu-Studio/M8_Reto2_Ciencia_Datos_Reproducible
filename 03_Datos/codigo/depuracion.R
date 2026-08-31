# ============================================================
# PROYECTO: Percepciones de las etapas de la vida en Europa 
#           (European Social Survey, Round 9)
#
# SCRIPT: Depuración de datos 
#
# OBJETIVO: 
# Seleccionar las variables utilizadas en el proyecto, identificar 
# y tratar los códigos especiales documentados por la ESS y generar 
# un conjunto de datos procesados para los análisis posteriores.
#
# FUENTE:
# European Social Survey (ESS), Round 9 
# Integrated File, Edition 3.3
# DOI: https://doi.org/10.21338/ess9e03_3
#
# Autora: Maria Meritxell Ruiz Muñoz 
# ============================================================


# ------------------------------------------------------------
# 1. Preparar el entorno de trabajo 
# ------------------------------------------------------------

# dplyr se utiliza para seleccionar variables, resumir información 
# y realizar las comprobaciones necesarias durante la depuración. 

if(!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}

library(dplyr)

# Ejecutar el script de importación para obtener datos_originales
# desde el fichero ESS9 original y realizar sus comprobaciones 
# previas a su depuración. 

source("03_Datos/codigo/importacion.R")

# ------------------------------------------------------------
# 2. Seleccionar las variables del proyecto 
# ------------------------------------------------------------

# Conservar únicamente las variables previamente definidas
# en el script de importación.

datos_seleccionados <- datos_originales |>
  select(all_of(variables_proyecto))

# Comprobar que la selección conserva todas las observaciones 
# y exactamente las variables previstas. 

stopifnot(
  nrow(datos_seleccionados) == nrow(datos_originales),
  ncol(datos_seleccionados) == length(variables_proyecto)
)

# ------------------------------------------------------------
# 3. Comprobar los códigos especiales 
# ------------------------------------------------------------

# Antes de depurar los datos, se comprueba la presencia de los 
# códigos especiales definidos por ESS para las variables seleccionadas.
# Esta comprobación permite distinguir las respuesta válidas de los 
# valores que posteriormente se convertirán en NA. 

# 3.1 Variable de control de diseño 
# ------------------------------------------------------------

# admge registra el grupo asignado mediante la aleatorización 
# del split ballot. Según el codebook, los valores 1 y 2 
# corresponden a los dos grupos y 9 es un código especial.

frecuencias_admge <- table(
  datos_seleccionados$admge,
  useNA = "ifany"
)

frecuencias_admge

# 3.2. Fases de la vida 
# ------------------------------------------------------------
# ageadlt, agemage, ageoage recogen la edad que la persona encuestada 
# considera que marca el incio de la adultez, la mediana edad y la vejez,
# respectivamente. Según el codebook, 0 = "Depende" es una respuesta válida,
# mientras que 777, 888 y 999 corresponden a códigos especiales. 

variables_fases <- c("ageadlt", "agemage", "ageoage")

# Examinar las frecuencias de los valores observados en cada variable.

frecuencias_fases <- lapply(
  datos_seleccionados[variables_fases],
  function(x) table(x, useNA = "ifany")
  )

frecuencias_fases

# 3.3. Planificación del futuro 
# ------------------------------------------------------------
# plnftr recoge la orientación hacia la planificación del futuro
# en una escala de 0 a 10. Según el codebook, 77, 88 y 99 
# corresponden a códigos especiales. 

frecuencias_plnftr <- table(
  datos_seleccionados$plnftr,
  useNA = "ifany"
)

frecuencias_plnftr

# 3.4. Bienestar subjetivo
# ------------------------------------------------------------
# happy y stflife recogen la felicidad y la satisfacción con la vida,
# respectivamente, en escalas de 0 a 10. Según el codebook, 
# 77, 88 y 99 corresponden a códigos especiales. 

variables_bienestar <- c("happy", "stflife")

frecuencias_bienestar <- lapply(
  datos_seleccionados[variables_bienestar],
  function(x) table(x, useNA = "ifany")
)

frecuencias_bienestar

# 3.5. Sociodemográficas
# ------------------------------------------------------------
# cntry identifica el país mediante códigos alfabéticos.
# Según el codebook, no presenta códigos especiales. 

frecuencias_cntry <- table(
  datos_seleccionados$cntry,
  useNA = "ifany"
)

frecuencias_cntry


# gndr recoge el sexo de la persona encuestada. 
# Según el codebook, 1 y 2 son valores válidos
# y 9 está definido como código especial. 

frecuencias_gndr <- table(
  datos_seleccionados$gndr,
  useNA = "ifany"
)

frecuencias_gndr


# agea recoge la edad calculada de la persona encuestada. 
# Según el codebook, 999 corresponde a un código especial.

frecuencias_agea <- table(
  datos_seleccionados$agea,
  useNA = "ifany"
)

frecuencias_agea

# ------------------------------------------------------------
# 4. Aplicar el tratamiento de valores perdidos 
# ------------------------------------------------------------

# Los códigos identificados como valores perdidos en el codebook 
# de ESS9 se recodifican como NA. Las frecuencias examinadas
# previamente permiten comprobar su presencia y cuantificar 
# el impacto de esta recodificación. No se realiza imputación. 
# 
# En las variables de fases de la vida, 0 = "Depende" es una
# respuesta válida y, por tanto, se conserva. 

mapa_perdidos <- list(
  admge = 9, 
  ageadlt = c(777, 888, 999),
  agemage = c(777, 888, 999),
  ageoage = c(777, 888, 999),
  plnftr = c(77, 88, 99),
  happy = c(77, 88, 99),
  stflife = c(77, 88, 99),
  gndr = 9,
  agea = 999
)

# Sustituir por NA únicamente los códigos definidos como
# valores perdidos para cada variable.

datos_limpios <- datos_seleccionados

for (variable in names(mapa_perdidos)) {
  datos_limpios[[variable]][
    datos_limpios[[variable]] %in% mapa_perdidos[[variable]]
  ] <- NA
}

# Eliminar las etiquetas heredadas del archivo SPSS
# conservando los valores ya depurados. 

datos_limpios <- datos_limpios |>
  mutate(
    across(everything(), haven::zap_labels)
  )

# ------------------------------------------------------------
# 5. Verificar la depuración   
# ------------------------------------------------------------

# 5.1. Comprobar que se conservan las dimensiones del conjunto 
# de datos tras la recodificación.
# ------------------------------------------------------------

stopifnot(
  nrow(datos_limpios) == nrow(datos_seleccionados),
  ncol(datos_limpios) == ncol(datos_seleccionados)
)

# 5.2. Comprobar que los códigos especiales definidos en el  
# mapa de valores perdidos ya no están presentes.
# ------------------------------------------------------------

codigos_restantes <- sapply(
  names(mapa_perdidos),
  function(variable) {
    sum(datos_limpios[[variable]] %in% mapa_perdidos[[variable]],
    na.rm = TRUE) 
  }
)

codigos_restantes

# 5.3. Comprobar que 0 = "Depende" se conserva como respuesta
# válida en las variables de fases de la vida.
# ------------------------------------------------------------

depende_conservado <- sapply(
  variables_fases, 
  function(variable) {
    sum(datos_limpios[[variable]] == 0, na.rm = TRUE)
  }
)

depende_conservado

# 5.4. Resumir los valores perdidos después de la depuración.
# ------------------------------------------------------------

resumen_na <- data.frame(
  variable = names(datos_limpios),
  n_na = sapply(datos_limpios, function(x) sum(is.na(x))),
  porcentaje_na = round(
    sapply(datos_limpios, function(x) mean(is.na(x)) * 100),
    2
  )
)

resumen_na

# 5.5. Comprobación final de la depuración.
# ------------------------------------------------------------

stopifnot(
  all(codigos_restantes == 0),
  all(depende_conservado > 0)
)

message(
  "Depuración completada correctamente: ",
  nrow(datos_limpios), " observaciones y ",
  ncol(datos_limpios), " variables"
)

# ------------------------------------------------------------
# 6. Guardar los datos depurados   
# ------------------------------------------------------------

saveRDS(
  datos_limpios,
  "03_Datos/datos_procesados/datos_limpios.rds"
)

# 6.1. Verificar el archivo guardado.
# ------------------------------------------------------------

ruta_limpios <- "03_Datos/datos_procesados/datos_limpios.rds"

stopifnot(
  file.exists(ruta_limpios)
)

datos_verificación <- readRDS(ruta_limpios)

stopifnot(
  nrow(datos_verificación) == nrow(datos_limpios),
  ncol(datos_verificación) == ncol(datos_limpios),
  identical(names(datos_verificación), names(datos_limpios))
)

message(
  "Archivo de datos_limpios.rds guardado y verificado correctamente."
)

rm(datos_verificación)