import hashlib

def generate_proof(pi_uid, secret):
    data = f"{pi_uid}:{secret}"
    return hashlib.sha256(data.encode()).hexdigest()

def verify_proof(pi_uid, secret, proof):
    return generate_proof(pi_uid, secret) == proof
