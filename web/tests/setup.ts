/**
 * Test bootstrap.
 *
 * Runs before any module is imported, so config.ts picks these up. The database
 * is a throwaway file that is deleted on exit: tests get real SQL against a
 * real file rather than a mocked driver, which is the only way to catch a
 * migration that does not apply.
 */
import { unlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const dbFile = join(tmpdir(), `rte-web-test-${process.pid}.db`);

process.env.DATABASE_FILE = dbFile;
process.env.SESSION_SECRET = "test-secret-not-for-production";
process.env.GATEWAY_ORIGIN = "http://127.0.0.1:5005";

function cleanup(): void {
  for (const suffix of ["", "-wal", "-shm"]) {
    try {
      unlinkSync(`${dbFile}${suffix}`);
    } catch {
      // Already gone, or never created.
    }
  }
}

cleanup();
process.on("exit", cleanup);