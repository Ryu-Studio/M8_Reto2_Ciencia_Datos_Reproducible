# ============================================================
# PROYECTO: Percepciones de las etapas de la vida en Europa 
#           (European Social Survey, Round 9)
#
# SCRIPT: Importación de datos 
#
# OBJETIVO: 
# Importar el fichero original de la European Social Survey 
# y comprobar que corresponde al conjunto de datos utilizado 
# en el proyecto antes de iniciar su depuración.
#
# FUENTE:
# European Social Survey (ESS), Round 9 
# Integrated File, Edition 3.3
# DOI: https://doi.org/10.21338/ess9e03_3
#
# Autora: Maria Meritxell Ruiz Muñoz 
# ============================================================


# ------------------------------------------------------------
# 1. Cargar paquetes 
# ------------------------------------------------------------

# haven permite importar el fichero original en formato SPSS (.sav).

# Instalar haven únicamente si no está disponible.

if (!requireNamespace("haven", quietly = TRUE)) {
    install.packages("haven")
  } 

# Cargar el paquete.  

library(haven)

# ------------------------------------------------------------
# 2. Definir las rutas de los archivos originales 
# ------------------------------------------------------------

# Se utilizan rutas relativas a la raíz del proyecto. 
# Los datos originales y el codebook se encuentran en 
# 03_Datos/datos_originales/.
 

ruta_datos <- "03_Datos/datos_originales/ESS9e03_3.sav"
ruta_codebook <- "03_Datos/datos_originales/ESS9e03_3 codebook.html"

# Comprobar que ambos archivos están disponibles antes de importarlos.

if(!file.exists(ruta_datos)) {
  stop("No se encuentra el archivo original ESS9e03_3.sav.",
       "Obtenga el fichero original de ESS9 (edición 3.3)",
       "y guárdelo en 03_Datos/datos_originales/"
       )
}

if(!file.exists(ruta_codebook)) {
  stop("No se encuentra codebook de ESS9.",
       "Obtenga el codebook correspondiente a ESS9 (edición 3.3)",
       "y guárdelo en 03_Datos/datos_originales/"
       )
}
 
# ------------------------------------------------------------
# 3. Importar los datos originales  
# ------------------------------------------------------------

# user_na = TRUE conserva inicialmente los códigos especiales 
# definidos por ESS. Su tratamiento se realizará de forma explícita 
# en el script de depuración, evitando modificar los datos durante 
# la importación. 

datos_originales <- read_sav(ruta_datos,
                             user_na = TRUE
                             )

# ------------------------------------------------------------
# 4. Comprobar la integridad de la importación  
# ------------------------------------------------------------

# Verificar que el fichero importado corresponde a la edición utilizada.
# La ejecución se detiene si no contiene las las 49.519 observaciones y 
# 575 variables documentadas para ESS9, edición 3.3.

stopifnot(
  nrow(datos_originales) == 49519, 
  ncol(datos_originales) == 575
)

# ------------------------------------------------------------
# 5. Comprobar las variables necesarias para el proyecto  
# ------------------------------------------------------------

# Se verifica que el fichero importado tiene todas las variables 
# seleccionadas para el análisis. La selección y transformación de
# estas variables se realizará posteriormente en depuracion.R. 

variables_proyecto <- c(
  "admge",
  "ageadlt",
  "agemage", 
  "ageoage",
  "plnftr",
  "happy",
  "stflife",
  "cntry",
  "gndr",
  "agea"
)

variables_ausentes <- setdiff(
  variables_proyecto,
  names(datos_originales)
)

if(length(variables_ausentes) > 0) {
  stop(
    "Faltan variables necesarias para el proyecto: ",
    paste(variables_ausentes, collapse = ", ")
  )
}

# ------------------------------------------------------------
# 6. Confirmar que la importación ha finalizado correctamente   
# ------------------------------------------------------------

message(
  "Importación completada correctamente:  ", 
  nrow(datos_originales), " observaciones y ",
  ncol(datos_originales), " variables."
)
