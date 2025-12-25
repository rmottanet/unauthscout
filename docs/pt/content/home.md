# Documentação do UnauthScout

**Bem-vindo à documentação oficial** do UnauthScout – a ferramenta de reconhecimento não autenticado para plataformas Git.

> ⚡ **Início Rápido**: [Instale em 30 segundos](#-Referência-Rápida)

## 📚 Filosofia da Documentação

Esta wiki segue os princípios **DRY (Don't Repeat Yourself - Não se Repita)**:

- **README.md** → Visão geral do projeto, instalação, exemplos rápidos
- **Wiki** → Documentação completa, tutoriais, análises detalhadas
- **Schemas/** → Fonte de verdade para contratos de dados
- **Código** → Autodescritivo sempre que possível

> **Sincronizado com o código**: Esta documentação é mantida juntamente com a base de código. Encontrou um problema? [Editar esta página](https://github.com/rmottanet/unauthscout/blob/main/docs/en/content/Home.md).

## 📢 Novidades

### Versão mais recente: [v0.3.0](https://github.com/rmottanet/unauthscout/releases/tag/v0.3.0)
- Camada unificada de metadados e inteligência – Esquemas normalizados e resumos analíticos
- Relatórios inteligentes com a flag `--summarize`
- Análise de repositórios entre provedores (total de estrelas, principais idiomas, insights de atividade)
- CLI aprimorada com a flag `--pretty` para saída JSON formatada

### Versão anterior: v0.2.0
- Enumeração de repositórios – Listagem de repositórios de usuários para GitHub e GitLab
- Documentação expandida de mapeamento de campos da API
- Atualizações da documentação multilíngue (EN/PT)
- CLI aprimorada com suporte à flag `--repos`

## 📌 Observações importantes

### Uso ético
O UnauthScout foi projetado para **avaliação, auditoria e pesquisa de segurança legítimas**. Use com responsabilidade:
- Respeite os limites de requisições da plataforma
- Consulte apenas dados públicos
- Siga os Termos de Serviço de cada provedor

### Limitações
- Sem suporte para autenticação (por design)
- Requisições limitadas pelos provedores
- Apenas dados públicos
- Sem correlação entre plataformas

## Suporte e Comunidade

- **Problemas**: [Relatórios de bugs e solicitações de recursos](https://github.com/rmottanet/unauthscout/issues)
- **Discussões**: [Perguntas e respostas e ideias](https://github.com/rmottanet/unauthscout/discussions)
- **Contribuição**: [Veja como ajudar](https://github.com/rmottanet/unauthscout/CONTRIBUTING.md)

## ⚡ Referência Rápida

```bash
# Installation (from source)
git clone https://github.com/rmottanet/unauthscout.git
cd unauthscout
chmod +x bin/unauthscout

# Add to PATH (optional)
export PATH="$PATH:$(pwd)/bin"

# First scan
unauthscout octocat --provider github
```
