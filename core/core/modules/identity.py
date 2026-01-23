users = {}

def register_user(pi_uid, wallet):
    users[wallet] = {
        "pi_uid": pi_uid,
        "roles": ["user"],
        "reputation": 0
    }
    return users[wallet]
