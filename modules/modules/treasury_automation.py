from modules.treasury import treasury

AUTOMATION_RULES = {
    "auto_invest_threshold": 1000,
    "reserve_ratio": 0.3
}

def automate_treasury():
    balance = treasury["balance"]
    reserve = balance * AUTOMATION_RULES["reserve_ratio"]
    investable = balance - reserve

    return {
        "balance": balance,
        "reserve": reserve,
        "investable": investable,
        "status": "automation_executed"
    }
