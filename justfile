all: build

build:
    mkdir -p cache
    sudo RUST_BACKTRACE=full rpm-ostree compose image --cachedir=cache --initialize --format=ociarchive manifest.yaml nginx.ociarchive
