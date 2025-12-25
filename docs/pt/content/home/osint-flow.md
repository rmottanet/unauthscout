# Fluxo OSINT

Este documento descreve o **modelo mental e o fluxo operacional** por trás do
UnauthScout. Ele explica *como* e *por que* a ferramenta realiza reconhecimento,
independentemente de qualquer implementação específica de um provedor.

## Objetivo

O UnauthScout foi projetado para realizar **reconhecimento não autenticado** em plataformas públicas de desenvolvedores de forma previsível, auditável e amigável à automação.

O objetivo não é o esgotamento de dados, mas sim a **extração de sinais**:
- Uma entidade existe?

- Onde ela está exposta publicamente?

- Qual é a superfície observável sem credenciais?

- **Aprimoramento da versão 0.3.0:** Quais são os sinais de inteligência agregados (principais idiomas, número total de estrelas, padrões de atividade)?

## Pressupostos Básicos

- APIs públicas expõem dados de reconhecimento relevantes sem autenticação
- Esses dados são suficientes para OSINT e criação de perfis em estágios iniciais
- A normalização é necessária para tornar os dados comparáveis ​​entre provedores
- Os contratos devem refletir a **realidade observável**, não a capacidade teórica da API
- **Aprimoramento da v0.3.0:** Esquemas de inteligência unificados permitem análise e sumarização entre provedores

## Fluxo Geral

```txt
Alvo
↓
Seleção de Provedor e Orquestração da CLI
↓
Requisição de API não autenticada
↓
Resposta Bruta
↓
Normalização → Esquema Unificado
↓
Saída Estruturada OU Resumo de Inteligência
```

Cada etapa tem uma **única responsabilidade** e um limite claramente definido.

## Detalhamento Passo a Passo

### 1. Identificação do Alvo

O usuário fornece um identificador de alvo (por exemplo, nome de usuário).

O UnauthScout não:

* Tenta adivinhar identidades
* Correlaciona entre plataformas
* Realiza enriquecimento nesta etapa

O alvo é tratado como um identificador opaco passado para o provedor.

### 2. Seleção do Provedor e Orquestração da CLI

A CLI determina qual módulo do provedor invocar (por exemplo, GitHub, GitLab) e orquestra o fluxo de inteligência.

**Responsabilidades atualizadas (v0.3.0):**
* Roteamento
* Manipulação de flags (`--raw`, `--repos`, `--summarize`, `--pretty`)
* Seleção do modo de saída (JSON bruto, relatório formatado, resumo de inteligência)
* Propagação de erros

O ponto de entrada **não implementa lógica de reconhecimento**, mas agora gerencia a camada de apresentação por meio do módulo de relatório integrado.

### 3. Requisição de API Não Autenticada

Cada módulo de provedor realiza:

* Uma requisição direta à API pública
* Sem autenticação
* Sem novas tentativas ou evasão de limite de requisições

Isso garante:

* Uso ético
* Reprodutibilidade
* Limites de confiança claros

### 4. Tratamento de Resposta Bruta

A resposta bruta da API representa a **verdade fundamental**.

O UnauthScout suporta um modo `--raw` para:

* Inspecionar os campos disponíveis
* Validar suposições
* Auxiliar na evolução do esquema

**Aprimoramento da v0.3.0:** A flag `--pretty` formata o JSON bruto para facilitar a leitura humana. A saída bruta destina-se à **análise e desenvolvimento**, não à automação.

### 5. Normalização para Esquema Unificado

A normalização transforma as respostas brutas do provedor em um **contrato de inteligência estável e unificado**.

**Princípios Atualizados (v0.3.0):**
* Transformar dados específicos do provedor em um esquema unificado (`unified_user.json`, `unified_repo.json`)
* Incluir apenas campos que estejam sempre disponíveis ou que possam ser nulos
* Evitar campos voláteis ou internos ao provedor
* Dar preferência a identificadores e atributos públicos
* Mapear conceitos semelhantes para os mesmos nomes de campo unificados em todas as plataformas

A normalização é implementada por meio de funções `normalize_*` dedicadas nos módulos do provedor, em conformidade com os esquemas oficiais em `schemas/`.

### 6. Saída Estruturada e Apresentação Inteligente

A saída final se adapta com base nas opções definidas pelo usuário, oferecendo múltiplas interfaces:

* **`--raw` (Padrão):** JSON compacto e unificado para scripts e ferramentas subsequentes.

* **`--raw --pretty`:** JSON com indentação para análise humana.

* **Padrão (sem --raw):** Relatórios formatados no terminal via `lib/report.sh`:

* Perfis de usuário específicos da plataforma
* Listagens unificadas de repositórios
* **`--summarize` (requer `--repos`):** Gera um **resumo de inteligência** agregando dados de repositórios enumerados (total de estrelas, principais linguagens, atividade mais recente).

Essa saída permanece determinística e em conformidade com o esquema, com o novo resumo fornecendo **valor analítico** além da listagem de dados brutos.

## Enumeração e Inteligência de Repositórios/Projetos

A enumeração de repositórios (GitHub) e projetos (GitLab) é uma **extensão condicional** do fluxo OSINT principal, ativada explicitamente pela flag `--repos`.

A introdução de `--summarize` adiciona uma **camada de inteligência** sobre a enumeração, transformando os dados listados em insights acionáveis.

### Condição de Acionamento

A enumeração ocorre somente quando:

* Um usuário/perfil válido é observado em um provedor
* O usuário solicita explicitamente a listagem de repositórios (`--repos`)

O resumo inteligente ocorre somente quando:
* A enumeração de repositórios está ativa (`--repos`)
* O usuário a solicita explicitamente (`--summarize`)

Isso evita:

* Chamadas de API desnecessárias
* Exaustão acidental do limite de taxa
* Expansão implícita do escopo
* Análise computacional não solicitada

### Fluxo de Enumeração e Inteligência

```txt
Usuário Normalizado Identificado
↓
Repositório Público / Solicitação de Projeto
↓
Resposta Bruta do Repositório
↓
Normalização do Repositório (Esquema Unificado)
↓
Saída Estruturada do Repositório
↓
[ Condicional: Resumo e Relatório Inteligente ]
```

Cada repositório/projeto é tratado como uma **entidade observável independente**. A etapa de resumo trata a **coleção inteira** como um conjunto de dados para análise.

### Princípios de Enumeração e Inteligência

* Somente repositórios/projetos públicos são consultados.

* A enumeração e o resumo são definidos por execução do provedor.

* Nenhuma correlação entre provedores é realizada automaticamente.

* Nenhuma travessia recursiva (problemas, commits, contribuidores).

* Os resumos de inteligência são derivados exclusivamente de dados normalizados do repositório.

O objetivo evolui do **mapeamento de superfície** para o **reconhecimento de padrões** dentro da superfície mapeada.

### Normalização e Contratos

**Atualizado para a versão 0.3.0:** Repositórios e projetos são normalizados no **esquema de repositório unificado** (`schemas/unified_repo.json`).

A seleção de campos prioriza:

* Identificadores
* URLs públicas
* Sinais de popularidade e atividade
* **Comparabilidade entre provedores** (por exemplo, `stars`, `updated_at`)
* Campos que permitem inteligência (por exemplo, `language`, `topics`)

Os mapeamentos de campos detalhados para os esquemas unificados estão documentados em:
* `docs/api_maps/unified-user-map.md`
* `docs/api_maps/unified-repo-map.md`

### Características da Saída

**Atualizado para a versão 0.3.0:** Saída da enumeração de repositórios:

* É emitida como um array JSON unificado ou uma lista formatada.

* Preserva a ordem retornada pelo provedor.

* **Novo:** Pode ser analisada para produzir um resumo de inteligência baseado em terminal.

* A saída unificada bruta (`--raw`) permanece disponível para inspeção. ## Por que os Esquemas Importam

Os esquemas servem como:

* Um contrato entre provedores, camadas de normalização e inteligência.

* Documentação do comportamento observável.

* Uma proteção contra alterações silenciosas que quebram a compatibilidade.

* **Função na v0.3.0:** Os **esquemas unificados** são a única fonte de verdade para a camada de inteligência, permitindo análises confiáveis ​​entre provedores.

Os esquemas são autoritativos. O código se adapta aos esquemas, e não o contrário.

## A Camada de Inteligência (v0.3.0)

Uma nova camada foi introduzida, implementada em `lib/report.sh`. Suas responsabilidades são estritamente separadas:

1. **Apresentação:** Formatação de dados normalizados para saída no terminal (`render_user_report`, `render_repos_list`).

2. **Análise:** Agregação de dados normalizados do repositório para responder a perguntas específicas de OSINT (`render_intel_summary`).

Esta camada não busca dados, não lida com erros nem gerencia esquemas. Ela transforma dados estruturados em relatórios e insights legíveis para humanos.

## O que este fluxo não abrange

O UnauthScout exclui intencionalmente:

* Reconhecimento autenticado
* Tratamento de limite de taxa
* Correlação multiplataforma **automática** (o resumo é por provedor)
* Análise comportamental além dos metadados estáticos do repositório
* Rastreamento histórico
* Inspeção profunda do repositório (problemas, commits, CI)

Essas responsabilidades pertencem a sistemas de nível superior construídos *sobre* esta ferramenta.

## Estratégia de evolução

Extensões futuras seguem o mesmo fluxo:

* Novo provedor → novo módulo → normalização para **esquema unificado**
* Novo endpoint → novo esquema
* Novo formato de saída ou inteligência → responsabilidade da camada de CLI e relatórios

O fluxo OSINT permanece estável; a camada de inteligência o estende sem alterações.

## Resumo

O UnauthScout foi projetado como uma ferramenta **primitiva**:

* Pequena
* Previsível
* Componível

Com a versão 0.3.0, seu valor é aprimorado: ele fornece não apenas **clareza e confiabilidade** dos dados coletados, mas também **inteligência acionável** derivada desses dados por meio de um pipeline estruturado e orientado a esquemas.
