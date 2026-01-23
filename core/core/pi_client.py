from pi_network import Pi
from core.config import PI_API_KEY, PI_WALLET_SEED

pi = Pi(api_key=PI_API_KEY, wallet_private_seed=PI_WALLET_SEED)

def send_pi_payment(amount, memo, metadata):
    tx = pi.create_payment(amount=amount, memo=memo, metadata=metadata)
    pi.submit_payment(tx)
    return tx
