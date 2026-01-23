def bridge(chain, data):
    return {
        "target_chain": chain,
        "status": "queued",
        "payload": data
    }
