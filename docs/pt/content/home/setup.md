# Configuração e resolução de problemas

Este documento descreve como configurar o UnauthScout, suas dependências de tempo de execução
e como resolver erros comuns durante a execução.

Requisitos

O UnauthScout é intencionalmente leve e depende apenas de ferramentas CLI padrão.

### Dependências necessárias

- **bash** (compatível com POSIX)
- **curl** — cliente HTTP para solicitações de API
- **jq** — análise e normalização de JSON

### Verificar dependências

Você pode verificar manualmente as ferramentas necessárias:

```bash
bash --version
curl --version
jq --version
````

Se algum comando estiver faltando, instale-o usando o gerenciador de pacotes do seu sistema.

## Instalação

```bash
git clone https://github.com/rmottanet/unauthscout.git
cd unauthscout
chmod +x bin/unauthscout
```

Opcionalmente, adicione o binário ao seu PATH:

```bash
export PATH="$PWD/bin:$PATH"
```

## Verificação Básica de Sanidade

Execute uma pesquisa simples sem autenticação:

```bash
unauthscout torvalds
```

Comportamento esperado:

* Saída JSON
* Sem solicitações de autenticação
* Sem rastreamentos de pilha ou erros de shell

## Erros comuns e solução de problemas

### Dependência ausente

**Erro**

```
[ERROR] Missing required command: jq
```

**Causa**

* Uma ou mais ferramentas necessárias não estão instaladas ou não estão no PATH.

**Solução**
Instale a dependência ausente, por exemplo:

```bash
sudo apt install jq
```

### Falha na rede ou na API

**Erro**

```
[ERROR] Failed to fetch GitHub user data
```

ou

```
[ERROR] Failed to fetch GitLab user data
```

**Possíveis causas**

* Problemas de conectividade de rede
* Interrupção temporária da API
* Limitação de taxa pelo provedor

**Solução**

* Verifique o acesso à rede
* Tente novamente a solicitação
* Use `--raw` para inspecionar respostas parciais, se disponíveis

### Falha na análise

**Erro**

```
[ERROR] Failed to parse API response
```

**Causa**

* Formato de resposta da API alterado
* JSON vazio ou malformado inesperado
* Incompatibilidade de ferramentas (versão `jq`)

**Resolução**

* Execute novamente o comando com `--raw`
* Compare a saída bruta com o mapeamento da API documentado
* Valide o alinhamento do esquema

### Nenhum resultado retornado (GitLab)

**Comportamento**

* Saída vazia ou erro de análise

**Causa**

* O endpoint GitLab `/users?username=` retorna uma matriz vazia
* O nome de usuário não existe ou é ambíguo

**Resolução**

* Verifique o nome de usuário manualmente
* Inspecione a saída bruta usando `--raw`

## Depuração com o modo bruto

O UnauthScout fornece um sinalizador `--raw` para ignorar a normalização:

```bash
unauthscout <username> --raw
unauthscout <username> --raw -gh
```

Use o modo bruto para:

* Inspecionar campos recém-expostos
* Validar o comportamento da API
* Auxiliar na evolução do esquema

O modo bruto destina-se à **análise e desenvolvimento**, não à automação.

## Comportamento esperado de saída

* A execução bem-sucedida retorna o código de saída `0`
* Erros fatais encerram a execução com um código de saída diferente de zero
* Todos os erros são impressos no stderr com uma mensagem clara

## Observações sobre limitação de taxa

O UnauthScout não tenta contornar os limites de taxa.

* As solicitações não autenticadas do GitHub têm taxa limitada
* As solicitações não autenticadas do GitLab também podem ser limitadas

Para uso contínuo, considere:

* Espaçar as solicitações
* Adicionar suporte autenticado em uma versão futura

## Resumo

O UnauthScout foi projetado para falhar de forma rápida e visível.

Se algo der errado:

1. Verifique as dependências
2. Execute novamente com `--raw`
3. Compare a saída bruta com os documentos de mapeamento da API
4. Atualize os esquemas e analisadores de acordo
