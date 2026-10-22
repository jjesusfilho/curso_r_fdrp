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

# TJSP, e-SAJ: acórdãos sobre dano moral por atraso de voo (60 decisões)
pasta_esaj <- tempfile()
dir.create(pasta_esaj)

tjsp_baixar_cjsg(
  livre = "dano moral atraso voo",
  inicio = "01/01/2026",
  fim = "30/09/2026",
  n = 3,
  diretorio = pasta_esaj
)

esaj_voo <- tjsp_ler_cjsg(diretorio = pasta_esaj) |>
  mutate(sistema = "e-SAJ")

saveRDS(esaj_voo, "dados/esaj_voo.rds")

# TJSP, eproc: mesma pesquisa (60 decisões; o eproc traz 10 por página)
pasta_eproc <- tempfile()
dir.create(pasta_eproc)

tjsp_baixar_eproc2g_jurisprudencia(
  pesquisa = "dano moral atraso voo",
  inicio = "01/01/2026",
  fim = "30/09/2026",
  n = 6,
  diretorio = pasta_eproc
)

eproc_voo <- tjsp_ler_eproc_jurisprudencia(diretorio = pasta_eproc) |>
  mutate(sistema = "eproc")

saveRDS(eproc_voo, "dados/eproc_voo.rds")
