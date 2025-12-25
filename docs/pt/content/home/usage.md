# Guia de Uso

Este documento fornece instruções completas para usar o UnauthScout v0.3.0,
abrangendo todos os fluxos de trabalho de reconhecimento, recursos de inteligência e formatos de saída.
Para instalação e configuração básica, consulte o [Guia de Configuração](./setup).

## Estrutura de Comandos

A estrutura básica de comandos segue este padrão:

```bash
unauthscout [opções] <nome de usuário>
```

Onde:
* `<nome de usuário>` é o identificador do alvo (obrigatório)
* `[opções]` controla a seleção da plataforma, a profundidade do reconhecimento e o formato de saída

## Seleção de Plataforma

Por padrão, o UnauthScout pesquisa tanto no GitHub quanto no GitLab. Você pode restringir seu
reconhecimento a uma única plataforma.

### Pesquisar em ambas as plataformas (padrão)

```bash
unauthscout <nome de usuário>
```

**Exemplo:**
```bash
unauthscout torvalds
```

### Somente GitHub

```bash
unauthscout <nome de usuário> --github
# ou
unauthscout <nome de usuário> -gh
```

**Exemplo:**
```bash
unauthscout torvalds --github
```

### Somente GitLab

```bash
unauthscout <nome de usuário> --gitlab
# ou
unauthscout <nome de usuário> -gl
```

**Exemplo:**
```bash
unauthscout dzaporozhets --gitlab
```

## Profundidade de reconhecimento

### Reconhecimento básico de perfil (padrão)

Busca e normaliza apenas as informações do perfil do usuário.

``bash
unauthscout <nome de usuário>
```

**A saída inclui:**
* Identificador da plataforma
* Nome de usuário e nome de exibição
* URL do perfil
* Métricas disponíveis (seguidores, repositórios públicos)
* Links para redes sociais (quando disponíveis)

### Enumeração de repositórios

Adiciona a lista de repositórios/projetos públicos ao reconhecimento.

```bash
unauthscout <nome de usuário> --repos
# ou
unauthscout <nome de usuário> -r
```

**A saída inclui (além do perfil):**
* Lista de repositórios/projetos públicos
* Para cada um: nome, URL, estrelas, idioma (somente GitHub), última atividade
* Formatado como uma tabela no modo padrão

**Exemplos:**
```bash
# Ambas as plataformas
unauthscout torvalds --repos

# Somente GitHub
unauthscout torvalds --github --repos

# Somente GitLab
unauthscout dzaporozhets --gitlab --repos
```

### Resumo de inteligência

Gera insights analíticos a partir dos repositórios enumerados. **Requer `--repos`.**

```bash
unauthscout <nome de usuário> --repos --summarize
# ou
unauthscout <nome de usuário> -r -s
```

**O resumo de inteligência inclui:**
* Total de estrelas em todos os repositórios
* 3 principais linguagens de programação (somente GitHub - o GitLab reporta "N/A")
* Repositório com mais estrelas
* Data da última atividade

**Exemplos:**
```bash
# Relatório de inteligência completo
unauthscout torvalds --repos --summarize

# Inteligência específica do GitHub
unauthscout torvalds --github --repos --summarize
```

## Formatos de Saída

O UnauthScout oferece vários formatos de saída para diferentes casos de uso.

### Saída formatada padrão (legível por humanos)

Quando nenhuma opção de saída é especificada, o UnauthScout apresenta relatórios formatados e
codificados por cores, adequados para visualização no terminal.

``bash
unauthscout <nome de usuário>
unauthscout <nome de usuário> --repos
unauthscout <nome de usuário> --repos --summarize
```

**Características:**
* Cabeçalhos de plataforma codificados por cores
* Formatação de tabela limpa para repositórios
* Seção de resumo de inteligência (quando solicitada)
* Projetado para consumo humano direto

### JSON legível por máquina (compacto)

Otimizado para scripts e integração de pipelines.

```bash
unauthscout <nome de usuário> --raw
```

**Características:**
* JSON compacto (sem espaços em branco extras)
* Compatível com esquemas unificados (`unified_user.json`, `unified_repo.json`)
* Adequado para processamento e armazenamento de dados com `jq`
* O código de saída indica apenas sucesso/falha

**Exemplos:**
```bash
# Envia dados para o jq para extração de campos
unauthscout torvalds --raw | jq '.handle'

# Armazena para análise posterior
unauthscout torvalds --github --repos --raw > torvalds_gh.json
```

### JSON legível (formatado)

JSON com indentação para inspeção manual e depuração.

```bash
unauthscout <nome de usuário> --raw --pretty
```

**Características:**
* Estrutura JSON com indentação adequada
* Mais fácil de ler do que o formato compacto
* Ainda está em conformidade com os esquemas unificados
* Combina com todas as outras opções

**Exemplos:**
```bash
# Inspecionar a estrutura completa
unauthscout torvalds --raw --pretty | menos

# Depurar respostas do GitLab
unauthscout dzaporozhets --gitlab --repos --raw --pretty
```

## Exemplos de fluxo de trabalho

### Verificação rápida de perfil

```bash
unauthscout johndoe
```

*Objetivo: Verificar se um nome de usuário existe em qualquer plataforma.*

### Reconhecimento OSINT completo

```bash
unauthscout targetuser --repos --summarize
```

*Objetivo: Coletar informações completas, incluindo perfil, ativos e análises.*

### Integração de script

```bash
unauthscout targetuser --github --repos --raw | jq '.[].stars' | awk '{sum+=$1} END {print sum}'
```

*Objetivo: Extrair métricas específicas para geração de relatórios automatizados.*

### Análise comparativa

```bash
# Dados do GitHub
unauthscout targetuser --github --repos --raw > gh_data.json

# Dados do GitLab
unauthscout targetuser --gitlab --repos --raw > gl_data.json

# Comparação programática
diff <(jq '.[].full_name' gh_data.json | sort) <(jq '.[].full_name' gl_data.json | sort)
```

*Objetivo: Comparação multiplataforma de pegadas de ativos.*

## Comparação do Modo de Saída

| Modo | Comando | Ideal para | Tipo de Saída |

|------|---------|----------|-------------|
| **Relatório Formatado** | `unauthscout user` | Visualização no terminal, análise rápida | Texto com código de cores |
| **Formatado + Repositórios** | `unauthscout user -r` | Revisão de enumeração de ativos | Texto + tabela |
| **Formatado + Inteligência** | `unauthscout user -r -s` | Avaliação OSINT completa | Texto + tabela + resumo |

| **JSON de Máquina** | `unauthscout user --raw` | Scripting, pipelines, armazenamento | JSON compacto |

| **JSON Humano** | `unauthscout user --raw --pretty` | Depuração, inspeção manual | JSON com recuo |

| **Específico da Plataforma** | Adicione `--github` ou `--gitlab` | Reconhecimento focado | Todos os formatos acima |

## Erros Operacionais Comuns

### Nome de usuário ausente

**Erro**: Texto de ajuda exibido

**Solução**: Forneça um nome de usuário como o primeiro argumento não opcional

### Resumo sem enumeração de repositórios

**Erro**: `--summarize` requer `--repos`

**Solução**: Sempre combine `--summarize` com `--repos`

```bash
# Incorreto
unauthscout user --summarize

# Correto
unauthscout user --repos --summarize
```

### Formatação amigável sem o modo raw

**Observação**: `--pretty` só afeta a saída quando usado com `--raw`. Sem `--raw`,
a ferramenta usa seu modo de relatório formatado padrão, independentemente de `--pretty`.

## Considerações Específicas da Plataforma

### GitHub
- API rica e não autenticada com mais de 15 campos públicos
- Detecção de idioma disponível para repositórios
- Limites de taxa mais rigorosos (60 requisições/hora por IP)
- Metadados sociais (Twitter, localização, biografia)

### GitLab
- API limitada e não autenticada (5 campos principais de usuário)
- Detecção de idioma **não disponível** (retorna "N/A")
- Tags de repositório disponíveis através do campo `tag_list`
- Limites de taxa geralmente mais permissivos

### Disponibilidade de Campos
Alguns recursos de inteligência têm restrições de plataforma:

| Recurso de Inteligência | GitHub | GitLab | Observações |

|---------------------|--------|--------|-------|

| Principais Idiomas | ✅ | ❌ | A API do GitLab não expõe o idioma |

| Total de Estrelas | ✅ | ✅ | Ambas as plataformas fornecem a contagem de estrelas |

| Atividade Recente | ✅ | ✅ | Nomes de campos diferentes, mesmo conceito |

| Contagem de repositórios | ✅ | ❌ | O GitLab não expõe public_repos |

## Considerações sobre limitação de taxa

O UnauthScout não implementa evasão de limite de taxa. Esteja atento a:

* **GitHub**: ~60 requisições não autenticadas por hora por IP
* **GitLab**: Mais permissivo, mas ainda limita padrões abusivos

**Recomendações:**
* Espaçamento entre requisições ao escanear múltiplos alvos
* Use flags de plataforma para evitar chamadas desnecessárias
* Para uso intenso, considere implementar atrasos em scripts auxiliares

## Informações da Versão

Verifique sua versão do UnauthScout:

```bash
unauthscout --version
```

**Saída esperada**: `UnauthScout v0.3.0`

Veja a ajuda completa:

```bash
unauthscout --help
```

## Padrões de Uso Avançados

### Processamento em Lote

```bash
# Processar lista de nomes de usuário
for user in user1 user2 user3; do

unauthscout "$user" --github --repos --raw >> results.jsonl

sleep 2 # Respeitar limites de requisição
done
```

### Integração com outras ferramentas

```bash
# Alimentar o grep para correspondência de padrões
unauthscout targetuser --repos | grep -i "python"

# Contar repositórios por idioma (somente GitHub)
unauthscout targetuser --github --repos --raw | jq 'group_by(.language) | map({lang: .[0].language, count: length})'

# Criar linha do tempo de atividades
unauthscout targetuser --repos --raw | jq 'map(.updated_at[0:10]) | unique | ordenar'
```

### Execução condicional

```bash
# Prossiga somente se o usuário existir
if unauthscout targetuser --github --raw >/dev/null 2>&1; then

echo "Usuário existe, enumerando repositórios..."

unauthscout targetuser --github --repos --summarize
else

echo "Usuário não encontrado no GitHub"
fi
```

## Resumo

O UnauthScout v0.3.0 fornece uma interface de linha de comando flexível para reconhecimento OSINT não autenticado no GitHub e GitLab. A chave para um uso eficaz é
compreender a abordagem em camadas:

1. **Selecione as plataformas** (`--github`, `--gitlab` ou ambas)
2. **Escolha a profundidade** (perfil, repositórios, inteligência)
3. **Escolha o formato** (relatório formatado ou JSON para máquinas)

Comece com verificações de perfil simples e, em seguida, adicione enumeração de repositórios e
sumário de inteligência conforme necessário para seus objetivos de reconhecimento.
