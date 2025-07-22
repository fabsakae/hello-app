from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "V2 Hello from CI/CD Pipeline! PROJETO CI/CD com GITHUB ACTIONS - DevSecOps! DOCKER HUB como registry, e ArgoCD para entrega contínua em kUBERNETES local com MINIKUBE"}