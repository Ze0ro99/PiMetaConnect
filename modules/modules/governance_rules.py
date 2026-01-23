from core.ai_reputation import reputations

SLASHING_RULES = {
    "spam_vote": -2,
    "double_vote": -5,
    "malicious_proposal": -10
}

def slash_user(user, violation_type):
    penalty = SLASHING_RULES.get(violation_type, 0)
    reputations[user] = reputations.get(user, 0) + penalty
    return {
        "user": user,
        "violation": violation_type,
        "new_reputation": reputations[user]
    }

def governance_guard(user, action):
    if reputations.get(user, 0) < -5:
        return False
    return True
