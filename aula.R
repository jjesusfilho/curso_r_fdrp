# Curso introdutório de R para estudantes de direito (FDRP)
# Script da aula: rode linha a linha (Ctrl+Enter no Positron).

# 1. Instalação dos pacotes (uma vez só) ---------------------------------------

install.packages(c("tidyverse", "remotes"))
remotes::install_github("jjesusfilho/tjsp")
remotes::install_github("jjesusfilho/datajud")

# 2. R básico -------------------------------------------------------------------

2 + 2

pena <- 6
pena * 2

penas <- c(2, 4, 6, 8)
mean(penas)
penas[penas > 3]

library(tidyverse)

# 3. Dados reais: acórdãos do TJSP nos dois sistemas (plano B, sem internet) -----
# O TJSP tem dois sistemas: e-SAJ (processos antigos) e eproc (processos novos).
# Se a coleta ao vivo falhar, use os arquivos prontos do repositório:
# esaj <- readRDS(url("https://raw.githubusercontent.com/jjesusfilho/curso_r_fdrp/main/dados/esaj_voo.rds"))

esaj <- readRDS("dados/esaj_voo.rds")
eproc <- readRDS("dados/eproc_voo.rds")

glimpse(esaj)
glimpse(eproc)

# Juntando os dois sistemas (colunas em comum)
acordaos <- bind_rows(
  select(esaj, sistema, processo, classe, orgao_julgador, relator, data_julgamento, ementa),
  select(eproc, sistema, processo, classe, orgao_julgador, relator, data_julgamento, ementa)
)

acordaos |>
  count(sistema)

acordaos |>
  count(orgao_julgador, sort = TRUE)

acordaos |>
  filter(str_detect(ementa, "(?i)dano moral")) |>
  count(sistema, relator, sort = TRUE) |>
  head(5)

acordaos |>
  count(sistema, orgao_julgador) |>
  group_by(sistema) |>
  slice_max(n, n = 6) |>
  ggplot(aes(x = n, y = reorder(orgao_julgador, n))) +
  geom_col() +
  facet_wrap(~ sistema, scales = "free_y") +
  labs(x = "Acórdãos", y = NULL, title = "Dano moral por atraso de voo, TJSP, jan a set/2026")

# 4. Coleta ao vivo no TJSP (datas no formato dd/mm/aaaa) -----------------------

library(tjsp)

# e-SAJ: 20 acórdãos por página
pasta_esaj <- "esaj"
dir.create(pasta_esaj, showWarnings = FALSE)

tjsp_baixar_cjsg(
  livre = "dano moral atraso voo",
  inicio = "01/01/2026",
  fim = "30/09/2026",
  n = 3,
  diretorio = pasta_esaj
)

esaj <- tjsp_ler_cjsg(diretorio = pasta_esaj)

# eproc: 10 acórdãos por página
pasta_eproc <- "eproc"
dir.create(pasta_eproc, showWarnings = FALSE)

tjsp_baixar_eproc2g_jurisprudencia(
  pesquisa = "dano moral atraso voo",
  inicio = "01/01/2026",
  fim = "30/09/2026",
  n = 6,
  diretorio = pasta_eproc
)

eproc <- tjsp_ler_eproc_jurisprudencia(diretorio = pasta_eproc)

# 5. DataJud: metadados de processos ---------------------------------------------

library(datajud)

set_api_key(get_default_api_key())

# Pode levar de 15 a 60 segundos; mantenha o size pequeno.
processos <- search_processes(
  tribunal = "tjsp",
  classe_codigo = "7",
  dataAjuizamento_start = "2025-01-01",
  dataAjuizamento_end = "2025-01-31",
  size = 100
)

# Plano B:
# processos <- readRDS("dados/datajud_tjsp.rds")

processos <- readRDS("dados/datajud_tjsp.rds")

processos |>
  count(assunto, sort = TRUE) |>
  head(10)

processos |>
  mutate(dia = as.Date(data_ajuizamento)) |>
  count(dia) |>
  ggplot(aes(x = dia, y = n)) +
  geom_line() +
  labs(x = NULL, y = "Processos ajuizados")
