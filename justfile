all:
    just build common
    just build base
    just build base-minimal
    just build minimal
    just build nginx

github:
    #!/bin/bash
    set -euxo pipefail
    dnf install -y rpm-ostree distribution-gpg-keys git
    dnf install -y 'dnf-command(debuginfo-install)'
    dnf debuginfo-install -y rpm-ostree ostree
    git clone https://github.com/coreos/rpm-ostree.git
    git clone https://github.com/ostreedev/ostree-rs-ext.git
    cd rpm-ostree
    dnf builddep -y rpm-ostree
    ./ci/installdeps.sh
    ./ci/install-cxx.sh
    git submodule update --init
    sed -i "s/ostree-ext = \"0.12\"/ostree-ext = { path = '..\/ostree-rs-ext\/lib\/' }/" Cargo.toml
    ./autogen.sh --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc
    make -j4
    cd ..
    mkdir -p cache
    RUST_BACKTRACE=full ./rpm-ostree/rpm-ostree compose image --cachedir=cache --initialize --format=ociarchive nginx.yaml ociarchives/nginx.ociarchive

# Set a default for some recipes
default_variant := "base"

build variant=default_variant:
    mkdir -p cache
    # Debug with: RUST_BACKTRACE=full
    sudo ../../coreos/rpm-ostree/rpm-ostree compose image --cachedir=cache --initialize --format=ociarchive {{variant}}.yaml ociarchives/{{variant}}.ociarchive
