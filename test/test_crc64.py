"""Equivalence tests for the pure-Python replacement of ``libscrc.iso``.

``zid`` values are persisted inside save files, so these tests are a
compatibility contract, not a smoke test: if they change, existing saves and
every cross-player reference break.
"""

import pytest

import crc64_go_iso

# Published CRC-64/GO-ISO check value: CRC("123456789") == 0xB90956C775A41001.
CHECK_INPUT = b"123456789"
CHECK_VALUE = crc64_go_iso.CRC64_GO_ISO_CHECK

# CRC-64/XZ shares the name "ISO CRC64" in some catalogs but uses a different
# polynomial. Guard against accidentally swapping them in.
CRC64_XZ_CHECK = 0x995DC9BBDF1939FA

# zid values the existing test-suite already assumes for `session.sid = "0"`.
ZID_FOR_SID_ZERO = 2341959767162880

PAYLOADS = (
    b"",
    b"0",
    b"1",
    b"session",
    CHECK_INPUT,
    bytes(range(256)),
    b"session:33130a4c-874d-4505-bf4e-53d41770806e",
)


def test_matches_published_check_value():
    assert crc64_go_iso.crc64_go_iso(CHECK_INPUT) == CHECK_VALUE


def test_is_not_crc64_xz():
    """CRC-64/XZ has a different polynomial; using it would shift every zid."""
    assert crc64_go_iso.crc64_go_iso(CHECK_INPUT) != CRC64_XZ_CHECK


def test_bitwise_reference_agrees_with_table():
    for payload in PAYLOADS:
        assert crc64_go_iso.crc64_go_iso_bitwise_reference(payload) == crc64_go_iso.crc64_go_iso(payload)


def test_is_unsigned_64_bit():
    for payload in PAYLOADS:
        value = crc64_go_iso.crc64_go_iso(payload)
        assert 0 <= value <= 0xFFFFFFFFFFFFFFFF


def test_zid_matches_value_hardcoded_in_the_existing_suite():
    """`battle_test.py` builds fleet names from this exact number."""
    assert crc64_go_iso.zid_from_sid("0") == ZID_FOR_SID_ZERO


@pytest.mark.parametrize("session_id", ["0", "1", "session"])
def test_zid_is_deterministic(session_id):
    assert crc64_go_iso.zid_from_sid(session_id) == crc64_go_iso.zid_from_sid(session_id)