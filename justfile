all:
    just build base
    just build base-minimal
    just build minimal
    just build nginx

# Full rpm-ostree & ostree-rs-ext from source build & test
github:
    #!/bin/bash
    set -euxo pipefail
    dnf update -y
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
    mkdir -p cache ociarchives
    for image in base base-minimal minimal nginx; do
        RUST_BACKTRACE=full ./rpm-ostree/rpm-ostree compose image --cachedir=cache --initialize --format=ociarchive $image.yaml ociarchives/$image.ociarchive
    done

# Set a default for some recipes
default_variant := "base"
default_release := "39"

build variant=default_variant release=default_release:
    sudo rpm-ostree compose image --initialize --format=ociarchive --image-config={{release}}/config.json {{release}}/{{variant}}.yaml {{variant}}-{{release}}.ociarchive
