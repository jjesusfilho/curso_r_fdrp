# Gera as bases do plano B (dados/). Rode uma vez, com internet.
library(tidyverse)
library(datajud)
library(tjsp)

dir.create("dados", showWarnings = FALSE)

# DataJud: 100 processos cíveis do TJSP ajuizados em janeiro de 2025
set_api_key(get_default_api_key())

datajud_tjsp <- search_processes(
  tribunal = "tjsp",
  classe_codigo = "7",
  dataAjuizamento_start = "2025-01-01",
  dataAjuizamento_end = "2025-01-31",
  size = 100
) |>
  mutate(
    classe = map_chr(classe, "nome"),
    assunto = map_chr(assuntos, \(x) x[[1]]$nome %||% NA_character_),
    orgao = map_chr(orgaoJulgador, "nome"),
    data_ajuizamento = ymd_hms(dataAjuizamento)
  ) |>
  select(numeroProcesso, classe, assunto, orgao, data_ajuizamento)

saveRDS(datajud_tjsp, "dados/datajud_tjsp.rds")

# TJSP: acórdãos sobre dano moral por atraso de voo (60 decisões)
pasta <- tempfile()
dir.create(pasta)

tjsp_baixar_cjsg(
  livre = "dano moral atraso voo",
  inicio = "01/01/2025",
  fim = "30/06/2025",
  n = 3,
  diretorio = pasta
)

cjsg_voo <- tjsp_ler_cjsg(diretorio = pasta)

saveRDS(cjsg_voo, "dados/cjsg_voo.rds")
