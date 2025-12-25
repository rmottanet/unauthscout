# Mapeamento Unificado de Campos de Repositório

Este documento descreve como os campos das respostas da API de repositórios não autenticados do **GitHub** e do **GitLab** são mapeados e normalizados no esquema de inteligência unificado do UnauthScout v0.3.0.

Ele fornece uma referência clara para:
- Normalização de campos de repositórios entre provedores
- Esquema de inteligência unificado para enumeração de ativos
- Análise e sumarização de repositórios orientadas a esquemas

## Filosofia de Normalização

O UnauthScout v0.3.0 introduz um esquema de repositório unificado que transforma dados de projetos específicos de cada provedor em um formato consistente para análise de ativos multiplataforma. Isso possibilita operações de inteligência como análise de linguagem, rastreamento de atividades e métricas de popularidade tanto no GitHub quanto no GitLab.

O esquema unificado do repositório serve como:
1. **Base de Inteligência de Ativos** para enumeração de repositórios
2. **Consistência entre Plataformas**, permitindo análise unificada
3. **Entrada de Sumarização** para relatórios de inteligência

## Visão Geral do Esquema Unificado

O esquema unificado do repositório (`schemas/unified_repo.json`) define o contrato de saída padrão para todas as operações de enumeração de repositórios, independentemente da plataforma de origem.

### Princípios Essenciais de Design
- **Observabilidade**: Incluir apenas campos de repositório publicamente disponíveis
- **Relevância para OSINT**: Priorizar campos úteis para análise de reconhecimento
- **Restrições de Plataforma**: Reconhecer as limitações de linguagem do GitLab
- **Consistência de Array**: Padronizar o formato de array para múltiplos repositórios

## Tabela de Mapeamento de Campos

| Plataforma | Campo Bruto | Campo Unificado | Tipo | Observações |

|----------|-----------|---------------|------|-------|

| GitHub | `name` | `name` | string | Nome abreviado do repositório |

| GitLab | `name` | `name` | string | Nome abreviado do projeto |

| GitHub | `full_name` | `full_name` | string | Formato `owner/name` |

| GitLab | `path_with_namespace` | `full_name` | string | Formato de caminho equivalente |

| GitHub | `html_url` | `url` | URI | URL web do repositório |

| GitLab | `web_url` | `url` | URI | URL web do projeto |

| GitHub | `description` | `description` | string | Descrição do projeto (vazio se nulo) |

| GitLab | `description` | `description` | string | Descrição do projeto (vazio se nulo) |

| GitHub | `stargazers_count` | `stars` | integer | Número de estrelas (≥ 0) |

| GitLab | `star_count` | `stars` | integer | Contagem de estrelas (≥ 0) |
| GitHub | `language` | `language` | string | Idioma principal (null → "N/A") |

| GitLab | — | `language` | string | Sempre "N/A" (limitação da API do GitLab) |

| GitHub | `updated_at` | `updated_at` | date-time | Timestamp da última atividade (ISO 8601) |

| GitLab | `last_activity_at` | `updated_at` | date-time | Timestamp da última atividade |

| GitHub | `topics` | `topics` | array[string] | Tópicos/tags do repositório |

| GitLab | `tag_list` | `topics` | array[string] | Tags do projeto |

## Implementação da Normalização

A normalização atual é implementada em módulos específicos do provedor:

### Normalização do GitHub
```bash
normalize_github_repos() {

jq ${JQ_OPTS} 'map({

name: .name,

full_name: .full_name,

url: .html_url,

description: (.description // ""),

stars: .stargazers_count,

language: (.language // "N/A"),

updated_at: .updated_at,

topics: (.topics // [])

})'
}
```

### Normalização do GitLab
```bash
normalize_gitlab_repos() {

jq ${JQ_OPTS} 'map({

name: .name,

full_name: .path_with_namespace,

url: .web_url,

description: (.description // ""),
estrelas: .star_count,

idioma: "N/A",

atualizado_em: .last_activity_at,

tópicos: (.tag_list // [])

})'
}
```

## Contrato de Saída

A saída normalizada está em conformidade com:

```
schemas/unified_repo.json
```

Este esquema define a estrutura oficial para toda a saída de inteligência do repositório no UnauthScout v0.3.0 e versões posteriores.

## Considerações Específicas da Plataforma

### Vantagens do GitHub
- Detecção de idioma disponível na API não autenticada
- Sistema robusto de tópicos/tags com um campo dedicado `topics`
- Campo `updated_at` consistente para rastreamento de atividades
- `forks_count` disponível (atualmente não mapeado para um esquema unificado)

### Limitações do GitLab
- **Detecção de Idioma**: Não disponível na API não autenticada - sempre retorna "N/A"
- **Sistema de Tags**: Usa `tag_list` em vez de `topics`
- **Rastreamento de Atividades**: Usa `last_activity_at` em vez de `updated_at`
- **Métricas de Popularidade**: Limitadas a `star_count` (sem contagem de forks na resposta padrão)

### Estratégia entre Fornecedores
- **Nomes de Campos Consistentes**: Mapear conceitos semelhantes para os mesmos nomes unificados
- **Valores Padrão**: Usar "N/A" para dados de idioma indisponíveis
- **Espaços Reservados Vazios**: Arrays/strings vazios para valores nulos
- **Reconhecimento de Inteligência**: O resumo lida com as diferenças entre plataformas

## Aplicações de Inteligência

O esquema de repositório unificado possibilita diversas funcionalidades de inteligência:

1. **Análise de Linguagem**: Identificar as principais linguagens de programação (somente GitHub)
2. **Métricas de Popularidade**: Comparar a quantidade de estrelas em diferentes plataformas
3. **Rastreamento de Atividades**: Determinar a atividade recente do projeto
4. **Análise de Tópicos**: Identificar as áreas de foco e tecnologias do projeto
5. **Enumeração de Ativos**: Lista completa de repositórios/projetos públicos

## Justificativa

O esquema de repositório unificado representa uma mudança estratégica da listagem de ativos específica do provedor para a análise de repositórios focada em inteligência:

1. **Análise Multiplataforma**: Permite a comparação de repositórios entre GitHub e GitLab
2. **Base para Sumarização**: Fornece uma estrutura de dados consistente para relatórios de inteligência
3. **Integração de Ferramentas**: Ferramentas externas podem consumir dados de repositório padronizados
4. **Extensibilidade Futura**: Novos campos de repositório podem ser adicionados ao esquema unificado

## Resumo

Este mapeamento documenta a transformação de dados brutos de repositórios de provedores para um formato de inteligência unificado, habilitando os recursos de enumeração de ativos do UnauthScout. O esquema de repositório unificado serve como base para os recursos de inteligência da versão 0.3.0, incluindo análise de linguagem, rastreamento de atividade e sumarização de repositórios multiplataforma.
