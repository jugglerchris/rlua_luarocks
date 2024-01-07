#!/bin/bash
set -ex

LUAROCKS_AREA=$(realpath lr)
LUAROCKS_TAR="luarocks-3.9.2.tar.gz"
LUAROCKS_URL="http://luarocks.github.io/luarocks/releases/$LUAROCKS_TAR"
LUAROCKS_DIR="${LUAROCKS_AREA}/luarocks-3.9.2"

echo $LUAROCKS_AREA

mkdir -p "${LUAROCKS_AREA}"

# Download luarocks if needed
if [ ! -f "${LUAROCKS_AREA}/${LUAROCKS_TAR}" ]; then
    (cd "${LUAROCKS_AREA}" && wget "${LUAROCKS_URL}")
fi

if [ ! -d "${LUAROCKS_DIR}" ]; then
    (cd "${LUAROCKS_AREA}" && tar xf "${LUAROCKS_TAR}")
fi
