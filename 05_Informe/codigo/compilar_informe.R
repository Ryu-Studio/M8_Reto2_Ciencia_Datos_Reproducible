# ===============================================
# Copiar informe generado a la carpeta PDF
# ===============================================

# Carpeta script

carpeta_codigo <- dirname(rstudioapi::getSourceEditorContext()$path)

# From

origen <- file.path(
  carpeta_codigo, "informe.pdf"
)

# To

carpeta_pdf <-  file.path(dirname(carpeta_codigo), "PDF")
destino <- file.path(carpeta_pdf, "informe.pdf")

# Comprobaciones 

stopifnot(file.exists(origen))

dir.create(
  carpeta_pdf,
  showWarnings = FALSE,
  recursive = TRUE
)

file.copy(
  from = origen,
  to = destino,
  overwrite = TRUE
)

stopifnot(file.exists(destino))

message("PDF copiado correctamente a 05_Informe/PDF/informe.pdf")