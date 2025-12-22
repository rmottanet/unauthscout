# Fluxo OSINT

Este documento descreve o **modelo mental e o fluxo operacional** por trás do
UnauthScout. Ele explica *como* e *por que* a ferramenta realiza o reconhecimento,
independentemente de qualquer implementação específica do provedor.


## Objetivo

O UnauthScout foi projetado para realizar **reconhecimento não autenticado** em plataformas públicas
de desenvolvedores de maneira previsível, auditável e fácil de automatizar.

O objetivo não é a exaustão de dados, mas a **extração de sinais**:
- A entidade existe?
- Onde ela está exposta publicamente?
- Qual é a superfície observável sem credenciais?


## Premissas básicas

- As APIs públicas expõem dados de reconhecimento significativos sem autenticação
- Esses dados são suficientes para OSINT e criação de perfis em estágio inicial
- A normalização é necessária para tornar os dados comparáveis entre os provedores
- Os contratos devem refletir a **realidade observável**, não a capacidade teórica da API


## Fluxo Geral

```txt
Destino
↓
Seleção do Provedor
↓
Requisição de API Não Autenticada
↓
Resposta Bruta
↓
Normalização (Esquema)
↓
Saída Estruturada
````

Cada etapa tem uma **única responsabilidade** e um limite claramente definido.

## Detalhamento Passo a Passo

### 1. Identificação do Destino

O usuário fornece um identificador de destino (por exemplo, nome de usuário).

O UnauthScout não:

* Tenta adivinhar identidades
* Correlaciona entre plataformas
* Realiza enriquecimento nesta etapa

O destino é tratado como um identificador opaco passado para o provedor.

### 2. Seleção do Provedor

A CLI determina qual módulo do provedor invocar (por exemplo, GitHub, GitLab).

Responsabilidades:

* Roteamento
* Manipulação de flags (`--raw`, `--repos`)
* Propagação de erros

O ponto de entrada **não implementa lógica de reconhecimento**.

### 3. Requisição de API não autenticada

Cada módulo provedor realiza:

* Uma requisição direta à API pública
* Sem autenticação
* Sem novas tentativas ou evasão de limite de taxa

Isso garante:

* Uso ético
* Reprodutibilidade
* Limites de confiança claros

### 4. Manipulação de Resposta Bruta

A resposta bruta da API representa a **verdade fundamental**.

O UnauthScout suporta um modo `--raw` para:

* Inspecionar campos disponíveis
* Validar suposições
* Auxiliar na evolução do esquema

A saída bruta destina-se à **análise e desenvolvimento**, não à automação.

### 5. Normalização

A normalização transforma as respostas brutas em um **contrato mínimo e estável**.

Princípios:

* Incluir apenas campos que estejam sempre disponíveis
* Evitar campos voláteis ou internos ao provedor
* Dar preferência a identificadores e atributos públicos

A normalização é implementada por meio de funções de análise sintática dedicadas e esquemas documentados em `schemas/`.

### 6. Saída Estruturada

A saída final:

* É determinística
* Está em conformidade com um esquema documentado
* É adequada para scripts, armazenamento e ferramentas subsequentes

Esta saída é a **interface principal** do UnauthScout.

## Enumeração de Repositórios/Projetos

A enumeração de repositórios (GitHub) e projetos (GitLab) é uma **extensão condicional**
do fluxo OSINT principal, ativada explicitamente pela flag `--repos`.

Esta fase segue o **mesmo modelo mental** do reconhecimento de perfil e
não introduz uma nova classe de comportamento.

### Condição de Acionamento

A enumeração ocorre somente quando:

* Um usuário/perfil válido é observado em um provedor
* O usuário solicita explicitamente a listagem de repositórios (`--repos`)

Isso evita:

* Chamadas de API desnecessárias
* Exaustão acidental do limite de requisições
* Expansão implícita do escopo

### Fluxo de Enumeração

```txt
Usuário Normalizado Identificado
↓
Requisição de Repositório/Projeto Público
↓
Resposta Bruta do Repositório
↓
Normalização do Repositório (Esquema)
↓
Saída Estruturada do Repositório
```

Cada repositório/projeto é tratado como uma **entidade observável independente**.

### Princípios de Enumeração

* Somente repositórios/projetos públicos são consultados
* A enumeração é limitada por provedor
* Nenhuma correlação entre provedores é realizada
* Nenhuma busca recursiva (issues, commits, contribuidores)

O objetivo é o **mapeamento superficial**, não uma inspeção profunda.

### ### Normalização e Contratos

Repositórios e projetos são normalizados em esquemas específicos do provedor, mas semanticamente alinhados:

* `schemas/github_user_repos.json`
* `schemas/gitlab_user_repos.json`

A seleção de campos prioriza:

* Identificadores
* URLs públicas
* Sinais de popularidade e atividade
* Comparabilidade entre provedores

Mapeamentos de campos detalhados estão documentados em:

* `docs/api_maps/github_repo_map.md`
* `docs/api_maps/gitlab_repo_map.md`

### Características da Saída

A saída da enumeração de repositórios:

* É emitida como um fluxo de objetos normalizados
* Preserva a ordem retornada pelo provedor
* Pode ser consumida incrementalmente por ferramentas subsequentes

A saída bruta (`--raw`) permanece disponível para inspeção e evolução do esquema.

## Por que os Esquemas Importam

Os esquemas servem como:

* Um contrato entre provedores e consumidores
* Documentação do comportamento observável
* Uma proteção contra alterações silenciosas que quebram a compatibilidade

Os esquemas são autoritativos.

O código se adapta aos esquemas, e não o contrário.

## O que este fluxo não abrange

O UnauthScout exclui intencionalmente:

* Reconhecimento autenticado
* Tratamento de limite de taxa
* Correlação entre plataformas
* Análise comportamental
* Rastreamento histórico
* Inspeção profunda do repositório (problemas, commits, CI)

Essas preocupações pertencem a sistemas de nível superior construídos *sobre* esta ferramenta.

## Estratégia de Evolução

Extensões futuras seguem o mesmo fluxo:

* Novo provedor → novo módulo
* Novo endpoint → novo esquema
* Novo formato de saída → preocupação no nível da CLI

O fluxo OSINT permanece estável.

## Resumo

O UnauthScout foi projetado como um **primitivo**:

* Pequeno
* Previsível
* Componível

Seu valor reside não no volume de dados coletados, mas na **clareza e
confiabilidade** dos dados que ele emite.
