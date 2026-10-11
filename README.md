# Canary

[![Discord](https://img.shields.io/discord/528117503952551936.svg?style=flat-square&logo=discord)](https://discord.gg/gvTj5sh9Mp)
[![CI](https://github.com/opentibiabr/canary/actions/workflows/ci.yml/badge.svg)](https://github.com/opentibiabr/canary/actions/workflows/ci.yml)
[![Status da análise de qualidade](https://sonarcloud.io/api/project_badges/measure?project=opentibiabr_canary&metric=alert_status)](https://sonarcloud.io/dashboard?id=opentibiabr_canary)
![Tamanho do repositório](https://img.shields.io/github/repo-size/opentibiabr/canary)
[![Licença](https://img.shields.io/github/license/opentibiabr/canary.svg)](https://github.com/opentibiabr/canary/blob/main/LICENSE)

Canary é um emulador de servidor MMORPG gratuito e de código aberto para a comunidade OpenTibia, escrito em C++20 e Lua. O projeto deriva do [OTServBR-Global](https://github.com/opentibiabr/otservbr-global). O repositório inclui o núcleo do servidor, datapacks, scripts Lua, esquema do banco de dados, presets de compilação, testes automatizados e ferramentas de desenvolvimento usadas pelo projeto.

---

## Primeiros passos

- [Wiki](https://github.com/opentibiabr/canary/wiki).
- [Histórico de alterações deste repositório](CHANGELOG.md).

---

## Início rápido com Docker

Canary inclui uma configuração simplificada com Docker para executar um servidor
de testes local sem precisar compilar o Canary na sua máquina. O ambiente inicia
o MariaDB, a imagem publicada do Canary, o MyAAC como site e painel administrativo
de contas (AAC) e o `opentibiabr/login-server` como serviço web de login do cliente.

Essa configuração é destinada ao desenvolvimento local, aos testes e às
demonstrações em rede local. Não a exponha diretamente à internet com as contas
e senhas de teste padrão.

Execute a partir do diretório `docker`:

```bash
cp .env.dist .env
docker compose up -d --build
```

O diretório `docker` também fornece scripts que iniciam o ambiente e limpam
resíduos seguros do Docker sem remover os volumes do banco de dados:

```powershell
.\up.ps1
```

```bash
sh ./up.sh
```

Endereços e porta locais padrão:

- Site e painel administrativo: `http://localhost:8080`
- Serviço web de login do cliente: `http://localhost:8088/login`
- Porta do jogo: `7172`

O `login.php` do MyAAC foi removido intencionalmente da imagem de início rápido.
Os clientes devem usar apenas o `login-server`. Consulte o
[guia para iniciantes](docs/docker/quickstart-for-beginners.md) e a
[documentação completa do Docker](docker/DOCKER.md) para conhecer a configuração,
as variáveis de ambiente, a conta de teste e as orientações para resolver problemas.

---

## Documentação

- [Recompilação no Linux com backups do executável](docs/building/recompile.md).
  Inclui retenção de sete dias, análise de falhas, reinício opcional e testes no WSL.
- [Dimensionamento de hardware e planejamento de capacidade](docs/hardware-sizing.md).
  Explica como medir RAM e CPU, comparar cargas de treino e caça e avaliar a capacidade.
- [Cache de compilação compartilhado entre worktrees e forks](docs/development/shared-build-cache.md).
- [Início rápido com Docker para iniciantes](docs/docker/quickstart-for-beginners.md).
- [Perfis de execução multiprotocolo](docs/systems/multiprotocol.md).
  Descreve os contratos de execução do protocolo atual, 11.00 e 8.60, a organização
  das portas, a preparação dos clientes e as verificações de validação.
- [Documentação dos sistemas](docs/systems/README.md).
- [Loot premium por monstro](docs/systems/premium-loot.md).
- [Referência da API Lua e definições para IntelliSense no VSCode](docs/lua-api/lua_api.md).
  O Canary gera esses arquivos a partir dos vínculos Lua do C++ durante a
  inicialização, quando `generateLuaApiDocs` está habilitado. O `.luarc.json` do
  repositório já adiciona `docs/lua-api` à biblioteca do Lua Language Server.
  Para configurar o workspace do VSCode, execute `tools/setup_vscode_lua_api.ps1`.

---

## Loot premium por monstro

Configure `monster.lootpremium` no arquivo Lua do monstro para adicionar uma
bonificação separada, mantendo `monster.loot` como loot normal:

```lua
monster.lootpremium = {
    { name = "gold coin", chance = 100000, minCount = 5, maxCount = 10 },
}
```

O sorteio premium acontece uma única vez. Em uma party, os itens são divididos
entre os membros premium elegíveis, incluindo o líder. Os itens permanecem no
corpo do monstro, reservados ao destinatário até a coleta. As mensagens normal e
premium seguem o mesmo fluxo no C++, usando os tipos 31 e 59, respectivamente.
O cliente precisa reconhecer o tipo 59 para apresentar o aviso premium separado.

Consulte a [documentação do sistema](docs/systems/premium-loot.md) para conhecer
as regras de distribuição, as verificações de acesso e os testes de validação.

---

## Ferramentas e clientes recomendados

- [Assets Editor](https://github.com/Arch-Mina/Assets-Editor).
  Use-o como fonte única dos assets e exporte pacotes `.dat`/`.spr` compatíveis
  com clientes 8.60 a partir do mesmo conjunto atual de assets.
- [Remere's Map Editor](https://github.com/opentibiabr/remeres-map-editor/).
- [OTClient Redemption](https://github.com/opentibiabr/otclient).
- [Tibia Extended Client Library](https://github.com/dudantas/Tibia-Extended-Client-Library).
  Use-a para preparar clientes CipSoft 8.60/11.00 compatíveis, com limites
  ampliados, redirecionamento de login por configuração e estado local por cliente.
- [Cliente do jogo](https://github.com/dudantas/tibia-client/releases/latest).

---

## Compilações de desenvolvimento

As compilações de desenvolvimento podem ser baixadas nos artefatos do GitHub
Actions. Elas ajudam a testar as mudanças recentes da branch `main`, mas podem
incluir comportamentos ainda ausentes nas versões estáveis.

- [GitHub Actions](https://github.com/opentibiabr/canary/actions/workflows/ci.yml?query=branch%3Amain).

---

## Execução dos testes

Os testes podem ser executados a partir da raiz do repositório, usando as versões
das ferramentas e as tarefas fixadas no `.mise.toml`:

```bash
mise install
mise run configure linux-debug
mise run build linux-debug
mise run test linux-debug

# Substitua linux-debug por macos-debug ou windows-debug conforme necessário.
```

Para informações sobre a criação de testes e o uso do framework, consulte a
[documentação dos testes](tests/README.md).

O teste Lua isolado do loot premium pode ser executado a partir da raiz com:

```bash
python3 tests/lua/run_premium_loot.py
```

Esse teste usa objetos simulados e não substitui a compilação do C++ nem a
validação dentro do jogo.

---

## Suporte e comunidade

Para suporte em tempo real, participe do
[Discord da OpenTibiaBR](https://discord.gg/gvTj5sh9Mp).

As issues do GitHub devem ser usadas para relatar bugs, propor melhorias e
acompanhar tarefas técnicas do projeto. Elas não são um fórum de suporte.

---

## Como contribuir

Contribuições são bem-vindas. Você pode ajudar de várias formas:

- Relatar bugs pelo [rastreador de issues](https://github.com/opentibiabr/canary/issues/new/choose).
- Enviar melhorias por [pull requests](https://github.com/opentibiabr/canary/pulls).
- Melhorar testes, documentação, scripts, datapacks ou código C++.
- Validar versões estáveis, compilações de desenvolvimento e alterações recentes.

Antes de contribuir, leia o
[Código de Conduta](https://github.com/opentibiabr/canary/blob/main/CODE_OF_CONDUCT.md)
e o [guia de contribuição](https://github.com/opentibiabr/canary/blob/main/CONTRIBUTING.md).

---

## Apoio ao projeto

Canary é mantido por colaboradores da comunidade. Para apoiar o desenvolvimento,
visite a [página de patrocínio da OpenTibiaBR](https://github.com/sponsors/opentibiabr).

---

## Agradecimentos

Agradecemos a todos os colaboradores do
[Canary](https://github.com/opentibiabr/canary/graphs/contributors), do
[OTServBR-Global](https://github.com/opentibiabr/otservbr-global/graphs/contributors)
e da comunidade OpenTibia.

---

## Licença

Este projeto é distribuído sob a
[licença GPL-2.0](https://github.com/opentibiabr/canary/blob/main/LICENSE).
