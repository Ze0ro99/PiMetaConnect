dex_modules = {}

def register_dex(name, handler):
    dex_modules[name] = handler

def execute_trade(dex_name, trade_data):
    if dex_name not in dex_modules:
        return {"error": "DEX not found"}
    return dex_modules[dex_name](trade_data)
