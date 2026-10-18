/**
 * Reset one account's password.
 *
 * This exists because a stored hash can become unreadable without anybody
 * choosing that: argon2 only verifies against an encoding it can parse, and a
 * hash that has been mangled in transit -- truncated, re-encoded through a
 * driver that returned bytes, carried across an engine change -- raises
 * PASSWORD_INVALID_ENCODING instead of simply returning false. The symptom is a
 * login that 500s for every correct password, with nothing in the form to tell
 * you why.
 *
 * There is no route in the web surface for this on purpose: changing a password
 * means proving you can already log in. An account that cannot log in is exactly
 * the case that route cannot reach.
 *
 * Usage:
 *   bun run reset-password.ts <username> <new-password>
 *
 * The password is an argument rather than a prompt because this is run from a
 * terminal, where the shell history is a bigger problem than anything this script
 * can do about it -- so if that matters, edit the line below to read it instead.
 */
import { SQL } from 'bun';

const [, , username, password] = process.argv;

if (!username || !password) {
	console.error('uso: bun run reset-password.ts <usuario> <nueva-contrasena>');
	process.exit(2);
}
if (password.length < 8) {
	console.error('la contrasena debe tener al menos 8 caracteres');
	process.exit(2);
}

const url = process.env.RTE_DB_URL ?? 'mysql://root:2001@127.0.0.1:3306/raisetheempires';
const sql = new SQL(url);

try {
	const rows = (await sql.unsafe(
		'SELECT id, username, password_hash FROM users WHERE username_key = ?',
		[username.trim().toLowerCase()]
	)) as any[];

	if (!rows.length) {
		console.error(`no existe ninguna cuenta con ese usuario: ${username}`);
		process.exit(1);
	}

	const user = rows[0];

	// Why it is being reset, rather than just replacing it silently. A hash that
	// is merely wrong would have logged in and been changed; one that cannot be
	// parsed is corruption, and it is worth saying so out loud.
	const previousUsable = await Bun.password.verify(password, user.password_hash).catch(() => false);

	const hash = await Bun.password.hash(password, { algorithm: 'argon2id' });

	// Prove the new hash survives the same round trip before it replaces the old
	// one: write it, read it back, verify against what came back. Verifying the
	// in-memory value would pass even if the column mangles it again.
	await sql.unsafe('UPDATE users SET password_hash = ? WHERE id = ?', [hash, user.id]);
	const [readBack] = (await sql.unsafe('SELECT password_hash FROM users WHERE id = ?', [
		user.id
	])) as any[];

	let ok = false;
	try {
		ok = await Bun.password.verify(password, readBack.password_hash);
	} catch {
		ok = false;
	}

	if (!ok) {
		console.error(
			'ATENCION: la nueva hash se guardo pero no verifica al releerla.\n' +
				'Se ha restaurado la anterior; no se ha cambiado nada.'
		);
		await sql.unsafe('UPDATE users SET password_hash = ? WHERE id = ?', [
			user.password_hash,
			user.id
		]);
		process.exit(1);
	}

	console.log(`contrasena de ${user.username} (id ${user.id}) actualizada`);
	console.log(
		previousUsable
			? 'nota: la anterior tambien era valida'
			: 'nota: la anterior no servia (hash ilegible o distinto), por eso se reseteo'
	);
} finally {
	await sql.close();
}