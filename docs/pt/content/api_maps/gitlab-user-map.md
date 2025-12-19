# Mapeamento de campos da API GitLab

Este documento descreve como os campos da **resposta da API de Usuários do GitLab não autenticada**
são mapeados e normalizados pelo UnauthScout.

Ele fornece uma referência clara para:
- Visibilidade dos campos brutos em solicitações não autenticadas
- Decisões de normalização
- Alinhamento de esquema e auditabilidade

## Endpoint

```

GET [https://gitlab.com/api/v4/users?username={username}](https://gitlab.com/api/v4/users?username={username})

````

- Autenticação: ❌ Não é necessária
- Escopo: Somente dados públicos do usuário

> Observação: Este endpoint retorna um **array**. O UnauthScout opera na primeira entrada correspondente.

## Visão geral da resposta

O endpoint de busca de usuários não autenticados do GitLab retorna um conjunto limitado de campos públicos. Vários atributos disponíveis em contextos autenticados estão intencionalmente ausentes.

O UnauthScout normaliza apenas os campos que são **observáveis ​​e estáveis** na resposta não autenticada.

---

## Mapeamento de Campos

| Raw Field        | Normalized Field | Included | Notes |
|------------------|------------------|----------|-------|
| `id`             | `id`             | ✅       | Stable unique identifier |
| `username`       | `username`       | ✅       | User handle |
| `name`           | `name`           | ✅       | Display name (nullable) |
| `state`          | `state`          | ✅       | Account state |
| `web_url`        | `web_url`        | ✅       | Public profile URL |
| `avatar_url`     | —                | ❌       | Cosmetic |
| `public_email`   | —                | ❌       | Empty in unauth context |
| `locked`         | —                | ❌       | Internal account state |
| `created_at`     | —                | ❌       | Not exposed without auth |
| `bio`            | —                | ❌       | Not available |
| `location`       | —                | ❌       | Not available |

---

## Lógica de Normalização

A normalização atual é implementada da seguinte forma:

```bash
parse_gitlab_user() {
    jq '.[0] | {
        id,
        username,
        name,
        state,
        web_url
    }'
}
````

The parser explicitly selects the first matching user from the search result
array.

## Contrato de Saída

A saída normalizada está em conformidade com:

```
schemas/gitlab_user.json
```

Este esquema define a estrutura autoritativa da saída de um usuário não autenticado do GitLab.

## Justificativa

A seleção de campos segue estas restrições:

* Os campos devem ser retornados pelo endpoint não autenticado
* Os campos devem estar consistentemente presentes entre os usuários
* Os campos devem ser relevantes para OSINT (Inteligência de Fontes Abertas)
* Os campos devem evitar ruídos internos ou cosméticos

A normalização exclui intencionalmente campos que:

* Requerem autenticação
* São instáveis ​​ou pouco preenchidos
* Representam mecanismos internos da plataforma

## Observações sobre as limitações do endpoint

* O endpoint `/users?username=` é uma **busca**, não uma consulta direta.
* Nomes de usuário ambíguos podem retornar múltiplos resultados.
* Atualmente, o UnauthScout seleciona apenas o primeiro resultado.

Essas limitações são documentadas por design e podem ser abordadas em iterações futuras.

## Resumo

Este mapeamento documenta a transformação exata de dados brutos e não autenticados da API do GitLab em uma representação mínima e normalizada, adequada para fluxos de trabalho de OSINT (Inteligência de Fontes Abertas) e automação.
