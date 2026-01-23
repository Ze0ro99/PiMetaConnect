registry = {}

def register_hash(asset_id, ipfs_hash):
    registry[asset_id] = ipfs_hash
    return registry[asset_id]

def resolve_hash(asset_id):
    return registry.get(asset_id)
