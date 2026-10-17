"""Temporal: ver exactamente como el SWF construye la URL del gateway."""
import pathlib
import re
import zlib

SWF = pathlib.Path(__file__).resolve().parent / "assets" / "ZGame.109338.swf"


def decompress(data: bytes) -> bytes:
    if data[:3] == b"CWS":
        return zlib.decompress(data[8:])
    return data[8:]


body = decompress(SWF.read_bytes())
strings = body

print("=== contexto alrededor de 'flashservices' ===")
for match in re.finditer(rb"flashservices", body):
    start = max(0, match.start() - 200)
    end = min(len(body), match.end() + 200)
    chunk = body[start:end]
    printable = re.sub(rb"[^\x20-\x7e]", b".", chunk).decode("ascii")
    print(printable)

print()
print("=== contexto alrededor de 'gateway.php' ===")
for match in re.finditer(rb"gateway\.php", body):
    start = max(0, match.start() - 250)
    end = min(len(body), match.end() + 120)
    chunk = body[start:end]
    printable = re.sub(rb"[^\x20-\x7e]", b".", chunk).decode("ascii")
    print(printable)

print()
print("=== literales de esquema de URL presentes en el SWF ===")
schemes = sorted({m.group().decode() for m in re.finditer(rb"[a-z]{2,6}://", body)})
print("  " + ", ".join(schemes) if schemes else "  (ninguno)")

print()
print("=== literales con 'flashservices' o rutas relativas Candidates ===")
for pattern in (rb"[A-Za-z0-9_./%-]{0,40}flashservices[A-Za-z0-9_./%-]{0,40}",
                rb"[A-Za-z0-9_./%-]{0,40}\.php"):
    found = {m.group().decode("ascii", "replace") for m in re.finditer(pattern, body)}
    for item in sorted(found)[:25]:
        print(f"  {item}")