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

## Enumeração de Repositórios/Projetos

O UnauthScout pode, opcionalmente, enumerar **repositórios/projetos públicos** associados
a um usuário por meio da flag `--repos`.

Este recurso é **explicitamente ativado** e tem escopo definido por provedor.

### Enumerar repositórios em ambos os provedores

```bash
unauthscout torvalds --repos
```

### Enumerar apenas repositórios do GitHub

```bash
unauthscout torvalds --github --repos
```

### Enumerar apenas projetos do GitLab

```bash
unauthscout dzaporozhets --gitlab --repos
```

### Combinar com o modo raw

O modo raw pode ser usado para inspecionar as respostas originais da API:

```bash
unauthscout torvalds --repos --raw
unauthscout torvalds --github --repos --raw
```

A saída raw é útil para:

* Inspecionar campos recém-expostos
* Validar o comportamento da API
* Suportar a evolução do esquema

## Erros comuns e solução de problemas

### Ausente Dependência

**Erro**

```
[ERRO] Comando necessário ausente: jq
```

**Causa**

* Uma ou mais ferramentas necessárias não estão instaladas ou não estão no PATH.

**Solução**

Instale a dependência ausente, por exemplo:

```bash
sudo apt install jq
```

### Falha de rede ou API

**Erro**

```
[ERRO] Falha ao buscar dados do usuário do GitHub
```

ou

```
[ERRO] Falha ao buscar dados do usuário do GitLab
```

ou durante a enumeração de repositórios:

```
[ERRO] Falha ao buscar dados do repositório
```

**Possíveis causas**

* Problemas de conectividade de rede
* Interrupção temporária da API
* Limitação de taxa do provedor

**Solução**

* Verifique o acesso à rede
* Tente novamente a solicitação após um atraso
* Use `--raw` para inspecionar respostas parciais

### Falha na análise

**Erro**

```
[ERRO] Falha ao analisar a resposta da API
```

**Causa**

* Formato da resposta da API * JSON vazio ou malformado inesperado
* Incompatibilidade de ferramentas (versão do `jq`)

**Solução**

* Execute o comando novamente com `--raw`
* Compare a saída bruta com os mapeamentos da API documentada
* Valide o alinhamento do esquema em `schemas/`

### Nenhum resultado retornado (GitLab)

**Comportamento**

* Saída vazia ou erro de análise durante a busca de perfil ou projeto

**Causa**

* O endpoint `/users?username=` do GitLab retorna um array vazio
* O nome de usuário não existe ou é ambíguo
* O usuário não possui projetos públicos

**Solução**

* Verifique o nome de usuário manualmente
* Inspecione a saída bruta usando `--raw`

## Depuração com o Modo Bruto

O UnauthScout fornece um parâmetro `--raw` para ignorar a normalização:

```bash
unauthscout <nome de usuário> --raw
unauthscout <nome de usuário> --github --raw
unauthscout <nome de usuário> --repos --raw

```

Use o modo raw para:

* Inspecionar campos recém-expostos
* Validar o comportamento da API
* Auxiliar na evolução do esquema

O modo raw destina-se à **análise e desenvolvimento**, não à automação.

## Comportamento de saída esperado

* A execução bem-sucedida retorna o código de saída `0`
* Erros fatais encerram a execução com um código de saída diferente de zero
* Todos os erros são impressos no stderr com uma mensagem clara

## Observações sobre limitação de taxa

O UnauthScout não tenta burlar os limites de taxa.

* As requisições não autenticadas do GitHub têm limite de taxa.
* As requisições não autenticadas do GitLab também podem ter sua taxa de requisições limitada.

Para uso contínuo, considere:

* Espaçamento entre as requisições
* Limitar o escopo do provedor (`--github` / `--gitlab`)
* Adicionar suporte a autenticação em uma versão futura

## Resumo

O UnauthScout foi projetado para falhar de forma rápida e visível.

Se algo quebrar:

1. Verifique as dependências
2. Execute novamente com `--raw`
3. Compare a saída bruta com a documentação de mapeamento da API
4. Atualize os esquemas e analisadores sintáticos de acordo
