# Multi-stage Dockerfile for building extra-codecs WASM module
# Usage: docker build -t mediabunny-extra-codecs-builder .
# Then: docker run --rm -v $(pwd):/src -v $(pwd)/build:/build mediabunny-extra-codecs-builder

FROM emscripten/emsdk:latest

# Install additional dependencies
RUN apt-get update && apt-get install -y \
	git \
	cmake \
	build-essential \
	pkg-config \
	nasm \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy build entrypoint
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Mount points expected:
# -v $(pwd):/src - Source directory with bridge.c
# -v $(pwd)/build:/build - Output directory for extra-codecs.js

ENTRYPOINT ["/entrypoint.sh"]
