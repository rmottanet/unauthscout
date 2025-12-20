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


## Fluxo de alto nível

```txt

Alvo
↓
Seleção do provedor
↓
Solicitação de API não autenticada
↓
Resposta bruta
↓
Normalização (esquema)
↓
Saída estruturada

```

Cada etapa tem uma **responsabilidade única** e um limite claramente definido.


## Detalhamento passo a passo

### 1. Identificação do alvo

O usuário fornece um identificador de alvo (por exemplo, nome de usuário).

O UnauthScout não:
- Adivinha identidades
- Estabelece correlações entre plataformas
- Realiza enriquecimento nesta etapa

O alvo é tratado como um identificador opaco passado para o provedor.


### 2. Seleção do provedor

A CLI determina qual módulo do provedor invocar (por exemplo, GitHub, GitLab).

Responsabilidades:
- Roteamento
- Tratamento de sinalizadores (`--raw`, modos de saída futuros)
- Propagação de erros

O ponto de entrada **não implementa lógica de reconhecimento**.


### 3. Solicitação de API não autenticada

Cada módulo do provedor executa:
- Uma solicitação direta à API pública
- Sem autenticação
- Sem novas tentativas ou evasão de limite de taxa

Isso garante:
- Uso ético
- Reprodutibilidade
- Limites de confiança claros


### 4. Tratamento de resposta bruta

A resposta bruta da API representa a **verdade fundamental**.

O UnauthScout oferece suporte a um modo `--raw` para:
- Inspecionar campos disponíveis
- Validar suposições
- Auxiliar na evolução do esquema

A saída bruta destina-se à **análise e desenvolvimento**, não à automação.


### 5. Normalização

A normalização transforma respostas brutas em um **contrato estável e mínimo**.

Princípios:
- Incluir apenas campos que estejam consistentemente disponíveis
- Evitar campos voláteis ou internos do provedor
- Preferir identificadores e atributos públicos

A normalização é implementada por meio de funções de analisador dedicadas e esquemas documentados
em `schemas/`.


### 6. Saída estruturada

A saída final:
- É determinística
- Está em conformidade com um esquema documentado
- É adequada para scripts, armazenamento e ferramentas downstream

Essa saída é a **interface principal** do UnauthScout.


## Porque os esquemas são importantes

Os esquemas servem como:
- Um contrato entre fornecedores e consumidores
- Documentação de comportamento observável
- Uma proteção contra alterações silenciosas

Os esquemas são autoritários.
O código se adapta aos esquemas, e não o contrário.


## O que este fluxo não abrange

O UnauthScout exclui intencionalmente:
- Reconhecimento autenticado
- Tratamento de limite de taxa
- Correlação entre plataformas
- Análise comportamental
- Rastreamento histórico

Essas questões pertencem a sistemas de nível superior construídos *sobre* essa ferramenta.


## Estratégia de evolução

Extensões futuras seguem o mesmo fluxo:
- Novo provedor → novo módulo
- Novo endpoint → novo esquema
- Novo formato de saída → questão no nível da CLI

O fluxo OSINT permanece inalterado.


## Resumo

O UnauthScout foi projetado como um **primitivo**:
- Pequeno
- Previsível
- Combinável

Seu valor não reside no volume de dados coletados, mas na **clareza e
confiabilidade** dos dados que emite.
