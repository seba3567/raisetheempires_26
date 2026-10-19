"""Platform-native single instance lock using msvcrt (Windows) and fcntl (Unix)."""

import contextlib
import os
import tempfile
from pathlib import Path


class SingleInstanceException(Exception):
    pass


class SingleInstance:
    """Ensures that only a single instance of the application runs per flavor/port."""

    def __init__(self, flavor_id: str = ""):
        self.flavor_id = flavor_id
        # Safe filename in the temp directory
        lock_filename = f"raisetheempires_{flavor_id or 'default'}.lock"
        self.lockfile = str(Path(tempfile.gettempdir()) / lock_filename)
        self.file_handle = None
        self._lock()

    def _lock(self):
        try:
            # We deliberately keep the file handle open for the lifetime of the process to maintain the lock
            self.file_handle = Path(self.lockfile).open("w")  # noqa: SIM115
            self.file_handle.write(f"{os.getpid()}\n")
            self.file_handle.flush()

            if os.name == "nt":
                import msvcrt

                # Lock 1 byte from the beginning of the file non-blocking
                msvcrt.locking(self.file_handle.fileno(), msvcrt.LK_NBLCK, 1)
            else:
                import fcntl

                fcntl.flock(self.file_handle.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        except OSError as exc:
            if self.file_handle:
                with contextlib.suppress(Exception):
                    self.file_handle.close()
            raise SingleInstanceException(
                f"Another instance is already running with flavor '{self.flavor_id}' (lockfile: {self.lockfile})"
            ) from exc

    def clean_up(self):
        if self.file_handle:
            try:
                if os.name == "nt":
                    import msvcrt

                    self.file_handle.seek(0)
                    msvcrt.locking(self.file_handle.fileno(), msvcrt.LK_UNLCK, 1)
                else:
                    import fcntl

                    fcntl.flock(self.file_handle.fileno(), fcntl.LOCK_UN)
                self.file_handle.close()
                Path(self.lockfile).unlink(missing_ok=True)
            except Exception:  # noqa: S110
                pass
            finally:
                self.file_handle = None

    def __del__(self):
        self.clean_up()
