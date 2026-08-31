# ===============================================
# Copiar dashboard generado a la carpeta HTML
# ===============================================

# Carpeta script

carpeta_codigo <- dirname(rstudioapi::getSourceEditorContext()$path)

# From

origen <- file.path(
  carpeta_codigo, "dashboard.html"
)

# To

carpeta_html <-  file.path(dirname(carpeta_codigo), "HTML")
destino <- file.path(carpeta_html, "dashboard.html")

# Comprobaciones 

stopifnot(file.exists(origen))

dir.create(
  carpeta_html,
  showWarnings = FALSE,
  recursive = TRUE
)

file.copy(
  from = origen,
  to = destino,
  overwrite = TRUE
)

stopifnot(file.exists(destino))

message("HTML copiado correctamente a 04_Dashboard/HTML/dashboard.html")
