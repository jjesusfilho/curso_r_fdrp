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

# 3. Dados reais: acórdãos do TJSP (plano B, sem internet) -----------------------
# Se a coleta ao vivo falhar, use os arquivos prontos do repositório:
# acordaos <- readRDS("dados/cjsg_voo.rds")
# acordaos <- readRDS(url("https://raw.githubusercontent.com/jjesusfilho/curso_r_fdrp/main/dados/cjsg_voo.rds"))

acordaos <- readRDS("dados/cjsg_voo.rds")

glimpse(acordaos)

acordaos |>
  count(orgao_julgador, sort = TRUE)

acordaos |>
  filter(str_detect(ementa, "(?i)dano moral")) |>
  count(relator, sort = TRUE) |>
  head(5)

acordaos |>
  count(orgao_julgador) |>
  slice_max(n, n = 8) |>
  ggplot(aes(x = n, y = reorder(orgao_julgador, n))) +
  geom_col() +
  labs(x = "Acórdãos", y = NULL, title = "Dano moral por atraso de voo, TJSP, 1º semestre de 2025")

# 4. Coleta ao vivo no TJSP (datas no formato dd/mm/aaaa) -----------------------

library(tjsp)

pasta <- "cjsg"
dir.create(pasta, showWarnings = FALSE)

tjsp_baixar_cjsg(
  livre = "dano moral atraso voo",
  inicio = "01/01/2025",
  fim = "30/06/2025",
  n = 3,
  diretorio = pasta
)

acordaos <- tjsp_ler_cjsg(diretorio = pasta)

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
