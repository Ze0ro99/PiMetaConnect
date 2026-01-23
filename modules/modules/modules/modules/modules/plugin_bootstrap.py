from modules.gamefi_adapter import register_game
from modules.dex_adapter import register_dex

def sample_game(payload):
    return {"xp_gained": 10, "user": payload["user"]}

def sample_dex(trade):
    return {"status": "matched", "price": trade["price"], "amount": trade["amount"]}

register_game("RPG-Quest", sample_game)
register_dex("PiDEX-Core", sample_dex)
