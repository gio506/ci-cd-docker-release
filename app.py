from fastapi import FastAPI
import os

app = FastAPI(title="ci-cd-docker-release")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/version")
def version() -> dict[str, str]:
    return {
        "version": os.getenv("APP_VERSION", "0.0.0-dev"),
        "commit": os.getenv("GIT_SHA", "local"),
    }
