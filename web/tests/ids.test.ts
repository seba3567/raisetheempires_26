/**
 * Cross-language equivalence contract for the zid derivation.
 *
 * These constants were produced by the Python reference (crc64_go_iso.py), not
 * by this implementation. If they change, every existing save and every
 * cross-player reference breaks, so this is a compatibility test and not a
 * smoke test.
 */
import { describe, expect, test } from "bun:test";

import {
  CRC64_GO_ISO_CHECK,
  crc64GoIso,
  crc64GoIsoBitwiseReference,
  zidForUser,
  zidForUserAsNumber,
  zidFromSessionId,
} from '#lib/ids';

/** Python: crc64_go_iso.CRC64_GO_ISO_CHECK */
const CHECK_VALUE = 13333283586479230977n;
/** Python: crc64_go_iso.zid_from_sid("0"), also hardcoded in battle_test.py */
const ZID_FOR_SID_ZERO = 2341959767162880n;
/** CRC-64/XZ shares the name "ISO CRC64" in some catalogs but is a different polynomial. */
const CRC64_XZ_CHECK = 0x995dc9bbdf1939fan;

/** [payload, expected] — expected values taken from the Python implementation. */
const VECTORS: ReadonlyArray<readonly [string, bigint]> = [
  ["", 0n],
  ["0", 4796333603149578240n],
  ["1", 4836865999795912704n],
  ["session", 4434983008330763328n],
  ["123456789", 13333283586479230977n],
  ["session:33130a4c-874d-4505-bf4e-53d41770806e", 14008447242477010670n],
];

describe("crc64GoIso", () => {
  test("matches the published CRC-64/GO-ISO check value", () => {
    expect(crc64GoIso("123456789")).toBe(CHECK_VALUE);
    expect(CRC64_GO_ISO_CHECK).toBe(CHECK_VALUE);
  });

  test("is not CRC-64/XZ", () => {
    // Same name in some catalogs, different polynomial. Swapping them in would
    // silently shift every zid.
    expect(crc64GoIso("123456789")).not.toBe(CRC64_XZ_CHECK);
  });

  test("agrees with the Python reference on every vector", () => {
    for (const [payload, expected] of VECTORS) {
      expect(`${payload}: ${crc64GoIso(payload)}`).toBe(`${payload}: ${expected}`);
    }
  });

  test("table path agrees with the bitwise reference", () => {
    const payloads: Array<string | Uint8Array> = [
      ...VECTORS.map(([payload]) => payload),
      new Uint8Array(256).map((_, i) => i),
    ];
    for (const payload of payloads) {
      expect(crc64GoIso(payload)).toBe(crc64GoIsoBitwiseReference(payload));
    }
  });

  test("accepts raw bytes, not just text", () => {
    const bytes = new Uint8Array(256);
    for (let i = 0; i < 256; i += 1) bytes[i] = i;
    expect(crc64GoIso(bytes)).toBe(9941672708500359133n);
  });
});

describe("zid derivation", () => {
  test("legacy session derivation still matches the existing test-suite", () => {
    // battle_test.py builds fleet names from this exact number.
    expect(zidFromSessionId("0")).toBe(ZID_FOR_SID_ZERO.toString());
  });

  test("is deterministic", () => {
    expect(zidFromSessionId("session")).toBe(zidFromSessionId("session"));
    expect(zidForUser(7)).toBe(zidForUser(7));
  });

  test("account zids match the Python derivation of the same id", () => {
    // Pinned from Python: crc64_go_iso(str(n)) // 2048
    expect(zidForUser(0)).toBe("2341959767162880");
    expect(zidForUser(1)).toBe("2361750976462848");
    expect(zidForUser(2)).toBe("2319969534607360");
    expect(zidForUser(3)).toBe("2260595906707456");
  });

  test("zid lands inside the range ActionScript can represent exactly", () => {
    // AS3 has no integer type; every Number is a double. That is the whole
    // reason the checksum is divided by 2048. If this ever fails, the uid sent
    // over AMF0 loses precision inside the SWF.
    const zid = zidForUser(42);
    expect(typeof zid).toBe("string");
    expect(BigInt(zid)).toBeLessThanOrEqual(BigInt(Number.MAX_SAFE_INTEGER));
    expect(zidForUserAsNumber(42)).toBe(Number(zid));
  });

  test("every account id in a realistic range yields a safe AMF0 number", () => {
    for (let i = 1; i <= 2000; i += 1) {
      const asNumber = zidForUserAsNumber(i);
      expect(Number.isSafeInteger(asNumber)).toBe(true);
      expect(asNumber.toString()).toBe(zidForUser(i));
    }
  });

  test("the raw checksum does NOT fit in a JS number, only the divided zid does", () => {
    // This is why ids.ts uses BigInt at all.
    expect(Number(crc64GoIso("0"))).not.toBe(BigInt(crc64GoIso("0")));
  });

  test("distinct accounts never collide", () => {
    const seen = new Set<bigint>();
    for (let i = 1; i <= 500; i += 1) seen.add(BigInt(zidForUser(i)));
    expect(seen.size).toBe(500);
  });
});