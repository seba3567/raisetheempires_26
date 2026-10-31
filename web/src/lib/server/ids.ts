/**
 * CRC-64/GO-ISO and the game's stable zone id (``zid``).
 *
 * This is a faithful port of ``crc64_go_iso.py``. The two implementations must
 * agree bit for bit, because the Python gateway and this service both need to
 * produce the same ``zid`` for the same player. ``tests/ids.test.ts`` pins the
 * published check value and the cross-language fixtures from the Python suite.
 *
 * Which CRC is it, exactly?
 * -----------------------
 * The original code called ``libscrc.iso(...)``, whose name is misleading: in
 * libscrc ``iso`` is registered on the CRC-64 module and documented as
 * "GO-IOS of CRC64 [Poly=0x1B, Init=0xFFFFFFFFFFFFFFFF, refin=True,
 * refout=True, xorout=0xFFFFFFFFFFFFFFFF]". So this is CRC-64/GO-ISO:
 *
 *     width=64  poly=0x000000000000001B  init=0xFFFFFFFFFFFFFFFF
 *     refin=true  refout=true  xorout=0xFFFFFFFFFFFFFFFF
 *     check("123456789")=0xB90956C775A41001
 *
 * Not CRC-64/XZ (poly 0x42F0E1EBA9EA3693), which would silently change every zid.
 */
import { contract } from './contract.ts';

const POLYNOMIAL_REFLECTED = 0xd800000000000000n;
const INITIAL = 0xffffffffffffffffn;
const FINAL_XOR = 0xffffffffffffffffn;

/** Published CRC-64/GO-ISO check value for the ASCII string "123456789". */
export const CRC64_GO_ISO_CHECK = 0xb90956c775a41001n;

/**
 * zid divides the checksum down to keep the number manageable.
 *
 * The divisor is a contract with the gateway: both sides derive the player's
 * id this way, so a change on one side has to change on the other. It is
 * written down once, in `contract/runtime.json`.
 */
const ZID_DIVISOR = BigInt(contract.zid.divisor);

/**
 * The largest player id the Flash client can be told about.
 *
 * ActionScript 3 has no integer type, so every Number is a double and only
 * the integers up to 2^53-1 are exact. The gateway refuses a larger id from
 * the header, and this side refuses to send one.
 */
const MAX_SAFE_ZID = contract.zid.maxSafe;

function buildTable(): bigint[] {
  const table: bigint[] = new Array<bigint>(256);
  for (let byte = 0; byte < 256; byte += 1) {
    let crc = BigInt(byte);
    for (let i = 0; i < 8; i += 1) {
      crc = (crc & 1n) === 1n ? (crc >> 1n) ^ POLYNOMIAL_REFLECTED : crc >> 1n;
    }
    table[byte] = crc;
  }
  return table;
}

const TABLE = buildTable();

/** Return the unsigned CRC-64/GO-ISO checksum of `data`. */
export function crc64GoIso(data: Uint8Array | string): bigint {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : data;
  let crc = INITIAL;
  for (const byte of bytes) {
    const index = Number((crc ^ BigInt(byte)) & 0xffn);
    crc = (TABLE[index] as bigint) ^ (crc >> 8n);
  }
  return crc ^ FINAL_XOR;
}

/**
 * Table-free CRC-64/GO-ISO, kept so the fast table path can be cross-checked
 * without trusting a precomputed table. Mirrors the Python reference.
 */
export function crc64GoIsoBitwiseReference(data: Uint8Array | string): bigint {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : data;
  let crc = INITIAL;
  for (const byte of bytes) {
    crc ^= BigInt(byte);
    for (let i = 0; i < 8; i += 1) {
      crc = (crc & 1n) === 1n ? (crc >> 1n) ^ POLYNOMIAL_REFLECTED : crc >> 1n;
    }
  }
  return crc ^ FINAL_XOR;
}

/**
 * The legacy derivation: zid from a Flask session id.
 *
 * Kept only for migration: the Python gateway still assigns the player uid from
 * the session cookie, so an existing save is filed under this value.
 */
export function zidFromSessionId(sessionId: string): string {
  return (crc64GoIso(sessionId) / ZID_DIVISOR).toString();
}

/**
 * The account derivation: zid from a stable account id.
 *
 * This is what makes identity durable. The legacy value moves whenever the
 * session cookie is regenerated, which can split one player's save in two; an
 * account id does not change on logout, password change or cookie rotation.
 *
 * Returned as a string on purpose. See {@link zidForUserAsNumber} for why the
 * arithmetic is safe but the string form is what gets stored.
 */
export function zidForUser(userId: number | bigint): string {
  return (crc64GoIso(userId.toString()) / ZID_DIVISOR).toString();
}

/**
 * The same value as a JS number, for handing it to the AMF0 gateway.
 *
 * ActionScript 3 has no integer type: every Number is a double, so the game
 * can only represent integers exactly up to 2^53-1. That is the reason the
 * original code divides the 64-bit checksum down by 2048 — not to make the
 * number prettier, but to land inside the client's exact integer range.
 *
 * Because of that, `zid` must be sent as an AMF0 *number*. Handing the gateway
 * the string form would reach the SWF as a String and the player uid would
 * silently become text, so keep the two conversions explicit.
 */
export function zidForUserAsNumber(userId: number | bigint): number {
  const value = Number(zidForUser(userId));
  if (!Number.isSafeInteger(value) || value > MAX_SAFE_ZID) {
    throw new RangeError(`zid for user ${userId} is not a safe integer: ${value}`);
  }
  return value;
}