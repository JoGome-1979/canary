"""Run the standalone Lua test without installing a Lua executable."""
import ctypes
import ctypes.util
from pathlib import Path

library = ctypes.util.find_library("lua5.4") or ctypes.util.find_library("lua5.3")
if not library:
    raise SystemExit("Lua 5.3/5.4 shared library unavailable; use lua tests/lua/premium_loot.lua.")

lua = ctypes.CDLL(library)
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
lua.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
lua.lua_pcallk.argtypes = [
    ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int,
    ctypes.c_ssize_t, ctypes.c_void_p,
]
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_close.argtypes = [ctypes.c_void_p]

if not Path("data/libs/functions/monstertype.lua").is_file():
    raise SystemExit("Run this test from the repository root.")

state = lua.luaL_newstate()
if not state:
    raise SystemExit("Unable to allocate Lua state.")
try:
    lua.luaL_openlibs(state)
    result = lua.luaL_loadfilex(state, b"tests/lua/premium_loot.lua", None)
    if result == 0:
        result = lua.lua_pcallk(state, 0, 0, 0, 0, None)
    if result:
        raise SystemExit(lua.lua_tolstring(state, -1, None).decode())
finally:
    lua.lua_close(state)
