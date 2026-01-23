assets = {}

def mint_asset(owner, uri):
    asset_id = f"PMCNFT-{len(assets)}"
    assets[asset_id] = {"owner": owner, "uri": uri}
    return asset_id

def transfer_asset(asset_id, new_owner):
    assets[asset_id]["owner"] = new_owner
