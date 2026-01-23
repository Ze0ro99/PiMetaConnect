from core.zk_identity import generate_proof, verify_proof
from core.ai_reputation import update_reputation

users = {}

def register_user(pi_uid, wallet, secret):
    proof = generate_proof(pi_uid, secret)
    users[wallet] = {
        "pi_uid": pi_uid,
        "proof": proof,
        "roles": ["user"],
        "rep": 0
    }
    return users[wallet]

def verify_user(wallet, secret):
    user = users.get(wallet)
    if not user:
        return False
    ok = verify_proof(user["pi_uid"], secret, user["proof"])
    if ok:
        user["rep"] = update_reputation(wallet, 1)
    return ok
