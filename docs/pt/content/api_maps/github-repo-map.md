# Mapeamento de Campos da API de Repositórios do GitHub

Este documento descreve como os campos das **respostas da API de Repositórios do GitHub não autenticadas**
são mapeados e normalizados pelo UnauthScout.

Ele serve como referência para:
- Entender quais campos brutos são usados
- Validar o alinhamento do esquema
- Auditar as decisões de normalização

## Endpoint

```

GET [https://api.github.com/users/{username}/repos](https://api.github.com/users/{username}/repos)

```

- Autenticação: ❌ Não obrigatória
- Escopo: Somente repositórios públicos
- Paginação: `per_page=100` (máximo permitido)

## Visão Geral da Resposta Bruta

A API de Repositórios do GitHub retorna um **array de objetos de repositório**, cada um contendo
metadados extensos, URLs internas da API, sinalizadores de recursos e detalhes de configuração.

O UnauthScout seleciona intencionalmente um **subconjunto mínimo** de metadados de repositório estáveis ​​e relevantes para OSINT,
adequados para normalização entre provedores.

## Mapeamento de Campos

| Raw Field              | Normalized Field | Included | Notes |
|------------------------|------------------|----------|-------|
| `id`                   | `id`             | ✅       | Stable unique repository identifier |
| `name`                 | `name`           | ✅       | Repository name |
| `full_name`            | `full_name`      | ✅       | Owner/repository (globally unique) |
| `description`          | `description`    | ✅       | Nullable, useful for context |
| `html_url`             | `url`            | ✅       | Public repository URL |
| `stargazers_count`     | `stars`          | ✅       | Popularity signal |
| `forks_count`          | `forks`          | ✅       | Activity and reuse signal |
| `language`             | `language`       | ✅       | Primary language (nullable) |
| `private`              | —                | ❌       | Always false for public enumeration |
| `owner`                | —                | ❌       | Redundant (implicit via username) |
| `topics`               | —                | ❌       | Requires preview headers |
| `license`              | —                | ❌       | Often null / inconsistent |
| `created_at`           | —                | ❌       | Not required for MVP |
| `updated_at`           | —                | ❌       | Highly volatile |
| `pushed_at`            | —                | ❌       | Activity noise |
| `size`                 | —                | ❌       | Low OSINT value |
| `default_branch`       | —                | ❌       | Operational detail |
| `clone_url`            | —                | ❌       | Non-OSINT |
| `ssh_url`              | —                | ❌       | Non-OSINT |
| `fork`                 | —                | ❌       | Context-specific, excluded for MVP |
| `archived`             | —                | ❌       | Edge-case, low signal |
| `disabled`             | —                | ❌       | Rare, non-actionable |
| `permissions`          | —                | ❌       | Auth-dependent |
| `hooks_url`            | —                | ❌       | Internal API URL |
| `issues_url`           | —                | ❌       | Internal API URL |

## Lógica de Normalização

A normalização atual é implementada da seguinte forma:

```bash
parse_github_repos() {
    jq '.[] | {
        id,
        name: .name,
        full_name: .full_name,
        description,
        url: .html_url,
        stars: .stargazers_count,
        forks: .forks_count,
        language
    }'
}
````

Cada repositório é emitido como um **objeto normalizado único**.

## Contrato de Saída

A saída normalizada está em conformidade com:

```
schemas/github_user_repos.json
```

Este esquema é a **definição oficial** da saída do repositório GitHub
dentro do UnauthScout.

## Justificativa

A inclusão de campos segue estes princípios:

* Os campos devem estar sempre presentes
* Os campos devem ser relevantes para OSINT (Inteligência de Fontes Abertas)
* Os campos devem suportar paridade entre provedores
* Os campos não devem exigir autenticação
* Os campos devem ser automatizáveis ​​e estáveis

Todos os outros campos são intencionalmente excluídos para reduzir ruído, evitar desvios na API
e preservar a estabilidade do contrato a longo prazo.

## Notas sobre a Evolução

* Metadados adicionais (ex.: licença, tópicos) poderão ser adicionados em versões futuras.
* Os cronogramas de atividade do repositório foram intencionalmente excluídos do escopo do MVP.
* Campos exclusivos para usuários autenticados exigirão um contrato e um esquema separados.
* Alterações que quebrem a compatibilidade serão documentadas explicitamente.

## Resumo

Este mapeamento garante que o UnauthScout emita uma **representação limpa, minimalista e previsível** dos repositórios públicos do GitHub, adequada para fluxos de trabalho OSINT,
pipelines de automação e expansão futura de provedores.
