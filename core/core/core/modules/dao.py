from core.ai_reputation import get_reputation

proposals = {}
votes = {}

def create_proposal(title, desc, creator):
    pid = len(proposals)
    proposals[pid] = {
        "title": title,
        "desc": desc,
        "creator": creator,
        "score": 0
    }
    return pid

def vote(user, pid):
    key = (user, pid)
    if key in votes:
        return False
    weight = max(1, int(get_reputation(user) + 1))
    votes[key] = True
    proposals[pid]["score"] += weight
    return True
