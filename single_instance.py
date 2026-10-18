"""Platform-native single instance lock using msvcrt (Windows) and fcntl (Unix)."""

import os
import tempfile


class SingleInstanceException(Exception):
    pass


class SingleInstance:
    """Ensures that only a single instance of the application runs per flavor/port."""

    def __init__(self, flavor_id: str = ""):
        self.flavor_id = flavor_id
        # Safe filename in the temp directory
        lock_filename = f"raisetheempires_{flavor_id or 'default'}.lock"
        self.lockfile = os.path.join(tempfile.gettempdir(), lock_filename)
        self.file_handle = None
        self._lock()

    def _lock(self):
        try:
            self.file_handle = open(self.lockfile, "w")
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
                try:
                    self.file_handle.close()
                except Exception:
                    pass
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
                if os.path.exists(self.lockfile):
                    os.remove(self.lockfile)
            except Exception:
                pass
            finally:
                self.file_handle = None

    def __del__(self):
        self.clean_up()
