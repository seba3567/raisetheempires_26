"""Drive /admin/sessions end to end, signed in, and delete a save from the UI.

The gateway delete is already proven. What this checks is the part the browser
exercises: the page renders the button, the form action reaches the gateway, and
the row disappears from the list afterwards.
"""
import http.cookiejar
import re
import urllib.parse
import urllib.request

BASE = "http://localhost:8080"
ORIGIN_HEADERS = {"Origin": BASE, "Referer": f"{BASE}/admin/sessions"}

jar = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))


def get(path):
    with opener.open(f"{BASE}{path}", timeout=30) as response:
        return response.status, response.read().decode("utf-8", "replace")


def post(path, data):
    body = urllib.parse.urlencode(data).encode()
    request = urllib.request.Request(
        f"{BASE}{path}", data=body,
        headers={**ORIGIN_HEADERS, "Content-Type": "application/x-www-form-urlencoded"})
    try:
        with opener.open(request, timeout=30) as response:
            return response.status, response.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as error:
        return error.code, error.read().decode("utf-8", "replace")


def rows(html):
    """(world, level, store_id) for every row of the sessions table."""
    found = []
    for block in html.split('</tr>'):
        cells = re.findall(r'<td[^>]*>(.*?)</td>', block, re.DOTALL)
        if len(cells) < 5:
            continue
        text = re.sub(r'<[^>]+>', ' ', block)
        level = re.search(r'(\d[\d.]*)', re.sub(r'session:[\w\-]+', '', text))
        key = re.search(r'session:[\w\-:]+', block)
        if key and level:
            found.append((key.group(0), level.group(1)))
    return found


print("1) login")
status, _ = post("/entrar", {"username": "seba3567", "password": "Osorio67"})
print(f"   -> {status}")

status, html = get("/admin/sessions")
print(f"2) pagina de sesiones -> {status}")
print(f"   boton Borrar en el HTML: {'Borrar esta partida' in html}")
listed = rows(html)
print(f"   filas listadas: {len(listed)} -> {listed}")

if not listed:
    raise SystemExit("no rows rendered; cannot test the delete")

store_id = listed[0][0]
print(f"3) borrando {store_id[:44]}...")
status, body = post("/admin/sessions?/delete", {"store_id": store_id})
print(f"   -> {status} {body[:100]}")

status, html = get("/admin/sessions")
after = rows(html)
print(f"4) despues -> {status}, filas: {len(after)} -> {after}")
print()
print("BORRADO DESDE EL FRONTEND:", "OK" if len(after) == len(listed) - 1 else "FALLO")