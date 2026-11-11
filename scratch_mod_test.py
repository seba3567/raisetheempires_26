import importlib.util
spec = importlib.util.spec_from_file_location("es", "empires-server.py")
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
app = m.configure_app()
from fastapi_session import session as fs_session
with app.test_request_context():
    fs_session['user_object'] = {"userInfo": {"player": {"uid": 123, "level": 1}, "worldName": "Test", "world": {"resources": {"coins": 100}}}}
    from flask import session as flask_session
    print("flask modified:", flask_session.modified)
    print("proxy modified:", fs_session.modified)
