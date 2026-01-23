from fastapi import FastAPI
from modules.identity import register_user, verify_user
from modules.dao import create_proposal, vote

app = FastAPI()

@app.post("/register")
def reg(data: dict):
    return register_user(data["uid"], data["wallet"], data["secret"])

@app.post("/verify")
def ver(data: dict):
    return verify_user(data["wallet"], data["secret"])

@app.post("/proposal")
def prop(data: dict):
    return create_proposal(data["title"], data["desc"], data["creator"])

@app.post("/vote")
def v(data: dict):
    return vote(data["user"], data["pid"])
