# Histórico de alterações

Este arquivo registra as alterações próprias deste repositório, incluindo a
autenticação pelo Discord e o loot premium. Não reproduz o histórico completo
do projeto Canary.

## [Não lançado] — 2026-10-11

### Autenticação e controle de acesso pelo Discord

- Integração da conta do jogo com a identidade Discord por `accounts.discord_id`.
  O servidor valida a autorização sincronizada pelo bot em `discord_game_access`,
  conferindo a identidade vinculada, o servidor Discord, o cargo exigido e o
  prazo de validade da autorização.
- Política de acesso configurável em `discord-access.json`, com ativação do
  controle, servidor, cargo, mensagem de recusa, convite e endereço da conta no site.
- Verificação de acesso tanto na listagem de personagens (`ProtocolLogin`)
  quanto na entrada no mundo (`ProtocolGame`), usando `IOLoginData::getDiscordAccessError`.
- Orientações de recusa para vincular a conta pelo site e pelo painel existente
  **Liberar ID**, ou aguardar a sincronização do bot quando o jogador já possui
  o cargo necessário.
- Opção `requireDesktopIdentity` para exigir autenticação da identidade Discord
  pelo cliente compatível, recusando o login convencional quando essa exigência
  está ativa.
- Suporte a tickets de login recebidos pela chave de sessão com prefixo
  `@discord:`. O ticket tem formato hexadecimal de 32 caracteres; o servidor
  consulta seu hash SHA-256 em `discord_login_tickets` e verifica a expiração,
  o vínculo Discord, a conta e a propriedade do personagem.
- Validação do ticket antes do agendamento do login e nova validação na admissão
  do personagem. O consumo é transacional, com bloqueio da linha e exclusão do
  ticket, impedindo sua reutilização após a admissão.
- Recusa do acesso quando a política exigida está indisponível ou inválida,
  em vez de desabilitar silenciosamente a verificação de identidade.
- Bloqueio da visualização pública por `@livestream` enquanto a identidade
  Discord é obrigatória.
- Essas integrações já constam no histórico do repositório; esta entrada também
  documenta o trabalho anterior ao loot premium. O bot e o site são componentes
  externos, responsáveis pelo vínculo, pela emissão de tickets e pela sincronização
  das autorizações conforme seu próprio fluxo.

### Webhooks Discord — em implementação

- Adicionada a configuração opcional `discordWebhookURL2`, com valor padrão
  vazio, e sua constante `DISCORD_WEBHOOK_URL2` no gerenciador de configurações.
- As duas versões C++ de `Webhook::sendMessage` recebem uma segunda URL
  opcional, consultam a configuração quando o argumento está vazio e encaminham
  ambos os destinos para `sendPayload`.
- A declaração e a implementação de `sendPayload` passam a receber `url2`.
  As chamadas existentes continuam válidas por meio dos argumentos padrão
  declarados no cabeçalho.
- O fluxo mantém a necessidade de um destino primário: uma chamada sem URL
  explícita e sem `discordWebhookURL` preenchida retorna antes de entrar na fila.
- **Pendente:** criar a segunda tarefa em `sendPayload` quando `url2` estiver
  preenchida e for diferente da primeira URL. Na revisão dos fontes, a função
  ainda enfileira apenas o destino original; o envio duplo não está concluído.
- A finalidade da segunda URL é espelhar também os logs Lua que passam pelo
  emissor C++ com um destino específico. A compilação e a confirmação dos dois
  envios em execução ainda precisam ser realizadas após concluir a função.

### Loot premium — adicionado

- Bonificação por monstro configurável com `monster.lootpremium`, separada de
  `monster.loot`.
- Fluxo de cadastro Lua/C++ com `createLootPremium`, `addLootPremium`,
  `getLootPremium`, `loadLootPremium` e armazenamento em `lootPremiumItems`.
- Um único sorteio premium por morte, seguido de divisão entre os membros
  premium elegíveis da party, incluindo o líder. A elegibilidade também exige
  `canReceiveLoot()`; não há filtro adicional de distância, participação no
  combate ou experiência compartilhada.
- Reserva dos itens no corpo pelo GUID do destinatário, usando o atributo
  `premium_loot_owner`.
- Tipo `MESSAGE_LOOT_PREMIUM = 59`, registrado para Lua e enviado ao cliente
  compatível. Protocolos antigos usam a adaptação para mensagem de loot normal.
- Configuração premium no Mountain Troll do datapack OTServBR-Global, com
  platinum coins (ID 3035, até 2 unidades) e small health potion (ID 7876),
  ambos com `chance = 33000`.
- Documentação do sistema em `docs/systems/premium-loot.md` e referência dos
  métodos premium nos arquivos gerados da API Lua.
- Suíte Lua isolada com 15 cenários de cadastro, sorteio, divisão, itens com
  cargas, entradas repetidas, recipientes aninhados, falhas de criação/inserção
  e ausência dos métodos premium no executável antigo.

### Alterado

- Mensagens normal e premium montadas em `Creature::dropCorpse`, a partir dos
  itens efetivamente presentes no corpo, e enviadas por `Player::sendLootMessage`.
  O callback Lua fica responsável por sortear e criar os itens.
- A descrição normal exclui itens premium reservados. A descrição premium
  seleciona apenas os itens do GUID destinatário e não gera aviso para uma
  parte vazia.
- O aviso normal mantém o envio para a party; o premium é individual, evitando
  divulgar ou repetir a bonificação dos outros membros.
- Textos de loot com marcações de cor para título e nome do monstro. As descrições
  mantêm `{itemId|descrição}`, interpretado pelo cliente para aplicar as cores dos itens.
- README traduzido para português, com atalhos para o changelog, a documentação
  do loot premium e seu teste Lua isolado.

### Corrigido

- Verificação de acesso aos itens premium na movimentação, troca de posições,
  autoloot/autobank, uso direto, ações sobre alvos e Stow.
- Verificação de ancestrais e descendentes de recipientes para impedir a coleta
  ou o consumo de itens reservados a outro jogador, permitindo abrir o corpo
  compartilhado.
- Liberação da reserva após coleta bem-sucedida no inventário do destinatário,
  permitindo a troca normal do item depois da coleta.
- Preservação de cargas e entradas do mesmo ID com atributos diferentes no
  sorteio premium, além do cadastro e sorteio recursivo dos itens filhos.
- Leitura de filhos `Loot` com o acesso correspondente ao userdata compartilhado.
- Proteções Lua para ignorar a configuração e o sorteio premium quando o
  executável ainda não oferece os métodos necessários.

### Validação

- O fluxo Discord foi conferido nos fontes `src/io/iologindata.cpp`,
  `src/server/network/protocol/protocollogin.cpp` e
  `src/server/network/protocol/protocolgame.cpp`. Na configuração consultada
  durante esta revisão, `enabled = true` e `requireDesktopIdentity = false`.
  Essa conferência não constitui um novo teste de login em execução.
- Os 15 cenários Lua passaram após a unificação do fluxo de mensagens.
- A suíte usa objetos simulados; não valida a compilação C++, o protocolo em
  execução nem o comportamento dentro do jogo.
- A compilação e os testes no jogo ficam a cargo do mantenedor. Não há resultado
  de teste em jogo registrado nesta entrada.
