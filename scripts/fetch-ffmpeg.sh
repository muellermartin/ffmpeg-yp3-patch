#!/bin/sh
# Fetch upstream ffmpeg sources. Usage:
#   fetch_ffmpeg <dest_dir>
fetch_ffmpeg() {
    dest=$1
    url=${FFMPEG_URL:-https://ffmpeg.org/releases/ffmpeg-7.1.tar.xz}
    tarball=${FFMPEG_TARBALL:-ffmpeg-7.1.tar.xz}
   srcdir=${FFMPEG_SRCDIR:-ffmpeg-7.1}

    mkdir -p "$(dirname "$dest")"
    work=$(dirname "$dest")

    if [ -d "$dest/.ffmpeg-fetched" ]; then
        return 0
    fi

    cd "$work"
    if [ ! -f "$tarball" ]; then
        echo "Downloading $url ..."
        curl -fsSL "$url" -o "$tarball"
    fi

    rm -rf "$srcdir"
    tar xf "$tarball"
    rm -rf "$dest"
    mv "$srcdir" "$dest"
    touch "$dest/.ffmpeg-fetched"
    echo "ffmpeg sources ready at $dest"
}
