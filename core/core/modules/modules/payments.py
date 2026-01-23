from core.pi_client import send_pi_payment

def process_payment(user_wallet, amount, memo):
    return send_pi_payment(amount, memo, {"user": user_wallet})
