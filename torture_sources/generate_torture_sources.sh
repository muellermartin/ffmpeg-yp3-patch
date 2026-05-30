#!/usr/bin/env bash
# Generate ~1 minute H.264 sources designed to maximize I-frame size after uid0001 encode.
# Sources are near-lossless (CRF 0) so re-encoding keeps maximum spatial detail.
set -euo pipefail

ROOT="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
FFMPEG="${FFMPEG:-ffmpeg}"
DURATION="${DURATION:-60}"
RATE="${RATE:-30}"

# Landscape 4:3 — matches typical player content before portrait scale/pad.
W="${W:-480}"
H="${H:-360}"

# Portrait native device canvas (after uid0001 scale/pad).
PW="${PW:-240}"
PH="${PH:-288}"

encode() {
    local out="$1"
    shift
    echo "==> $out"
    "$FFMPEG" -hide_banner -y -v warning \
        "$@" \
        -t "$DURATION" \
        -r "$RATE" \
        -c:v libx264 -preset ultrafast -crf 0 -pix_fmt yuv420p \
        -movflags +faststart \
        "$out"
}

echo "Writing torture sources to $ROOT (${DURATION}s @ ${RATE} fps)"

# 1. Full-frame temporal noise — worst-case entropy (~400–600 MB/min).
encode "$ROOT/torture01_noise_${W}x${H}.mp4" \
    -f lavfi -i "nullsrc=size=${W}x${H}:rate=${RATE},format=yuv420p,noise=alls=80:allf=t+u"

# 2. Conway life — chaotic fine structure, still hard to compress.
encode "$ROOT/torture02_life_${W}x${H}.mp4" \
    -f lavfi -i "life=size=${W}x${H}:rate=${RATE},format=yuv420p"

# 3. Elementary cellular automaton (rule 110 default).
encode "$ROOT/torture03_cellauto_${W}x${H}.mp4" \
    -f lavfi -i "cellauto=size=${W}x${H}:rate=${RATE},format=yuv420p"

# 4. testsrc2 with slow rotation — sharp edges + changing phase.
encode "$ROOT/torture04_testsrc2_spin_${W}x${H}.mp4" \
    -f lavfi -i "testsrc2=size=${W}x${H}:rate=${RATE}" \
    -vf "rotate=angle='2*PI*t/12':ow=${W}:oh=${H}:c=black@0,format=yuv420p"

# 5. YUV test pattern — chroma subsampling stress (Cb/Cr edges).
encode "$ROOT/torture05_yuvtest_${W}x${H}.mp4" \
    -f lavfi -i "yuvtestsrc=size=${W}x${H}:rate=${RATE}"

# 6. Zone plate — spatial frequency sweep (static; still spikes HF at scale).
encode "$ROOT/torture06_zoneplate_${W}x${H}.mp4" \
    -f lavfi -i "zoneplate=size=${W}x${H}:rate=${RATE}"

# 7. Noise at portrait resolution — no downscale blur before encode.
encode "$ROOT/torture07_noise_${PW}x${PH}.mp4" \
    -f lavfi -i "nullsrc=size=${PW}x${PH}:rate=${RATE},format=yuv420p,noise=alls=80:allf=t+u"

# 8. 1-pixel checker scroll — extreme HF (often smaller than noise but spikes QP).
encode "$ROOT/torture08_checker_scroll_${W}x${H}.mp4" \
    -f lavfi -i "nullsrc=size=${W}x${H}:rate=${RATE},format=gray,geq=lum='mod(X+Y+T*${RATE},2)*255':cb=128:cr=128,format=yuv420p"

echo
echo "Done. Files:"
ls -lh "$ROOT"/torture*.mp4
