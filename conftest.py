"""Pytest bootstrap.

The project is a flat collection of top-level modules rather than an installed
package, and the suite reaches them by plain name (``import state_machine``,
``__import__("empires-server")``). Historically the CI had to export
``PYTHONPATH=$GITHUB_WORKSPACE`` for this to work; doing it here means a plain
``pytest`` works from a clean checkout on any platform.
"""

from __future__ import annotations

import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent

if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))