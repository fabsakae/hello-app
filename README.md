# Pipeline CI/CD com GitHub Actions e GitOps com ArgoCD `hello-app`
Este projeto demonstra uma automação completa de entrega de software, desde o código-fonte até a implantação em um cluster Kubernetes, utilizando as melhores práticas de Integração Contínua (CI), Entrega Contínua (CD) e GitOps.

### Objetivo:

Automatizar o ciclo completo de desenvolvimento, build, deploy e
execução de uma aplicação FastAPI simples, usando GitHub Actions para
CI/CD, Docker Hub como registry, e ArgoCD para entrega contínua em
Kubernetes local com MiniKube.

## Etapa 1 – Criar a aplicação FastAPI:

* Criar um repositório Git para o projeto `hello-app` com o arquivo
`main.py`. Arquivo Python com a lógica da aplicação FastAPI.

* Criar um `Dockerfile` para executar esse aplicativo, com instruções para construir a imagem Docker da aplicação.

* Criar um repositório Git para os manifestos do ArgoCD `hello-manifests`. Contém os arquivos YAML que descrevem o estado desejado da aplicação no Kubernetes `deployment.yaml e service.yaml`.

## Etapa 2 – Criar o GitHub Actions (CI/CD)

1. Criar o arquivo de workflow no github actions para buildar a imagem Docker da aplicação e fazer o push da imagem no Docker Hub, que será o nosso container registry neste projeto.

* Criar o arquivo de workflow do GitHub Actions: No  repositório local `hello-app`, criar a estrutura de pastas: `.github/workflows/`. Dentro de workflows, criar um arquivo YAML, `main-ci.yml` Ele automatiza a construção e publicação da imagem Docker e a atualização dos manifestos do Kubernetes.

```
Checkout code: Baixar o código do repositório hello-app para o ambiente onde o workflow será executado.

Login to Docker Hub: Usar os segredos para se autenticar no Docker Hub.

Build and push Docker image: Construir a imagem Docker da sua aplicação (usando o Dockerfile criado) e enviá-la para o Docker Hub. A imagem é taggeada com latest e com o SHA do commit (um identificador único do seu código) para controle de versão.

Checkout hello-manifests repository: Baixar o conteúdo do seu repositório hello-manifests (o que contém as configurações do Kubernetes) para que ele possa ser modificado.

Update image tag in manifest file: Este é um passo crucial para o GitOps. A ideia é que, uma vez que uma nova imagem Docker é criada e publicada, o workflow automaticamente atualize o arquivo de manifesto do Kubernetes (que estará no hello-manifests) para usar a nova tag da imagem (o SHA do commit). Isso garante que o ArgoCD (que monitora o hello-manifests) detecte a mudança e implante a nova versão da sua aplicação.
```

2.  Criar um Pull Request no repositório de manifestos `hello-manifests`, alterando a tag da imagem.

* Criação do Pull Request:

Em vez de fazer um git push direto para o main do hello-manifests (seria uma prática menos GitOps-friendly), utilizei a action peter-evans/create-pull-request@v6.

Esta action é configurada para criar automaticamente um novo Pull Request no repositório hello-manifests, em uma branch temporária (update-image-<SHA>) que aponta para a branch main.

O PR é criado com um título e corpo informativos, e labels como automation e image-update, facilitando a identificação.

Um Personal Access Token (PAT) do GitHub (secrets.GH_PAT_FOR_PR) é usado para autenticar a criação do PR, garantindo que o bot tenha as permissões necessárias.

* Revisão e Merge:

Este Pull Request aguarda revisão e, uma vez mesclado no main do hello-manifests, ele dispara a ação final de implantação.
OBS: o merge do PR é atualmente um passo manual para revisão, mas que poderia ser automatizado usando "regras de proteção de branch do GitHub" ou "ações de auto-merge", se a política de equipe permitisse.


3.  Criar os segredos no GitHub ( Evitar expor senhas e chaves diretamente no código do workflow.): `DOCKER_USERNAME, DOCKER_PASSWORD, SSH_PRIVATE_KEY, GH_PAT_FOR_PR`.
* Os segredos são necessários no GitHub para autenticação no Docker Hub e acesso ao outro repositório. Os três segredos no repositório `hello-app` para permitir que o GitHub Actions se autentique no Docker Hub: `DOCKER_USERNAME, DOCKER_PASSWORD` (Personal Access Token (PAT) do Docker Hub), `SSH_PRIVATE_KEY` (A chave SSH privada que o GitHub Actions usará para clonar/fazer PR no repositório hello-manifests.).

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

4. Criar uma Pipeline de CI/CD com GitHub Actions `main-ci.yml`. Este workflow automatiza a construção da imagem Docker e a atualização do manifesto Kubernetes. O arquivo `YAML .github/workflows/main-ci.yml` que define os passos automatizados. Garante que cada alteração no código seja automaticamente buildada, testada e preparada para implantação.

## Etapa 3 - Repositório Git com os manifests do ArgoCD

# Objetivos da Etapa 3:

* Criar os arquivos de manifesto Kubernetes `deployment.yaml e service.yaml` para a sua aplicação hello-app dentro do repositório hello-manifests.

* Subpasta hello-manifests:

```Bash

mkdir ~/github-projetos/git-argocd/hello-manifests
```
* Navegar para essa nova pasta:

```Bash

cd ~/github-projetos/git-argocd/hello-manifests
```

1. Acesse o Pull Request que o GitHub Actions acabou de criar no repositório hello-manifests. 

2. Faça o "Merge" do Pull Request: Isso irá mesclar a nova branch com o k8s/deployment.yaml para a branch main do seu hello-manifests.

3. Clonar seu repositório hello-manifests do GitHub para esta pasta: Dentro da pasta k8s, editar o deployment.yaml e criar o service.yaml. 

```Bash

git clone https://github.com/fabsakae/hello-manifests.git .
```

* O `deployment.yaml` definirá como o Kubernetes irá implantar sua aplicação (qual imagem usar, quantos pods, etc.). O `deployment.yaml` com o conteúdo atualizado `replicas: 1, image: fabsakae/hello-app:latest, port: 8000`.

```Bash
code k8s/deployment.yaml
```
* O `service.yaml` definirá como sua aplicação será exposta dentro e fora do cluster. O `service.yaml` criado com a configuração de LoadBalancer para a porta 80, roteando para a porta 8000 do contêiner.

```Bash
touch k8s/service.yaml
code k8s/service.yaml
```
* O arquivo placeholder k8s/deployment.yaml que o workflow criou no Pull Request atual será o ponto de partida para o deployment.yaml real. O repositório hello-manifests com os arquivos de manifesto Kubernetes (deployment.yaml e service.yaml) prontos para serem usados pelo ArgoCD.

## Etapa 4 – Criar o App no ArgoCD
• Na interface do ArgoCD criar o vínculo com o repositório de manifestos.

1. Verifique se o Minikube está instalado:

```Bash

minikube status
```
2. inicie-o:

```Bash

minikube start
```
3. Verifique a instalação do ArgoCD:

```Bash

kubectl port-forward svc/argocd-server -n argocd 8080:443
```
4. Acessar https://localhost:8080 no navegador.

• Criar a aplicação no ArgoCD:

1. Clique em + New App.

2. Preencha os detalhes:

3. Application Name: `hello-app`

4. Project: default

5. Sync Policy: Automatic (com PRUNE e SELF HEAL marcados).

6. Repository URL: https://github.com/fabsakae/hello-manifests.git

7. Revision: HEAD

8. Path: k8s

9. Cluster Name: in-cluster

10. Namespace: default

11. Create.

O ArgoCD começará a sincronizar e detectará o deployment.yaml e o service.yaml em hello-manifests/k8s e tentará criá-los no seu cluster Minikube.

## Etapa 5 – Acessar e testar a aplicação localmente
# 1. Verifique o status dos pods no Minikube:

```Bash
kubectl get pods -n default -l app=hello-app
```
1.1. Verifique o status do serviço no Minikube:
```Bash
kubectl get svc -n default hello-app-service
```
1.2. Como estou usando o Minikube, em um outro terminal:
```Bash
minikube tunnel
```
1.3. Acesse a aplicação via navegador (o EXTERNAL-IP deve mostrar um IP 127.0.0.1):
```Bash
kubectl get svc -n default hello-app-service
```
1.4. Acesse a aplicação:
* No navegador web, digite o endereço: http://127.0.0.1:80

* Ou, usando curl no terminal WSL/Ubuntu:
```Bash
curl http://127.0.0.1:80
```
# 2. Alterar o repositório da aplicação:
2.1. Modificar a mensagem dentro do código python de Hello World para  outra mensagem. Modificar o `main.py` para disparar o pipeline completo. Alterei a mensagem de retorno na função root(): Adicionei "V2 Hello from CI/CD Pipeline! PROJETO CI/CD com GITHUB ACTIONS - DevSecOps! DOCKER HUB como registry, e ArgoCD para entrega contínua em kUBERNETES local com MINIKUBE"".
2.2. Verificar se, após o processo de CI/CD, a imagem foi atualizada no ambiente Kubernetes.