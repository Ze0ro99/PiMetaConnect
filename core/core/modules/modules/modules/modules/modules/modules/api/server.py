from fastapi import FastAPI
from modules.identity import register_user
from modules.dao import create_proposal, vote

app = FastAPI()

@app.post("/register")
def reg(data: dict):
    return register_user(data["uid"], data["wallet"])

@app.post("/proposal")
def prop(data: dict):
    return create_proposal(data["title"], data["desc"])

@app.post("/vote")
def v(data: dict):
    return vote(data["user"], data["pid"])
