/**
 * Test bootstrap.
 *
 * Runs before any module is imported, so config.ts picks these up.
 *
 * The tests get real SQL against a real database rather than a mocked driver,
 * which is the only way to catch a migration that does not apply. That makes
 * the target database important: the suite used to be a throwaway file per
 * process, but MariaDB is a shared server, so pointing it at the configured
 * database would have `resetDb` delete every real account before the first
 * assertion ran.
 *
 * So the suite gets its own database, dropped on exit. RTE_TEST_DB_URL
 * overrides it when you want the tests to run against another server.
 */
import { SQL } from 'bun';
import { afterAll } from 'bun:test';

process.env.RTE_DB_URL =
	process.env.RTE_TEST_DB_URL ?? 'mysql://root:2001@127.0.0.1:3306/rte_web_test';
process.env.RTE_DB_NAME = new URL(process.env.RTE_DB_URL).pathname.replace(/^\//, '');

process.env.SESSION_SECRET = 'test-secret-not-for-production';
process.env.GATEWAY_ORIGIN = 'http://127.0.0.1:5005';

async function dropTestDatabase(): Promise<void> {
	try {
		const server = new SQL(process.env.RTE_DB_URL!.replace(/\/([^/?]+)(\?|$)/, '/$2'));
		await server.unsafe(`DROP DATABASE IF EXISTS \`${process.env.RTE_DB_NAME}\``);
		server.close();
	} catch {
		// No server, or already gone. The tests themselves will say so.
	}
}

// Awaited, and in afterAll rather than on 'exit'.
//
// An exit handler is synchronous by definition, and `unsafe` is a promise. So
// the DROP was dispatched and the process left before it ran: every `bun test`
// left its database behind, and the server accumulated one per run. afterAll
// can await, which is the only reason this works at all.
afterAll(async () => {
	await dropTestDatabase();
});