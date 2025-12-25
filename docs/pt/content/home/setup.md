# Configuração e Solução de Problemas

Este documento descreve como configurar o UnauthScout, verificar suas dependências de tempo de execução
e realizar testes básicos de sanidade. Para obter instruções e exemplos de uso completos,
consulte o [Guia de Uso](./usage) separado.

## Objetivo

Este guia garante que você possa instalar o UnauthScout com sucesso e executar uma operação básica de reconhecimento.
Ele se concentra na **configuração do ambiente** e na **validação inicial**, e não em fluxos de trabalho operacionais.

## Requisitos

O UnauthScout foi projetado para ser leve e depende apenas de ferramentas de linha de comando padrão
disponíveis na maioria dos sistemas do tipo Unix.

### Dependências necessárias

- **bash** (shell compatível com POSIX, versão 4.0+)
- **curl** (7.0+) — Cliente HTTP para requisições de API
- **jq** (1.6+) — Análise e normalização de JSON

### Verificar dependências

Você pode verificar manualmente as ferramentas necessárias:

```bash
bash --version | head -1
curl --version | head -1
jq --version
```

Se algum comando estiver faltando ou reportar uma versão incompatível, instale ou atualize-o
usando o gerenciador de pacotes do seu sistema.

### Comandos de instalação específicos da plataforma

| Plataforma | Comando |

|----------|---------|

| Ubuntu/Debian | `sudo apt update && sudo apt install curl jq` |

| Fedora/RHEL | `sudo dnf install curl jq` |

| macOS (Homebrew) | `brew install curl jq` |

| Alpine Linux | `apk add curl jq` |

## Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/rmottanet/unauthscout.git
cd unauthscout
```

### 2. Torne o binário executável

```bash
chmod +x bin/unauthscout
```

### 3. (Opcional) Adicione ao seu PATH

Para acesso temporário:

```bash
export PATH="$PWD/bin:$PATH"
```

Para acesso permanente, adicione a linha ao seu perfil do shell (`~/.bashrc`, `~/.zshrc`,
etc.) ou crie um link simbólico:

```bash
sudo ln -s "$PWD/bin/unauthscout" /usr/local/bin/unauthscout
```

## Verificação básica

Após a instalação, verifique o A ferramenta funciona corretamente com uma simples busca não autenticada de uma figura pública conhecida:

```bash
./bin/unauthscout torvalds
```

**Comportamento esperado:**

* Saída JSON (compacta ou formatada, dependendo do modo padrão)
* Sem solicitações de autenticação ou requisitos de token
* Sem rastreamentos de pilha, erros de shell ou problemas de permissão
* Identificação clara da plataforma na saída

**Características de saída esperadas:**

* Código de saída `0`
* Saída para stdout (não stderr)
* JSON estruturado em conformidade com o esquema unificado
* Informações do perfil do usuário Linus Torvalds no GitHub

## Solução de problemas na configuração inicial

### Erro de dependência ausente

**Erro**

```
[ERRO] Dependência não encontrada: jq. Por favor, instale-a para continuar.

```

**Causa**

Uma ou mais ferramentas necessárias não estão instaladas ou não estão no PATH. **Solução**

Instale a dependência ausente usando o gerenciador de pacotes do seu sistema (consulte a tabela acima).

### Erro de permissão negada

**Erro**

```bash
 ./bin/unauthscout: Permissão negada
```

**Causa**

O binário não possui permissões de execução.

**Solução**

```bash
chmod +x bin/unauthscout
```

### Erro de comando não encontrado

**Erro**

```
unauthscout: comando não encontrado
```

**Causa**

O binário não está no seu PATH.

**Solução**

Uma das opções:
1. Use o caminho completo: `./bin/unauthscout`
2. Adicione ao PATH conforme descrito na seção Instalação
3. Crie um link simbólico para um diretório no seu PATH

### Problemas de conectividade de rede

**Erro**

```
[ERRO] Falha ao buscar dados do usuário do GitHub
[ERRO] Falha ao buscar dados do usuário do GitLab
```

**Possíveis causas**

* Sem conexão com a internet
* Falha na resolução de DNS
* Firewall corporativo bloqueando endpoints da API

**Solução**

* Verifique a conectividade de rede: `curl -s https://api.github.com`
* Teste os endpoints da API diretamente:

```bash

curl -s "https://api.github.com/users/torvalds" | jq .login

curl -s "https://gitlab.com/api/v4/users?username=dzaporozhets" | jq .[0].username

```

## Verificando a versão

Após a instalação, verifique se você está executando a versão esperada:

```bash
./bin/unauthscout --version
```

Formato de saída esperado: `UnauthScout vX.X.X`

## Comportamento de saída esperado

* **Execução bem-sucedida**: Código de saída `0`
* **Erros fatais**: Código de saída diferente de zero com mensagem de erro descritiva no stderr
* **Erros do usuário** (por exemplo, nome de usuário ausente): Código de saída `1` com texto de ajuda

## Próximos passos

Após executar com sucesso a verificação básica, consulte o
[Guia de Uso](./usage) para obter instruções detalhadas sobre:

* Reconhecimento específico da plataforma (`--github`, `--gitlab`)
* Enumeração de repositórios (`--repos`)
* Sumarização de inteligência (`--summarize`)
* Opções de formatação de saída (`--raw`, `--pretty`)
* Fluxos de trabalho avançados e exemplos

## Resumo

O UnauthScout foi projetado para ter requisitos mínimos de configuração e falhar visivelmente quando
os requisitos não forem atendidos. Um teste bem-sucedido com `./bin/unauthscout torvalds` confirma
que seu ambiente está configurado corretamente para todas as operações de reconhecimento.
