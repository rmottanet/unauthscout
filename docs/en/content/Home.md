# UnauthScout Documentation

**Welcome to the official documentation** for UnauthScout – the unauthenticated reconnaissance tool for Git platforms.

> ⚡ **Quick Start**: [Install in 30 seconds](#-quick-reference)


## 📚 Documentation Philosophy

This wiki follows **DRY (Don't Repeat Yourself)** principles:

- **README.md** → Project overview, installation, quick examples
- **Wiki** → Comprehensive documentation, tutorials, deep dives
- **Schemas/** → Source of truth for data contracts
- **Code** → Self-documenting where possible

> **Synced with code**: This documentation is maintained alongside the codebase. Found an issue? [Edit this page](https://github.com/rmottanet/unauthscout/blob/main/docs/en/content/Home.md).


## 📢 What's New

### Versão mais recente: [v0.2.0](https://github.com/rmottanet/unauthscout/releases/tag/v0.2.0)
- **Enumeração de repositórios** – Listagem de repositórios de usuários para GitHub e GitLab
- Documentação expandida de mapeamento de campos da API
- Atualizações de documentação multilíngue (EN/PT)
- CLI aprimorada com suporte à flag `--repos`

### Versão anterior: [v0.1.0](https://github.com/rmottanet/unauthscout/releases/tag/v0.1.0)
- Enumeração de usuários do GitLab
- Saída JSON normalizada via esquemas
- Interface CLI básica
- Base para arquitetura baseada em provedores

### Atualmente em desenvolvimento (v0.3.0)
- **Normalização e inteligência resumida** – Transformação de dados brutos do provedor em insights de reconhecimento unificados
- Comparação de dados aprimorada entre plataformas
- Resumo inteligente de pegadas de usuários e repositórios
- Base para correlação e relatórios entre fornecedores


## 📌 Important Notes

### Ethical Use
UnauthScout is designed for **legitimate security assessment, auditing, and research**. Use responsibly:
- Respect platform rate limits
- Only query public data
- Follow each provider's Terms of Service

### Limitations
- No authentication support (by design)
- Rate-limited by providers
- Public data only
- No correlation across platforms


## Support & Community

- **Issues**: [Bug reports & feature requests](https://github.com/rmottanet/unauthscout/issues)
- **Discussions**: [Q&A and ideas](https://github.com/rmottanet/unauthscout/discussions)
- **Contributing**: [See how to help](https://github.com/rmottanet/unauthscout/CONTRIBUTING.md)


## ⚡ Quick Reference

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
