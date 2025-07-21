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