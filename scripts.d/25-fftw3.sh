#!/bin/bash

SCRIPT_REPO="https://github.com/FFTW/fftw3.git"
SCRIPT_COMMIT="9426cd59106ffddde1f55131c07fa9c562fa2f8e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT_PINNED" fftw3
    cd fftw3

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-maintainer-mode
        --disable-shared
        --enable-static
        --disable-fortran
        --disable-doc
        --with-our-malloc
        --enable-threads
        --with-combined-threads
        --with-incoming-stack-boundary=2
    )

    if [[ $TARGET != *arm64 ]]; then
        myconf+=(
            --enable-sse2
            --enable-avx
            --enable-avx2
        )
    fi

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./bootstrap.sh "${myconf[@]}"
    make -j$(nproc)
    make install
}
