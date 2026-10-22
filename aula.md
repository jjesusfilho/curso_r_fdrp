# Introdução ao R para estudantes de direito

Faculdade de Direito de Ribeirão Preto (FDRP/USP)

Material da aula: https://github.com/jjesusfilho/curso_r_fdrp

---

## O que vamos fazer hoje

| Parte | Tema | Tempo |
|---|---|---|
| 1 | Instalar R e Positron | 20 min |
| 2 | Conhecer o Positron | 10 min |
| 3 | Primeiros passos em R | 25 min |
| 4 | Decisões e processos reais do TJSP | 25 min |
| 5 | Trabalhar com o Claude Code | 30 min |
| 6 | Fechamento | 10 min |

---

## Por que R no direito?

- O direito produz texto e decisões em grande quantidade.
- Ler uma a uma não mostra padrões; contar e comparar mostra.
- Jurimetria é o estudo empírico do direito: o que se decide, quanto tempo leva, de que depende.
- Hoje o objetivo é perder o medo e sair com um caminho.

---

## 1. Instalação

Nesta ordem:

1. R: https://cloud.r-project.org (escolha o seu sistema operacional)
2. Positron: https://positron.posit.co/download.html
3. Claude Code (opcional, só para quem tem conta): https://docs.claude.com/claude-code

Dicas:

- No Mac, escolha a versão certa (Apple Silicon ou Intel).
- No Windows sem permissão de administrador, instale só para o seu usuário.
- Não conseguiu instalar? Acompanhe junto com um colega.

---

## 2. O Positron

- Editor: onde escrevemos o script (o que fica guardado)
- Console: onde o R responde (rascunho)
- Variáveis e arquivos: ao lado
- Gráficos: aparecem à direita

Para executar uma linha: `Ctrl + Enter` (no Mac, `Cmd + Enter`).

Passos:

1. File > Open Folder e escolha uma pasta para o curso
2. Crie um arquivo chamado `minha_aula.R`
3. Instale os pacotes (leva alguns minutos, deixe rodando):

```r
install.packages(c("tidyverse", "remotes"))
remotes::install_github("jjesusfilho/tjsp")
remotes::install_github("jjesusfilho/datajud")
```

Se perguntar sobre atualizar outros pacotes, responda `3` (nenhum).

---

## 3. Primeiros passos em R

R funciona como uma calculadora:

```r
2 + 2
```

Guardamos valores em objetos com `<-`:

```r
pena <- 6
pena * 2
```

`c()` junta vários valores num vetor:

```r
penas <- c(2, 4, 6, 8)
mean(penas)
penas[penas > 3]
```

Pacotes são conjuntos de funções. Instalamos uma vez e carregamos em cada sessão:

```r
library(tidyverse)
```

---

## O pipe: `|>`

Lê-se "e então". Cada linha pega o resultado da anterior.

```r
penas |>
  sort() |>
  rev()
```

Equivale a `rev(sort(penas))`, mas na ordem em que pensamos.

---

## Dois sistemas, uma pergunta

O TJSP tem dois sistemas de processo eletrônico:

- e-SAJ: processos mais antigos
- eproc: processos novos (a migração segue em curso)

Pergunta: **quais câmaras decidem casos de dano moral por atraso de voo?**

Vamos usar uma base já pronta (acórdãos de setembro de 2026):

```r
esaj <- readRDS("dados/esaj_voo.rds")
eproc <- readRDS("dados/eproc_voo.rds")

glimpse(esaj)
glimpse(eproc)
```

---

## Juntando os dois sistemas

```r
acordaos <- bind_rows(
  select(esaj, sistema, processo, classe, orgao_julgador, relator, data_julgamento, ementa),
  select(eproc, sistema, processo, classe, orgao_julgador, relator, data_julgamento, ementa)
)
```

`select()` escolhe colunas; `bind_rows()` empilha as tabelas.

---

## Contando

```r
acordaos |>
  count(sistema)

acordaos |>
  count(orgao_julgador, sort = TRUE)
```

Filtrando ementas que falam em dano moral:

```r
acordaos |>
  filter(str_detect(ementa, "(?i)dano moral")) |>
  count(sistema, relator, sort = TRUE) |>
  head(5)
```

`(?i)` faz a busca ignorar maiúsculas.

---

## Exercícios

1. Quantos acórdãos há por comarca? (só o `esaj` tem a coluna `comarca`)
2. Quantas ementas citam "companhia aérea"?
3. Quais câmaras aparecem nos dois sistemas?

---

## Um gráfico

```r
acordaos |>
  count(sistema, orgao_julgador) |>
  group_by(sistema) |>
  slice_max(n, n = 6) |>
  ggplot(aes(x = n, y = reorder(orgao_julgador, n))) +
  geom_col() +
  facet_wrap(~ sistema, scales = "free_y") +
  labs(x = "Acórdãos", y = NULL)
```

---

## 4. Baixando dados direto do TJSP

Pacote `tjsp`. As datas vão no formato `dd/mm/aaaa`.

e-SAJ (20 acórdãos por página):

```r
library(tjsp)

dir.create("esaj", showWarnings = FALSE)

tjsp_baixar_cjsg(
  livre = "dano moral atraso voo",
  inicio = "01/09/2026",
  fim = "30/09/2026",
  n = 3,
  diretorio = "esaj"
)

esaj <- tjsp_ler_cjsg(diretorio = "esaj")
```

---

## eproc

O eproc traz 10 acórdãos por página:

```r
dir.create("eproc", showWarnings = FALSE)

tjsp_baixar_eproc2g_jurisprudencia(
  pesquisa = "dano moral atraso voo",
  inicio = "01/09/2026",
  fim = "30/09/2026",
  n = 6,
  diretorio = "eproc"
)

eproc <- tjsp_ler_eproc_jurisprudencia(diretorio = "eproc")
```

O pacote trabalha em duas etapas: primeiro baixa os arquivos para a pasta, depois lê. Como os arquivos ficam na pasta, dá para ler de novo sem baixar outra vez.

---

## DataJud: metadados de processos

O DataJud é a base pública do CNJ. Ela traz classe, assunto, órgão e datas, não o texto das decisões.

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

Pode levar de 15 a 60 segundos. Para a aula, usamos uma versão já tratada:

```r
processos <- readRDS("dados/datajud_tjsp.rds")

processos |>
  count(assunto, sort = TRUE) |>
  head(10)
```

---

## 5. Claude Code

Um assistente que trabalha dentro da sua pasta de projeto: lê arquivos, escreve código, roda e corrige.

Demonstração:

1. Criar uma pasta nova e abrir o terminal do Positron
2. Rodar `claude`
3. Rodar `/init` para criar o `CLAUDE.md`, com as regras do projeto
4. Planejar antes de executar (plan mode)
5. Aprovar o plano e acompanhar a execução

---

## O CLAUDE.md

Arquivo de instruções que o Claude lê toda vez. Exemplo:

```markdown
## Preferências

- Escreva sempre em português
- Use o tidyverse e o pipe nativo `|>`
- Gráficos com ggplot2
- Faça commit a cada tarefa concluída
```

---

## Pedindo um plano

Exemplo de pedido:

> Quero saber quais câmaras do TJSP mais decidem dano moral por atraso de voo. Use o pacote tjsp, no eproc e no e-SAJ. Monte um plano.

Leia o plano antes de aprovar. Ajuste o que não estiver certo.

---

## Cuidados

- Confira o resultado: o Claude pode errar, e a responsabilidade é sua
- Não envie dados sigilosos nem de clientes
- Verifique toda citação de lei e jurisprudência antes de usar
- Senhas e certificados nunca vão no código nem no git

---

## 6. Para continuar

- Todo o código da aula está em `aula.R`, no repositório
- R for Data Science (em português): https://r4ds.hadley.nz
- Pacotes: https://github.com/jjesusfilho/tjsp e https://github.com/jjesusfilho/datajud

Dúvidas?
