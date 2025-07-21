# hello-app
Práticas de automação no ciclo de desenvolvimento com GitHub Actions e ArgoCD.

### Objetivo:

Automatizar o ciclo completo de desenvolvimento, build, deploy e
execução de uma aplicação FastAPI simples, usando GitHub Actions para
CI/CD, Docker Hub como registry, e ArgoCD para entrega contínua em
Kubernetes local com Rancher Desktop.

# Etapa 1 – Criar a aplicação FastAPI:

* Criar um repositório Git para o projeto `hello-app` com o arquivo
main.py.

* Criar um Dockerfile para executar esse aplicativo.

* Criar um repositório Git para os manifestos do ArgoCD `hello-manifests`.

# Etapa 2 – Criar o GitHub Actions (CI/CD)

* Criar o arquivo de workflow no github actions para buildar a imagem Docker da aplicação e fazer o push da imagem no Docker Hub, que será o nosso container registry neste projeto.

* Criar um Pull Request no repositório de manifestos `hello-manifests`, alterando a tag da imagem.

* Criar os segredos no GitHub: DOCKER_USERNAME, DOCKER_PASSWORD, SSH_PRIVATE_KEY, GH_PAT_FOR_PR.Os segredos são necessários no GitHub para autenticação no Docker Hub e acesso ao outro repositório. Os três segredos no repositório `hello-app` para permitir que o GitHub Actions se autentique no Docker Hub: `DOCKER_USERNAME, DOCKER_PASSWORD` (Personal Access Token (PAT) do Docker Hub), `SSH_PRIVATE_KEY` (A chave SSH privada que o GitHub Actions usará para clonar/fazer PR no repositório hello-manifests.).

*  Adicionar SSH_PRIVATE_KEY no GitHub (Repositório hello-app)
```
cat ~/.ssh/github_actions_key
```
* Adicionar a Chave Pública como Deploy Key (Repositório hello-manifests)
```
cat ~/.ssh/github_actions_key.pub
```
(Adicionar como Deploy Key no GitHub, MUITO IMPORTANTE: Marquar a caixa Allow write access (Permitir acesso de gravação). Isso é essencial para que o GitHub Actions possa fazer Pull Requests neste repositório.)

* Adicionar `GH_PAT_FOR_PR` (Personal Access Token (PAT) no GitHub) no Repositório hello-app como segredos no GitHub. O GH_PAT_FOR_PR (Personal Access Token do GitHub) é usado especificamente pela action peter-evans/create-pull-request para ter permissão de criar um Pull Request no hello-manifests.

* Criar o arquivo de workflow do GitHub Actions: No  repositório local `hello-app`, criar a estrutura de pastas: `.github/workflows/`. Dentro de workflows, criar um arquivo YAML, `main-ci.yml` Ele automatiza a construção e publicação da imagem Docker e a atualização dos manifestos do Kubernetes.
```
Checkout code: Baixar o código do repositório hello-app para o ambiente onde o workflow será executado.

Login to Docker Hub: Usar os segredos para se autenticar no Docker Hub.

Build and push Docker image: Construir a imagem Docker da sua aplicação (usando o Dockerfile criado) e enviá-la para o Docker Hub. A imagem é taggeada com latest e com o SHA do commit (um identificador único do seu código) para controle de versão.

Checkout hello-manifests repository: Baixar o conteúdo do seu repositório hello-manifests (o que contém as configurações do Kubernetes) para que ele possa ser modificado.

Update image tag in manifest file: Este é um passo crucial para o GitOps. A ideia é que, uma vez que uma nova imagem Docker é criada e publicada, o workflow automaticamente atualize o arquivo de manifesto do Kubernetes (que estará no hello-manifests) para usar a nova tag da imagem (o SHA do commit). Isso garante que o ArgoCD (que monitora o hello-manifests) detecte a mudança e implante a nova versão da sua aplicação.

Create Pull Request: Em vez de fazer a alteração diretamente, o workflow cria um Pull Request no repositório hello-manifests. Isso é uma boa prática em GitOps: permite revisão humana das mudanças nos manifestos antes que elas sejam aplicadas ao cluster pelo ArgoCD.
```


* Ter acesso de gravação ao repositório de manifests usado pelo ArgoCD