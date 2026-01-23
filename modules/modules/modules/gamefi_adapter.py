game_modules = {}

def register_game(name, handler):
    game_modules[name] = handler

def execute_game(name, payload):
    if name not in game_modules:
        return {"error": "Game module not found"}
    return game_modules[name](payload)
