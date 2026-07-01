#!/bin/sh
# Fetch upstream x264 and apply yp3-x264.patch. Usage:
#   build_x264 <prefix> <patch_file> [workdir]
build_x264() {
    prefix="$1"
    workdir="${2:-/tmp/x264-build}"

    mkdir -p "$workdir"
    cd "$workdir" || true

    git clone "https://github.com/tytydraco/x264-yp3-patch"
    cd x264-yp3-patch || true

    ./configure \
        --prefix="$prefix" \
        --enable-static \
        --disable-cli \
        --disable-opencl
    make -j"${JOBS:-$(nproc)}"
    make install
}
