treasury = {"balance": 0}

def deposit(amount):
    treasury["balance"] += amount

def spend(amount):
    if treasury["balance"] >= amount:
        treasury["balance"] -= amount
        return True
    return False
