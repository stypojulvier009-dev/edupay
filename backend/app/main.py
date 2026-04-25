from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .database import engine
from . import models
from .routers import (
    auth, abonnements, geolocalisation, ecoles, classes,
    parents, etudiants, frais, echeanciers, paiements,
    notifications, rapports, audit
)

models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="EduPay API",
    description="API de paiement electronique des frais scolaires",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(abonnements.router)
app.include_router(geolocalisation.router)
app.include_router(ecoles.router)
app.include_router(classes.router)
app.include_router(parents.router)
app.include_router(etudiants.router)
app.include_router(frais.router)
app.include_router(echeanciers.router)
app.include_router(paiements.router)
app.include_router(notifications.router)
app.include_router(rapports.router)
app.include_router(audit.router)

@app.get("/")
def root():
    return {"message": "EduPay API is running"}
