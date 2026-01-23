from core.pi_client import pi

def validate_pi_payment(payment_id):
    """
    Validate payment directly from Pi Network blockchain via Pi SDK
    """
    try:
        payment = pi.get_payment(payment_id)
        if payment["status"] == "completed":
            return {
                "valid": True,
                "amount": payment["amount"],
                "from": payment["from_address"],
                "to": payment["to_address"],
                "memo": payment["memo"]
            }
        return {"valid": False, "reason": "Payment not completed"}
    except Exception as e:
        return {"valid": False, "error": str(e)}
