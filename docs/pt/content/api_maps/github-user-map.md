# Mapeamento de campos da API GitHub

Este documento descreve como os campos da **resposta da API de Usuários do GitHub não autenticados**
são mapeados e normalizados pelo UnauthScout.

Ele serve como referência para:
- Entender quais campos brutos são usados
- Validar o alinhamento do esquema
- Auditar as decisões de normalização

## Endpoint

```

GET [https://api.github.com/users/{username}](https://api.github.com/users/{username})

```

- Autenticação: ❌ Não é necessária
- Escopo: Somente dados públicos do usuário

## Visão geral da resposta bruta

A API do GitHub retorna um grande objeto JSON contendo metadados, URLs internas e
informações de perfil público.

O UnauthScout seleciona intencionalmente um **subconjunto mínimo** de campos estáveis ​​e relevantes para OSINT (Inteligência de Fontes Abertas)
para normalização.

## Mapeamento de Campos

| Raw Field        | Normalized Field | Included | Notes |
|------------------|------------------|----------|-------|
| `id`             | `id`             | ✅       | Stable unique identifier |
| `login`          | `login`          | ✅       | Username / handle |
| `name`           | `name`           | ✅       | Display name (nullable) |
| `type`           | `type`           | ✅       | User or Organization |
| `html_url`       | `html_url`       | ✅       | Public profile URL |
| `public_repos`   | `public_repos`   | ✅       | Public repository count |
| `followers`      | `followers`      | ✅       | Follower count |
| `following`      | `following`      | ✅       | Following count |
| `avatar_url`     | —                | ❌       | Cosmetic, excluded |
| `company`        | —                | ❌       | Often empty or noisy |
| `blog`           | —                | ❌       | User-controlled, unstable |
| `location`       | —                | ❌       | Free-form, inconsistent |
| `email`          | —                | ❌       | Null in unauth context |
| `bio`            | —                | ❌       | High variance |
| `twitter_username` | —             | ❌       | External enrichment |
| `created_at`     | —                | ❌       | Not required for MVP |
| `updated_at`     | —                | ❌       | Volatile |
| `repos_url`      | —                | ❌       | Internal API URL |
| `followers_url`  | —                | ❌       | Internal API URL |
| `events_url`     | —                | ❌       | Internal API URL |


## Lógica de Normalização

A normalização atual é implementada da seguinte forma:

```bash
parse_github_user() {
    jq '{
        id,
        login,
        name,
        type,
        html_url,
        public_repos,
        followers,
        following
    }'
}
````

Somente os campos listados no esquema correspondente são emitidos.

## Contrato de Saída

A saída normalizada está em conformidade com:

```
schemas/github_user.json
```

Este esquema é a **definição oficial** da saída do usuário do GitHub.

## Justificativa

A inclusão de campos segue estes princípios:

* Os campos devem estar sempre presentes
* Os campos devem ser relevantes para OSINT (Inteligência de Fontes Abertas)
* Os campos devem ser estáveis ​​ao longo do tempo
* Os campos não devem exigir autenticação

Todos os outros campos são intencionalmente excluídos para preservar a qualidade do sinal e a previsibilidade da saída.

## Notas sobre a Evolução

* Campos adicionais poderão ser adicionados em versões futuras por meio de atualizações de esquema.
* Campos autenticados exigirão um contrato separado.
* Alterações que quebrem a compatibilidade serão documentadas explicitamente.

## Resumo

Este mapeamento garante que o UnauthScout emita uma representação **limpa, minimalista e confiável** dos dados públicos de usuários do GitHub, adequada para automação e análise.
