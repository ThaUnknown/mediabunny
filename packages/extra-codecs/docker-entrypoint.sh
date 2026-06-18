#!/bin/bash
set -e

# extra-codecs WASM Build Entrypoint for Docker
# Builds a minimal FFmpeg with all Mediabunny decoder codecs:
#   surround: DTS, TrueHD, AC-3, E-AC-3
#   xiph:     FLAC, Vorbis, Opus

FFMPEG_VERSION="${FFMPEG_VERSION:-n8.1.1}"
BUILD_DIR="${BUILD_DIR:-/build}"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "=== extra-codecs WASM Build ==="
echo "FFmpeg version: $FFMPEG_VERSION"
echo "Build directory: $BUILD_DIR"
echo ""

if ! command -v emcc &> /dev/null; then
	echo "Error: Emscripten not found"
	exit 1
fi

BRIDGE_SRC=""
if [ -f "/src/src/bridge.c" ]; then
	BRIDGE_SRC="/src/src/bridge.c"
elif [ -f "/src/bridge.c" ]; then
	BRIDGE_SRC="/src/bridge.c"
else
	echo "Error: bridge.c not found"
	ls -la /src/ 2>/dev/null || echo "Could not list /src/"
	exit 1
fi

echo "Found bridge.c at: $BRIDGE_SRC"
echo ""

echo "[1/4] Cloning FFmpeg ($FFMPEG_VERSION)..."
cd "$TEMP_DIR"
git clone --depth 1 --branch "$FFMPEG_VERSION" https://github.com/FFmpeg/FFmpeg.git ffmpeg
cd ffmpeg

echo "[2/4] Configuring FFmpeg with all decoder support..."
emconfigure ./configure \
	--target-os=none \
	--arch=x86_32 \
	--enable-cross-compile \
	--disable-asm \
	--disable-x86asm \
	--disable-inline-asm \
	--disable-programs \
	--disable-doc \
	--disable-debug \
	--disable-all \
	--disable-everything \
	--disable-autodetect \
	--disable-pthreads \
	--disable-runtime-cpudetect \
	--disable-gpl \
	--enable-avcodec \
	--enable-swresample \
	--enable-decoder=dca \
	--enable-decoder=truehd \
	--enable-decoder=ac3 \
	--enable-decoder=eac3 \
	--enable-decoder=flac \
	--enable-decoder=opus \
	--enable-small \
	--cc=emcc \
	--cxx=em++ \
	--ar=emar \
	--nm=emnm \
	--ranlib=emranlib \
	--extra-cflags="-DNDEBUG -Oz -flto -fno-math-errno -mnontrapping-fptoint -msign-ext" \
	--extra-ldflags="-flto" \
	--prefix="$TEMP_DIR/ffmpeg/build"

echo "[3/4] Building FFmpeg libraries..."
emmake make -j$(nproc)

echo "[4/4] Compiling extra-codecs bridge..."
mkdir -p "$BUILD_DIR"

FFMPEG_DIR="$TEMP_DIR/ffmpeg"

emcc "$BRIDGE_SRC" \
	"$FFMPEG_DIR/libavcodec/libavcodec.a" \
	"$FFMPEG_DIR/libswresample/libswresample.a" \
	"$FFMPEG_DIR/libavutil/libavutil.a" \
	-I"$FFMPEG_DIR" \
	-s MODULARIZE=1 \
	-s EXPORT_ES6=1 \
	-s SINGLE_FILE=1 \
	-s ALLOW_MEMORY_GROWTH=1 \
	-s ENVIRONMENT=web,worker \
	-s FILESYSTEM=0 \
	-s MALLOC=emmalloc \
	-s SUPPORT_LONGJMP=0 \
	-s DYNAMIC_EXECUTION=0 \
	-s WASM_BIGINT=1 \
	-s DISABLE_EXCEPTION_CATCHING=1 \
	-s TEXTDECODER=2 \
	-s EXPORTED_RUNTIME_METHODS=cwrap,HEAPU8 \
	-s EXPORTED_FUNCTIONS=_malloc,_free \
	-flto \
	-Oz \
	-fno-math-errno \
	-mnontrapping-fptoint \
	-msign-ext \
	-o "$BUILD_DIR/extra-codecs.js"

echo "[5/5] Adding FFmpeg attribution header..."
{
	echo "/**"
	echo " * This software incorporates FFmpeg (https://ffmpeg.org/)."
	echo " *"
	echo " * FFmpeg is Copyright (c) 2000-2025 the FFmpeg developers."
	echo " * FFmpeg is licensed under LGPL version 2.1 or later."
	echo " * The complete corresponding source for FFmpeg is available at:"
	echo " *   https://github.com/FFmpeg/FFmpeg"
	echo " * Build configuration and scripts:"
	echo " *   https://github.com/Vanilagy/mediabunny/tree/main/packages/extra-codecs"
	echo " */"
	cat "$BUILD_DIR/extra-codecs.js"
} > "$BUILD_DIR/extra-codecs.js.tmp"
mv "$BUILD_DIR/extra-codecs.js.tmp" "$BUILD_DIR/extra-codecs.js"

echo ""
echo "=== Build complete! ==="
echo "Output: $BUILD_DIR/extra-codecs.js"
echo "Size: $(du -h "$BUILD_DIR/extra-codecs.js" | cut -f1)"
