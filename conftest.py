"""Pytest bootstrap.

The project is a flat collection of top-level modules rather than an installed
package, and the suite reaches them by plain name (``import state_machine``,
``__import__("empires-server")``). Historically the CI had to export
``PYTHONPATH=$GITHUB_WORKSPACE`` for this to work; doing it here means a plain
``pytest`` works from a clean checkout on any platform.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent

if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

# The suite writes to its own log file. It shares the gateway's logging setup,
# and it deliberately makes handlers raise to prove the gateway survives them;
# without this those failures land in the server's log and make it look as
# though the server is the thing that is broken. Set here rather than in
# test/conftest.py because this file is loaded first, and the gateway is
# imported by the test modules at collection time.
os.environ.setdefault("RTE_LOG_FILE", "log-test.txt")