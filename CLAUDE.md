# CLAUDE.md

## Git: commit e push

- Ao concluir cada tarefa lógica (uma unidade coesa de mudança), faça `git commit` e `git push` imediatamente, sem esperar novo pedido
- Não acumule mudanças não relacionadas no mesmo commit; cada commit deve representar uma única alteração lógica
- Antes de commitar, confira com `git status` e `git diff` o que entra; não inclua arquivos temporários, dados sensíveis ou credenciais
- Mensagens seguem a convenção Conventional Commits, usada no GitHub:
  - formato: `<tipo>(<escopo opcional>): <descrição curta>`
  - tipos: `feat` (nova funcionalidade), `fix` (correção), `docs` (documentação), `refactor` (refatoração sem mudança de comportamento), `test` (testes), `chore` (manutenção, configuração, dependências), `perf` (desempenho), `style` (formatação)
  - descrição em português, no imperativo, com até ~72 caracteres, sem ponto final (ex.: `feat(coleta): adiciona download das decisões`)
  - se necessário, deixe uma linha em branco e detalhe o porquê da mudança no corpo da mensagem
  - mudanças incompatíveis: use `!` após o tipo (`feat!:`) ou o rodapé `BREAKING CHANGE:`
- Se o push falhar (conflito, branch remota à frente), faça `git pull --rebase`, resolva e tente de novo; nunca use `push --force` sem autorização explícita


### Primeiras linhas

Eu vou dar um curso introdutório de R para estudantes de direito. O curso durará apenas duas horas. Eu tenho o pacote tjsp e o pacote datajud no meu github. Os alunos não tem familiaridade com R. Eu pensei em dar uma visao geral sobre o positron, evetualmente o uso desses pacotes e o queria incentivar o uso do claude code para trabalhar com projetos. Por exemplo, mostrar como iniciar um projeto, configurá-lo e deixar pronto. Eventualmente, mostrar como usar o claude code para planejar e executar o projeto.

Vc (claude) também pode dar sugestões.