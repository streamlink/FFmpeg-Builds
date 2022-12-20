#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/rav1e.git"
SCRIPT_COMMIT="0fb96baa0a8c2a539ad0c148b6b2f9cfed37707a"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" rav1e
    cd rav1e

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --library-type=staticlib
        --crt-static
        --release
    )

    if [[ -n "$FFBUILD_RUST_TARGET" ]]; then
        unset PKG_CONFIG_LIBDIR

        export CC="gcc"
        export CXX="g++"
        export TARGET_CC="${FFBUILD_CROSS_PREFIX}gcc"
        export TARGET_CXX="${FFBUILD_CROSS_PREFIX}g++"
        export CROSS_COMPILE=1
        export TARGET_CFLAGS="$CFLAGS"
        export TARGET_CXXFLAGS="$CFLAGS"
        unset CFLAGS
        unset CXXFLAGS

        myconf+=(
            --target="$FFBUILD_RUST_TARGET"
        )
        cat <<EOF >$CARGO_HOME/config.toml
[target.$FFBUILD_RUST_TARGET]
linker = "${FFBUILD_CROSS_PREFIX}gcc"
ar = "${FFBUILD_CROSS_PREFIX}ar"
EOF
    fi

    cargo cinstall -v "${myconf[@]}"
}

ffbuild_configure() {
    echo --enable-librav1e
}

ffbuild_unconfigure() {
    echo --disable-librav1e
}
