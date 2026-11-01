"""Hand the random generator over to its new owner.

Run from the repo root:  .venv\\Scripts\\python.exe scratch_delegate.py
"""
from __future__ import annotations

import pathlib

NEW = '''def roll_random() -> int:
    """Draw a number from the battle's stream.

    The generator lives in ``game_random``, which owns the seeds and counts
    the draws: the client simulates the battle and stops it dead if the two
    sides have not drawn the same number of values. This name stays because
    half the project reaches for it.
    """
    return game_random.roll_random()


def roll_random_float() -> float:
    return game_random.roll_random_float()


def roll_random_between(a: float, b: float) -> float:
    return game_random.roll_random_between(a, b)


def get_seed_w() -> int:
    return game_random.get_seed_w()


def get_seed_z() -> int:
    return game_random.get_seed_z()


def roll_reward_random() -> int:
    """Draw a number from the rewards' stream, which is a stream of its own.

    A reward is not a battle: paying one out must not move the numbers the
    fight is using.
    """
    return game_random.roll_reward_random()


def roll_reward_random_float() -> float:
    return game_random.roll_reward_random_float()


def roll_reward_random_between(a: float, b: float) -> float:
    return game_random.roll_reward_random_between(a, b)


'''


def main() -> None:
    path = pathlib.Path("quest_engine.py")
    text = path.read_text(encoding="utf-8", newline="")
    start = text.index("def roll_random() -> int:")
    end = text.index("def progress_harvest_consumable(")
    path.write_text(text[:start] + NEW + text[end:], encoding="utf-8", newline="")
    print("quest_engine.py: el generador ahora delega en game_random")


if __name__ == "__main__":
    main()
