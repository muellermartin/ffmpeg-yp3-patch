#!/bin/sh
# Fetch the patched x264 for YP3. Usage:
#   build_x264 <prefix> [workdir]
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
