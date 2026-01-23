proposals = {}
votes = {}

def create_proposal(title, desc):
    pid = len(proposals)
    proposals[pid] = {"title": title, "desc": desc, "votes": 0}
    return pid

def vote(user, pid):
    key = (user, pid)
    if key in votes:
        return False
    votes[key] = True
    proposals[pid]["votes"] += 1
    return True
