/**
 * Signed cookie sessions.
 *
 * The cookie carries only the account id plus an HMAC. No server-side session
 * table is needed, and nothing here is Facebook-related: this replaces the
 * OAuth handshake the original game used.
 *
 * SvelteKit 3 note: `redirect()` no longer takes cookies, they go through
 * `event.cookies.set()`. That API defaults `path` to '/' and `secure` to true
 * outside development, so both are set explicitly here — a Secure cookie on a
 * plain-HTTP request is silently dropped by the client, which looks exactly
 * like "login does not stick".
 */
import type { Cookies } from '@sveltejs/kit';

import { config } from './config.ts';

const encoder = new TextEncoder();

function secretKey(): Promise<CryptoKey> {
	const secret = config.session.secret;
	if (!secret) {
		throw new Error(
			'SESSION_SECRET is not set. Generate one with: bun -e "console.log(crypto.randomUUID()+crypto.randomUUID())"',
		);
	}
	return crypto.subtle.importKey(
		'raw',
		encoder.encode(secret),
		{ name: 'HMAC', hash: 'SHA-256' },
		false,
		['sign', 'verify'],
	);
}

async function sign(payload: string): Promise<string> {
	const key = await secretKey();
	const mac = await crypto.subtle.sign('HMAC', key, encoder.encode(payload));
	return [...new Uint8Array(mac)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

function base64url(bytes: Uint8Array): string {
	let binary = '';
	for (const byte of bytes) binary += String.fromCharCode(byte);
	return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
}

function fromBase64url(value: string): Uint8Array {
	const padded = value.replaceAll('-', '+').replaceAll('_', '/');
	const binary = atob(padded.padEnd(Math.ceil(padded.length / 4) * 4, '='));
	return Uint8Array.from(binary, (c) => c.charCodeAt(0));
}

function parseCookies(header: string | null): Record<string, string> {
	const jar: Record<string, string> = {};
	if (!header) return jar;
	for (const part of header.split(';')) {
		const index = part.indexOf('=');
		if (index < 0) continue;
		jar[part.slice(0, index).trim()] = decodeURIComponent(part.slice(index + 1).trim());
	}
	return jar;
}

/** Mint a session cookie value for an account id. */
export async function createSessionValue(userId: number): Promise<string> {
	const payload = `${userId}.${Date.now().toString(36)}`;
	return `${base64url(encoder.encode(payload))}.${await sign(payload)}`;
}

/** Verify a cookie header and return the account id, or null if untrusted. */
export async function readSession(req: Request): Promise<number | null> {
	const value = parseCookies(req.headers.get('cookie'))[config.session.cookieName];
	if (!value) return null;

	const [encoded, mac] = value.split('.');
	if (!encoded || !mac) return null;

	let payload: string;
	try {
		payload = new TextDecoder().decode(fromBase64url(encoded));
	} catch {
		return null;
	}

	const expected = await sign(payload);
	// Constant-time compare; lengths must match first or timing leaks length.
	if (mac.length !== expected.length) return null;
	let diff = 0;
	for (let i = 0; i < mac.length; i += 1) {
		diff |= mac.charCodeAt(i) ^ expected.charCodeAt(i);
	}
	if (diff !== 0) return null;

	const userId = Number.parseInt(payload.split('.')[0] ?? '', 10);
	return Number.isSafeInteger(userId) && userId > 0 ? userId : null;
}

export async function setSessionCookie(
	cookies: Cookies,
	userId: number,
	secure: boolean
): Promise<void> {
	const value = await createSessionValue(userId);
	cookies.set(config.session.cookieName, value, {
		path: '/',
		httpOnly: true,
		sameSite: 'lax',
		secure,
		maxAge: config.session.maxAgeSeconds
	});
}

export function clearSessionCookie(cookies: Cookies): void {
	cookies.delete(config.session.cookieName, { path: '/' });
}

/**
 * Whether the session cookie should carry the Secure attribute.
 *
 * Derived from the request rather than from config.host: listening on 0.0.0.0
 * says nothing about the scheme, and a Secure cookie over plain HTTP is
 * silently dropped by the client, which looks exactly like "login does not
 * stick". `x-forwarded-proto` is honoured for the case where TLS terminates at
 * a proxy in front of this service.
 */
export function isSecureRequest(req: Request): boolean {
	const forwarded = req.headers.get('x-forwarded-proto');
	if (forwarded) return forwarded.split(',')[0]?.trim() === 'https';
	return new URL(req.url).protocol === 'https:';
}