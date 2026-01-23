plugins = {}

def register_plugin(name, handler):
    plugins[name] = handler

def execute_plugin(name, payload):
    if name not in plugins:
        return None
    return plugins[name](payload)
