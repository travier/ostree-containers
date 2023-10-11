all: build

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
    RUST_BACKTRACE=full ./rpm-ostree/rpm-ostree compose image --cachedir=cache --initialize --format=ociarchive manifest.yaml nginx.ociarchive

build:
    mkdir -p cache
    sudo RUST_BACKTRACE=full rpm-ostree compose image --cachedir=cache --initialize --format=ociarchive manifest.yaml nginx.ociarchive
