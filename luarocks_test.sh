#!/bin/bash
set -ex

LUAROCKS_AREA=$(realpath lr)
LUAROCKS_TAR="luarocks-3.9.2.tar.gz"
LUAROCKS_URL="http://luarocks.github.io/luarocks/releases/$LUAROCKS_TAR"
LUAROCKS_DIR="${LUAROCKS_AREA}/luarocks-3.9.2"

LUA_TAR="lua-5.4.6.tar.gz"
LUA_URL="https://www.lua.org/ftp/${LUA_TAR}"
LUA_DIR="${LUAROCKS_AREA}/lua-5.4.6"

cargo build
ln -s debug/rlua_luarocks target/lua

APP=$(realpath target/debug/rlua_luarocks)
HERE=$(realpath $(dirname $0))

mkdir -p "${LUAROCKS_AREA}"

# Download luarocks if needed
if [ ! -f "${LUAROCKS_AREA}/${LUAROCKS_TAR}" ]; then
    (cd "${LUAROCKS_AREA}" && wget "${LUAROCKS_URL}")
fi

if [ ! -d "${LUAROCKS_DIR}" ]; then
    (cd "${LUAROCKS_AREA}" && tar xf "${LUAROCKS_TAR}")
fi

# Download lua if needed
if [ ! -f "${LUAROCKS_AREA}/${LUA_TAR}" ]; then
    (cd "${LUAROCKS_AREA}" && wget "${LUA_URL}")
fi

if [ ! -d "${LUA_DIR}" ]; then
    (cd "${LUAROCKS_AREA}" && tar xf "${LUA_TAR}")
fi

cd "${LUAROCKS_DIR}"
mkdir -p "${LUAROCKS_AREA}/lib"
if [ ! -l "${LUAROCKS_AREA}/lib/liblua54.so" ]; then
    ln -s "${APP}" "${LUAROCKS_AREA}/lib/liblua54.so"
fi

./configure --prefix="${LUAROCKS_AREA}" --sysconfdir="${LUAROCKS_AREA}/luarocks" --force-config --with-lua-bin=$(dirname "${APP}") --with-lua-interpreter="rlua_luarocks" --lua-version=5.4 --with-lua-include="${LUA_DIR}/src" --with-lua-lib="${LUAROCKS_AREA}/lib"

make
make install

cd "$HERE"
lr/bin/luarocks install http
target/debug/rlua_luarocks ./test_http.lua
