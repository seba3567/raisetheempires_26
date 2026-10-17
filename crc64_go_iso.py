"""CRC-64/GO-ISO: the checksum behind the game's stable zone id (``zid``).

Why this module exists
----------------------
The original game derived a persistent player identifier from the session id::

    zid = libscrc.iso(session_id) // 2048

``zid`` is written into save files and cross-referenced between players, so the
algorithm must never change. ``libscrc`` is not a viable dependency in 2026:

* it publishes **no wheels** on PyPI (source distribution only), so installing
  it needs a C compiler -- MSVC on Windows, gcc elsewhere;
* nothing else in the project needs a native extension.

So this module reimplements the one function the project used, in pure Python
on top of the standard library.

Which CRC is it, exactly?
--------------------------
The name ``libscrc.iso`` is misleading: it is **not** a CRC-32. In
``libscrc``'s C sources, ``iso`` is registered on the CRC-64 module, documented
as "GO-IOS of CRC64 [Poly=0x1B, Init=0xFFFFFFFFFFFFFFFF, refin=True,
refout=True, xorout=0xFFFFFFFFFFFFFFFF]" -- i.e. **CRC-64/GO-ISO**:

    width=64  poly=0x000000000000001B  init=0xFFFFFFFFFFFFFFFF
    refin=true  refout=true  xorout=0xFFFFFFFFFFFFFFFF
    check("123456789")=0xB90956C775A41001

Do not confuse it with CRC-64/XZ (poly 0x42F0E1EBA9EA3693, check
0x995DC9BBDF1939FA), which is a different polynomial and would silently change
every ``zid``.

``crc64_go_iso_bitwise_reference`` is a deliberately naive, table-free version
of the same parameter set, used only so the fast table-driven path can be
tested without trusting a precomputed table. See ``test/test_crc64.py``.
"""

from __future__ import annotations

__all__ = [
    "CRC64_GO_ISO_CHECK",
    "build_table",
    "crc64_go_iso",
    "crc64_go_iso_bitwise_reference",
    "zid_from_sid",
]

# CRC-64/GO-ISO parameters (Rocksoft model).
_POLYNOMIAL = 0x000000000000001B
_POLYNOMIAL_REFLECTED = 0xD800000000000000
_INITIAL = 0xFFFFFFFFFFFFFFFF
_FINAL_XOR = 0xFFFFFFFFFFFFFFFF
_MASK64 = 0xFFFFFFFFFFFFFFFF

#: Published CRC-64/GO-ISO check value for the ASCII string "123456789".
CRC64_GO_ISO_CHECK = 0xB90956C775A41001

#: ``zid`` divides the checksum down to keep the number manageable.
_ZID_DIVISOR = 2048


def build_table(polynomial: int = _POLYNOMIAL_REFLECTED) -> tuple[int, ...]:
    """Return the 256-entry CRC-64 table for the reflected polynomial."""
    table = []
    for byte in range(256):
        crc = byte
        for _ in range(8):
            crc = (crc >> 1) ^ polynomial if crc & 1 else crc >> 1
        table.append(crc)
    return tuple(table)


_TABLE = build_table()


def crc64_go_iso(data: bytes) -> int:
    """Return the unsigned CRC-64/GO-ISO checksum of ``data``.

    Drop-in replacement for ``libscrc.iso(data)``.
    """
    crc = _INITIAL
    for byte in data:
        crc = _TABLE[(crc ^ byte) & 0xFF] ^ (crc >> 8)
    return (crc ^ _FINAL_XOR) & _MASK64


def crc64_go_iso_bitwise_reference(data: bytes) -> int:
    """Table-free CRC-64/GO-ISO, used only to cross-check :func:`crc64_go_iso`."""
    crc = _INITIAL
    for byte in data:
        crc ^= byte
        for _ in range(8):
            crc = (crc >> 1) ^ _POLYNOMIAL_REFLECTED if crc & 1 else crc >> 1
    return (crc ^ _FINAL_XOR) & _MASK64


def zid_from_sid(session_id: str) -> int:
    """Derive the stable zone id (``zid``) from a session id.

    The result is persisted inside save files and shared with other players, so
    the algorithm and the pinned values in ``test/test_crc64.py`` must not drift.
    """
    return crc64_go_iso(session_id.encode()) // _ZID_DIVISOR