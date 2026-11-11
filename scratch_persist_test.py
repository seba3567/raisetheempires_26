import importlib.util
spec = importlib.util.spec_from_file_location("es", "empires-server.py")
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
app = m.configure_app()
from pyamf import AMF0, remoting
import urllib.request
# Simulate AMF call
body = [{'flashRevision': None}, [{'transaction': None, 'sequence': 1, 'stamp': 1.0, 'params': [], 'functionName': 'UserService.initUser'}], 0]
env = remoting.Envelope(AMF0)
env.bodies = [('/2', remoting.Request('BaseService.dispatchBatch', body=body))]
raw = remoting.encode(env).getvalue()
# Use test client
with app.test_client() as c:
    resp = c.post("/files/empire-s.assets.zgncdn.com/assets/109338/127.0.0.1flashservices/gateway.php", data=raw, content_type="application/x-amf")
    print("AMF status:", resp.status_code)
    from save_engine import get_saves
    saves = get_saves()
    print("saves count:", len(saves))
    if saves:
        print("uid:", saves[0].get("user_object", {}).get("userInfo", {}).get("player", {}).get("uid"))