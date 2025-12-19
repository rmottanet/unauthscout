# UnauthScout

O UnauthScout é uma ferramenta CLI para **reconhecimento OSINT não autenticado** em plataformas públicas
de desenvolvedores, como **GitHub** e **GitLab**.

Ele padroniza a coleta de dados de usuários disponíveis publicamente usando uma
interface consistente e **contratos de saída JSON normalizados**.


## Descrição do problema

As plataformas públicas de desenvolvedores expõem dados valiosos de reconhecimento sem exigir
autenticação. No entanto, esses dados costumam ser inconsistentes entre os provedores e
difíceis de consumir programaticamente.

O UnauthScout resolve isso:
- Consultando APIs públicas sem autenticação
- Normalizando respostas por meio de esquemas explícitos
- Fornecendo uma CLI simples e fácil de usar em scripts


## Recursos

- Reconhecimento de usuários não autenticados no GitHub
- Reconhecimento de usuários não autenticados no GitLab
- Saída JSON normalizada definida por esquemas explícitos
- Modo de saída bruta para depuração e descoberta de campo
- Arquitetura modular baseada em provedores


## Objetivos não alcançados

- Autenticação ou acesso baseado em token
- Contorno de limite de taxa
- Coleta de dados privados ou restritos
- Correlação ou enriquecimento automatizado entre plataformas


## Requisitos

- Bash (compatível com POSIX)
- `curl`
- `jq`


## Instalação

```bash
git clone https://github.com/rmottanet/unauthscout.git
cd unauthscout
chmod +x bin/unauthscout
````


## Uso

### Uso básico

```bash
unauthscout <username>
```

### Saída bruta (resposta API não processada)

```bash
unauthscout <username> --raw
```

Por padrão, o UnauthScout gera uma saída **JSON normalizada** que está em conformidade com o
esquema correspondente em `schemas/`.


## Contratos de saída

As saídas normalizadas são definidas por meio do esquema JSON:

* `schemas/github_user.json`
* `schemas/gitlab_user.json`

Esses esquemas são a **fonte de verdade** para todas as saídas processadas e garantem
estruturas de dados estáveis e previsíveis.


## Estrutura do projeto

```
bin/        # Ponto de entrada da CLI e orquestração
lib/        # Integrações de provedores e lógica de análise
schemas/    # Contratos de dados normalizados (esquema JSON)
docs/       # Documentação como código
tests/      # Testes automatizados (opcional)
```


## Princípios de design

* Não autenticado por padrão
* Contratos de dados explícitos sobre suposições implícitas
* Separação clara entre orquestração e recuperação de dados
* Área de superfície mínima, extensível por design

---

<br />
<br />
<div align="center">
  <a href="https://github.com/rmottanet/unauthscout"><img alt="Static Badge" src="https://img.shields.io/badge/-github?style=social&logo=github&logoSize=auto&label=GitHub&link=https%3A%2F%2Fgithub.com%2Frmottanet%2Funauthscout"></a>
  <a href="https://gitlab.com/rmottanet/unauthscout"><img alt="Static Badge" src="https://img.shields.io/badge/-gitlab?style=social&logo=gitlab&logoSize=auto&label=GitLab&link=https%3A%2F%2Fgitlab.com%2Frmottanet%2Funauthscout%23"></a>
</div>
