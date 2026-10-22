# Roteiro: introdução ao R para estudantes de direito

Duração: 2 horas. Formato: mão na massa, com instalação em sala. Material de apoio no repositório: `aula.R` (script completo), `dados/` (bases do plano B) e `coletar_dados.R` (como as bases foram geradas).

| Bloco | Tema | Tempo |
|---|---|---|
| 1 | Abertura e instalação | 20 min |
| 2 | Positron | 10 min |
| 3 | R básico | 25 min |
| 4 | Dados judiciais (tjsp e datajud) | 25 min |
| 5 | Claude Code | 30 min |
| 6 | Encerramento | 10 min |

## Antes de começar (professor)

- Deixe o repositório aberto no Positron e o `aula.R` pronto.
- Confira a rede da sala. O TJSP e o DataJud são consultas externas; se falharem, use o plano B (`readRDS` dos arquivos em `dados/`).
- O DataJud fica lento em horário comercial (15 a 60 s por consulta, às vezes erro 504 ou 429). Nunca peça mais de 100 processos na aula, e rode a consulta uma vez só, na sua máquina, enquanto os alunos acompanham a explicação.
- Não rode o tjsp com 30 alunos ao mesmo tempo sem aviso: peça que baixem só 3 páginas do e-SAJ e 6 do eproc (`n = 3` e `n = 6`).

## Bloco 1: abertura e instalação (20 min)

Objetivo: todos com R e Positron instalados ao fim do bloco.

Fala de abertura (5 min):

- Direito é feito de texto e de decisões; R permite contar, comparar e ver padrões em milhares delas.
- Jurimetria: o estudo empírico do direito. O que o juiz decide, quanto tempo leva, de que depende.
- Hoje o objetivo não é virar programador, é perder o medo e sair com um caminho.

Instalação (15 min), nesta ordem:

1. R, em https://cloud.r-project.org (escolher o sistema operacional).
2. Positron, em https://positron.posit.co/download.html.
3. Quem tiver conta, instala o Claude Code durante a espera (instruções em https://docs.claude.com/claude-code).

Problemas comuns:

- Windows sem permissão de administrador: instalar para o usuário atual.
- Mac: escolher a versão certa (Apple Silicon ou Intel).
- Quem não conseguir instalar acompanha em dupla.

## Bloco 2: Positron (10 min)

Objetivo: reconhecer as áreas da tela e saber onde digitar.

- Abrir uma pasta (File > Open Folder) e criar um script `minha_aula.R`.
- Áreas: editor (acima), console (abaixo), variáveis e arquivos (lateral), gráficos.
- Script é o que fica guardado; console é rascunho. Ctrl+Enter executa a linha.
- Deixar a instalação dos pacotes rodando enquanto explica (as 3 linhas iniciais do `aula.R`):

```r
install.packages(c("tidyverse", "remotes"))
remotes::install_github("jjesusfilho/tjsp")
remotes::install_github("jjesusfilho/datajud")
```

Se o `install_github` pedir para atualizar pacotes, responder `3` (nenhum).

## Bloco 3: R básico (25 min)

Objetivo: ler e escrever as linhas mais comuns de uma análise.

Ao vivo (10 min):

```r
pena <- 6
pena * 2

penas <- c(2, 4, 6, 8)
mean(penas)
penas[penas > 3]

library(tidyverse)
```

Falas-chave: `<-` guarda um valor com um nome; `c()` junta valores; uma função recebe argumentos entre parênteses; pacote é um conjunto de funções que se instala uma vez (`install.packages`) e se carrega em cada sessão (`library`).

Dados reais (15 min), com o plano B já aqui para todos terem a mesma base. O TJSP tem dois sistemas: o e-SAJ (processos mais antigos) e o eproc (processos novos, migrados nos últimos anos). Atraso de voo rende mais no eproc, então vamos olhar os dois:

```r
esaj <- readRDS("dados/esaj_voo.rds")
eproc <- readRDS("dados/eproc_voo.rds")

glimpse(esaj)
glimpse(eproc)

acordaos <- bind_rows(
  select(esaj, sistema, processo, classe, orgao_julgador, relator, data_julgamento, ementa),
  select(eproc, sistema, processo, classe, orgao_julgador, relator, data_julgamento, ementa)
)

acordaos |>
  count(orgao_julgador, sort = TRUE)

acordaos |>
  filter(str_detect(ementa, "(?i)dano moral")) |>
  count(sistema, relator, sort = TRUE) |>
  head(5)
```

Fala-chave: o `|>` lê-se "e então". Cada linha pega o resultado da anterior. `bind_rows` empilha tabelas com colunas iguais.

Gráfico (ver `aula.R`, seção 3): barras por órgão julgador, um painel por sistema, com `ggplot` e `facet_wrap`.

Exercícios (2 a 3 min cada):

1. Quantos acórdãos há por comarca? (só o e-SAJ tem a coluna `comarca`)
2. Quantas ementas citam "companhia aérea"? (`str_detect` com `(?i)` para ignorar maiúsculas)
3. Quais câmaras aparecem nos dois sistemas?

## Bloco 4: dados judiciais (25 min)

Objetivo: ver que os pacotes `tjsp` e `datajud` trazem decisões e processos reais para dentro do R.

TJSP, jurisprudência (12 min). Aviso importante: as datas vão no formato `dd/mm/aaaa`, não `aaaa-mm-dd`.

```r
library(tjsp)

# e-SAJ: 20 acórdãos por página
dir.create("esaj", showWarnings = FALSE)

tjsp_baixar_cjsg(
  livre = "dano moral atraso voo",
  inicio = "01/01/2026",
  fim = "30/09/2026",
  n = 3,
  diretorio = "esaj"
)

esaj <- tjsp_ler_cjsg(diretorio = "esaj")

# eproc: 10 acórdãos por página
dir.create("eproc", showWarnings = FALSE)

tjsp_baixar_eproc2g_jurisprudencia(
  pesquisa = "dano moral atraso voo",
  inicio = "01/01/2026",
  fim = "30/09/2026",
  n = 6,
  diretorio = "eproc"
)

eproc <- tjsp_ler_eproc_jurisprudencia(diretorio = "eproc")
```

Testado em 22/10/2026: cada busca devolve 60 acórdãos em cerca de 10 s. Por que dois sistemas: o e-SAJ e o eproc têm sites, funções de download e leitores diferentes, e o e-SAJ não cobre os processos que já migraram. Mostre que `eproc` traz `id_jurisprudencia`, usado para baixar o inteiro teor (`tjsp_baixar_eproc_inteiro_teor`). O eproc também tem `tjsp_baixar_eproc1g_jurisprudencia`, para sentenças de 1º grau (nelas `ementa` vem vazia; o texto fica em `decisao`).

DataJud, metadados de processos (13 min):

```r
library(datajud)
set_api_key(get_default_api_key())

processos <- search_processes(
  tribunal = "tjsp",
  classe_codigo = "7",
  dataAjuizamento_start = "2025-01-01",
  dataAjuizamento_end = "2025-01-31",
  size = 100
)
```

Testado em 22/10/2026: 100 processos em cerca de 16 s. A resposta traz classe, assuntos e órgão em colunas aninhadas; para simplificar na aula, use `dados/datajud_tjsp.rds`, que já vem achatado (processo, classe, assunto, órgão, data de ajuizamento):

```r
processos <- readRDS("dados/datajud_tjsp.rds")

processos |>
  count(assunto, sort = TRUE) |>
  head(10)
```

Observação para discussão: o DataJud é uma base pública do CNJ e não traz processos sigilosos; o órgão informado é o atual.

Plano B, se a rede ou o site falhar: `readRDS("dados/esaj_voo.rds")`, `readRDS("dados/eproc_voo.rds")` e `readRDS("dados/datajud_tjsp.rds")`. Se o repositório estiver público, também funciona sem baixar nada:

```r
readRDS(url("https://raw.githubusercontent.com/jjesusfilho/curso_r_fdrp/main/dados/esaj_voo.rds"))
```

## Bloco 5: Claude Code (30 min)

Objetivo: mostrar como o Claude Code ajuda a iniciar, configurar, planejar e executar um projeto. Demonstração do professor; quem tem conta acompanha.

1. Criar o projeto (5 min). Numa pasta nova (`mkdir pesquisa_voos && cd pesquisa_voos`), abrir o terminal do Positron e rodar `claude`.
2. Configurar (5 min): rodar `/init`. Mostrar o `CLAUDE.md` gerado e acrescentar regras da turma, por exemplo:
   - escreva sempre em português;
   - use o tidyverse e o pipe nativo `|>`;
   - gráficos com ggplot2;
   - faça commit a cada tarefa concluída.
3. Planejar (8 min): entrar em plan mode (Shift+Tab até aparecer) e pedir, por exemplo: "Quero saber quais câmaras do TJSP mais concedem dano moral por atraso de voo. Use o pacote tjsp, no eproc e no e-SAJ. Monte um plano." Ler o plano em voz alta e ajustar antes de aprovar.
4. Executar (7 min): aprovar o plano, acompanhar o código criado, abrir o resultado e o gráfico.
5. Cuidados (5 min):
   - conferir o resultado, o Claude pode errar e a conta é sua;
   - não enviar dados sigilosos ou de clientes;
   - verificar toda citação de lei e jurisprudência antes de usar;
   - segredos (senhas, certificados) ficam em `~/.Renviron`, nunca no código nem no git.

Se o Claude Code falhar durante a demonstração, volte ao `aula.R` e diga que o próximo passo do curso é exatamente esse.

## Bloco 6: encerramento (10 min)

- Todo o código da aula está no `aula.R`; refaçam em casa.
- Próximos passos sugeridos: R for Data Science (em português: https://r4ds.hadley.nz) e a documentação dos pacotes `tjsp` e `datajud` no GitHub.
- Perguntas e dúvidas de instalação que sobraram.
