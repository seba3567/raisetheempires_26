import configparser
import sys
from base64 import b32encode
from pathlib import Path

from jsonpatch import apply_patch
from tqdm import tqdm
from xmldiff.main import patch_text

import init_settings as settings
from save_engine import install_path, my_games_path

config = configparser.ConfigParser()

def read_file(file_name):
    return Path(file_name).read_bytes()

def write_file(file_name, content):
    return Path(file_name).write_bytes(content)

def is_mod(file_name):
    return is_xml_diff(file_name) or is_json_patch(file_name)


def is_xml_diff(file_name):
    return Path(file_name).suffix == ".xmldiff"


def is_json_patch(file_name):
    return Path(file_name).suffix == ".jsonpatch"


def apply_mod(source, mod_file, name):
    if is_xml_diff(name):
        return lambda: patch_text(read_file(mod_file), source())
    if is_json_patch(name):
        return lambda: apply_patch(read_file(mod_file), source())
    return lambda: read_file(mod_file)


def get_cache_filename(original_path):
    return b32encode(original_path.encode()).decode("utf-8")


mod = {}
install_p = Path(install_path())
my_games_p = Path(my_games_path())
mod_folders = [install_p / 'mods']
mod_stats = []

if my_games_p != install_p:
    mod_folders.append(my_games_p / 'mods')

print("Loading mods...")

for mod_folder in mod_folders:
    mods_conf = mod_folder / "mods.conf"
    if mods_conf.is_file():
        config.read_string(mods_conf.read_text(encoding="utf-8"))
        if "mods" in config:
            for mod_name in config['mods']:
                if config['mods'][mod_name] == "false":
                    print("* mod " + mod_name + " is disabled")
                elif config['mods'][mod_name] == "true":
                    print("* mod " + mod_name + " is enabled")
                    mod_dir = mod_folder / mod_name
                    if mod_dir.is_dir():
                        for mod_file_path in mod_dir.rglob("*"):
                            if not mod_file_path.is_file():
                                continue
                            name = mod_file_path.name
                            rel = mod_file_path.relative_to(mod_dir)
                            source_name = mod_file_path.stem if is_mod(name) else name
                            source_file = (rel.parent / source_name).as_posix()
                            mod_file = str(mod_file_path)
                            print(" -> ", str(mod_file_path.parent), name, mod_file)
                            print(" | - rel " + str(rel.parent))
                            print(" | - source_file " + source_file)
                            print(" | - mod_file " + mod_file)

                            source = mod.get(source_file, lambda p=source_file: read_file(p))  # lambda chaining
                            mod[source_file] = apply_mod(source, mod_file, name)

                            stats = mod_file_path.stat()
                            mod_stats.append(f"{mod_file}: {stats.st_size} {stats.st_ctime_ns} {stats.st_mtime_ns}")
    else:
        print("mods.conf not found.")

cache_path = my_games_p / 'cache'
if settings.caching:
    try:
        cache_path.mkdir(exist_ok=True)
    except OSError as error:
        print(error)
        print("WARNING: cache directory can't be created in ", my_games_path(), ", caching is disabled, this may decrease performance and increase loading times.")
        settings.caching = False
else:
    print("WARNING: caching is disabled by choice, this may decrease performance and increase loading times.")

config_raw = repr({section: dict(config[section]) for section in config.sections()})

if settings.caching:
    mods_config_cache = cache_path / 'mods.config.cache'
    directory_cache = cache_path / 'directory.cache'

    if not mods_config_cache.exists() \
            or read_file(mods_config_cache) != config_raw.encode() or \
            not directory_cache.exists() \
            or read_file(directory_cache) != "\n".join(mod_stats).encode() :

        print("Updating cache")
        # Clear cache
        if cache_path.is_dir():
            for file_path in cache_path.iterdir():
                try:
                    if file_path.is_file():
                        file_path.unlink()
                except Exception as e:
                    print(f'ERROR: Failed to delete {file_path.name}. Reason: {e}')
                    print("Cache can't update, caching deactivated, this may decrease performance and increase loading times.")
                    settings.caching = False
        # Write cache
        if settings.caching:
            for path in tqdm(sorted(mod), file=sys.stdout):
                try:
                    write_file(cache_path / get_cache_filename(path), mod[path]())
                except Exception as e:
                    print(f'ERROR: Failed to write cache file {get_cache_filename(path)}. Reason: {e}')
                    print("Cache can't update, caching deactivated, this may decrease performance and increase loading times.")
                    settings.caching = False
            if settings.caching:
                write_file(mods_config_cache, config_raw.encode())
                write_file(directory_cache, "\n".join(mod_stats).encode())
                print("Cache creation complete")
    else:
        print("Cache up to date")
    # Swap modded files with cache
    if settings.caching:
        for path in sorted(mod):
            cached_file = cache_path / get_cache_filename(path)
            if cached_file.exists():
                # `path` is bound as a default argument on purpose: without it the
                # closure would capture the loop variable and every entry would
                # read the cache file of the *last* iterated path.
                mod[path] = lambda p=cached_file: read_file(p)
            else:
                print(f'ERROR: Cache miss, Cache file {get_cache_filename(path)} missing for original {path}. ')
                print("This may decrease performance and increase loading times.")


print("mod " + repr(mod))
print("config " + config_raw)


