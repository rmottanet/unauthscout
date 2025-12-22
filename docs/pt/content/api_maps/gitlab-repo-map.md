# Mapeamento de Campos da API de Projetos do GitLab

Este documento descreve como os campos da **resposta da API de Projetos do GitLab não autenticada**
são mapeados e normalizados pelo UnauthScout.

Ele serve como referência para:
- Entender quais campos brutos são usados
- Validar o alinhamento do esquema
- Auditar as decisões de normalização

## Endpoint

```

GET [https://gitlab.com/api/v4/users/{username}/projects](https://gitlab.com/api/v4/users/{username}/projects)

```

- Autenticação: ❌ Não obrigatória
- Escopo: Somente projetos públicos
- Filtros: `visibility=public`
- Paginação: `per_page=100`

## Visão Geral da Resposta Bruta

A API de Projetos do GitLab retorna um **array de objetos de projeto**, cada um contendo
metadados, URLs internas, permissões e campos de configuração específicos da plataforma.

O UnauthScout seleciona intencionalmente um **subconjunto mínimo** de metadados de projeto estáveis ​​e relevantes para OSINT,
adequados para normalização entre provedores.

## Mapeamento de Campos

| Raw Field                | Normalized Field | Included | Notes |
|--------------------------|------------------|----------|-------|
| `id`                     | `id`             | ✅       | Stable unique project identifier |
| `name`                   | `name`           | ✅       | Project name |
| `path_with_namespace`    | `path`           | ✅       | Fully qualified project path |
| `description`            | `description`    | ✅       | Nullable, contextual |
| `web_url`                | `url`            | ✅       | Public project URL |
| `star_count`             | `stars`          | ✅       | Popularity signal |
| `forks_count`            | `forks`          | ✅       | Reuse and activity signal |
| `visibility`             | —                | ❌       | Filtered at request time |
| `namespace`              | —                | ❌       | Redundant with path |
| `owner`                  | —                | ❌       | Not always present |
| `default_branch`         | —                | ❌       | Operational detail |
| `created_at`             | —                | ❌       | Not required for MVP |
| `last_activity_at`       | —                | ❌       | Volatile |
| `archived`               | —                | ❌       | Edge-case, low signal |
| `topics`                 | —                | ❌       | Not consistently populated |
| `readme_url`             | —                | ❌       | Secondary resource |
| `http_url_to_repo`       | —                | ❌       | Non-OSINT |
| `ssh_url_to_repo`        | —                | ❌       | Non-OSINT |
| `permissions`            | —                | ❌       | Auth-dependent |
| `_links`                 | —                | ❌       | Internal API URLs |

## Lógica de Normalização

A normalização atual é implementada da seguinte forma:

```bash
parse_gitlab_repos() {
    jq '.[] | {
        id,
        name: .name,
        path: .path_with_namespace,
        description,
        url: .web_url,
        stars: .star_count,
        forks: .forks_count
    }'
}
````

Cada projeto é emitido como um **objeto normalizado único**.

## Contrato de Saída

A saída normalizada está em conformidade com:

```
schemas/gitlab_user_repos.json
```

Este esquema é a **definição oficial** da saída de projetos do GitLab
dentro do UnauthScout.

## Justificativa

A inclusão de campos segue estes princípios:

* Os campos devem estar sempre presentes
* Os campos devem ser relevantes para OSINT (Inteligência de Fontes Abertas)
* Os campos devem suportar paridade entre provedores
* Os campos não devem exigir autenticação
* Os campos devem ser estáveis ​​entre as versões do GitLab

Todos os outros campos são intencionalmente excluídos para reduzir ruído, evitar acoplamento específico da plataforma e preservar a estabilidade do contrato a longo prazo.

## Notas sobre a Evolução

* Metadados adicionais (por exemplo, tópicos, licença) poderão ser adicionados em versões futuras.
* Projetos pertencentes a grupos poderão receber tratamento estendido em versões futuras.
* Campos exclusivos para usuários autenticados exigirão um contrato e um esquema separados.
* Alterações que quebrem a compatibilidade serão documentadas explicitamente.

## Resumo

Este mapeamento garante que o UnauthScout emita uma **representação limpa, minimalista e previsível** de projetos públicos do GitLab, adequada para fluxos de trabalho de OSINT,
pipelines de automação e análises independentes de provedor.
