import time

rate_limit = {}

def check_rate(user_id, limit=5, window=60):
    now = time.time()
    logs = rate_limit.get(user_id, [])
    logs = [t for t in logs if now - t < window]
    if len(logs) >= limit:
        return False
    logs.append(now)
    rate_limit[user_id] = logs
    return True
