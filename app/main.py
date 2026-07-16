from fastapi import FastAPI
import os

app = FastAPI(title="Secure Financial Microservice", version="1.0.0")

@app.get("/")
def read_root():
    return {"status": "healthy", "service": "finance-api"}

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/config")
def get_config():
    # Demonstrating reading non-sensitive config
    environment = os.getenv("ENVIRONMENT", "development")
    return {"environment": environment}
