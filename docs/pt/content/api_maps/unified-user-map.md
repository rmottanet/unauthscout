# Mapeamento Unificado de Campos de Usuário

Este documento descreve como os campos das respostas de API não autenticadas do **GitHub** e do **GitLab** são mapeados e normalizados no esquema de inteligência unificado do UnauthScout v0.3.0.

Ele fornece uma referência clara para:
- Decisões de normalização de campos entre provedores
- Conformidade com o esquema de inteligência unificado
- Reconhecimento OSINT orientado por esquema

## Filosofia de Normalização

O UnauthScout v0.3.0 introduz uma camada de inteligência unificada que transforma dados específicos de provedores em um formato consistente para análise e geração de relatórios multiplataforma.

O esquema unificado serve como:
1. **Fonte Única da Verdade** para todo o processamento subsequente
2. **Camada de Abstração do Provedor** permitindo análises consistentes
3. **Base de Inteligência** para sumarização e geração de relatórios

## Visão Geral do Esquema Unificado

O esquema unificado do usuário (`schemas/unified_user.json`) define o contrato de saída padrão para todas as operações de reconhecimento do usuário, independentemente da plataforma de origem.

### Princípios Essenciais de Design
- **Observabilidade**: Incluir apenas campos publicamente disponíveis
- **Estabilidade**: Priorizar dados consistentemente disponíveis
- **Valor de Inteligência**: Selecionar campos relevantes para análise OSINT
- **Consistência entre Provedores**: Mapear conceitos semelhantes para nomes unificados

## Tabela de Mapeamento de Campos

| Plataforma | Campo Bruto | Campo Unificado | Tipo | Observações |

|----------|-----------|---------------|------|-------|

| Ambos | — | `plataforma` | string | Identificador de origem: "github" ou "gitlab" |
| GitHub | `login` | `handle` | string | Identificador de nome de usuário/login |

| GitLab | `username` | `handle` | string | Identificador de nome de usuário |

| GitHub | `name` | `display_name` | string | Nome de exibição (alternativo: login) |

| GitLab | `name` | `display_name` | string | Nome de exibição (pode ser nulo) |

| GitHub | `html_url` | `profile_url` | URI | URL completa do perfil |

| GitLab | `web_url` | `profile_url` | URI | URL completa do perfil |

| GitHub | `email` | `email` | email/null | E-mail público (geralmente nulo) |

| GitHub | `bio` | `bio` | string/null | Biografia do usuário |

| GitHub | `location` | `location` | string/null | Localização geográfica |

| GitHub | `created_at` | `created_at` | data e hora | Criação da conta |
| GitHub | `public_repos` | `metrics.public_repos` | inteiro/nulo | Número de repositórios públicos |

| GitLab | — | `metrics.public_repos` | nulo | Não exposto na API não autenticada |

| GitHub | `followers` | `metrics.followers` | inteiro/nulo | Número de seguidores |

| GitHub | `following` | `metrics.following` | inteiro/nulo | Número de pessoas que sigo |

| GitHub | `twitter_username` | `social.twitter` | string/nulo | Nome de usuário do Twitter |

## Implementação da Normalização

A normalização atual é implementada em módulos específicos do provedor:

### Normalização do GitHub
```bash
normalize_github_user() {

jq '{

platform: "github",

handle: .login,

display_name: (.name // .login),

email: .email,

profile_url: .html_url,

metrics: {
public_repos: .public_repos,

followers: .followers,

following: .following
},

social: {
twitter: .twitter_username

},

location: .location,

bio: .bio,

created_at: .created_at

}'
}
```

### Normalização do GitLab
```bash
normalize_gitlab_user() {

jq '.[0] | {

plataforma: "gitlab",

handle: .username,

display_name: .name,

profile_url: .web_url,

metrics: {

public_repos: null,

followers: null,

following: null

},

social: {
twitter: null

},

bio: null,

location: null,

created_at: null

}'
}
```

## Contrato de Saída

A saída normalizada está em conformidade com:

```
schemas/unified_user.json
```

Este esquema define a estrutura oficial para todas as saídas de inteligência de usuário no UnauthScout v0.3.0 e versões posteriores.

## Observações sobre a disponibilidade de campos

### Vantagens do GitHub
- API não autenticada mais completa com mais de 15 campos públicos
- Metadados de redes sociais (Twitter, localização, biografia)
- Dados de métricas (seguidores, pessoas que segue, repositórios públicos)
- Carimbo de data/hora de criação da conta

### Limitações do GitLab
- O endpoint de busca não autenticado retorna dados limitados (5 campos principais)
- Sem métricas, dados de redes sociais ou dados temporais no contexto não autenticado
- Requer autenticação para informações de perfil estendidas

### Estratégia entre provedores
- **Mapeamento inclusivo**: Inclui campos disponíveis em qualquer provedor
- **Marcadores de posição nulos**: Usa nulo para dados indisponíveis (garante um esquema consistente)
- **Consciência de inteligência**: As funções de sumarização lidam com valores nulos de forma adequada

## Justificativa

O esquema unificado representa uma mudança estratégica de saídas específicas de provedores para estruturas de dados focadas em inteligência:

1. **Habilitação de análise**: A estrutura consistente permite Comparação entre plataformas
2. **Extensibilidade futura**: Novos provedores mapeiam para campos unificados existentes
3. **Integração de ferramentas**: Ferramentas externas podem consumir um único formato
4. **Experiência do usuário**: A camada de relatório apresenta informações consistentes independentemente da fonte

## Resumo

Este mapeamento documenta a transformação de dados brutos de provedores em um formato de inteligência unificado, permitindo a evolução do UnauthScout de um coletor de dados para uma plataforma de inteligência de reconhecimento. O esquema unificado serve como base para todos os recursos de inteligência da versão 0.3.0, incluindo sumarização, análise multiplataforma e geração de relatórios aprimorados.
