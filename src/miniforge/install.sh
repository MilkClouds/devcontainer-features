#!/bin/bash
set -e

MINIFORGE_VERSION="${VERSION:-latest}"
CONDA_INSTALL_PATH="${INSTALLPATH:-/opt/conda}"

fail() {
    echo "$1" >&2
    exit 1
}

ensure_download_tool() {
    if command -v wget >/dev/null 2>&1; then
        return
    fi
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends wget ca-certificates
    apt-get clean
    rm -rf /var/lib/apt/lists/*
}

resolve_arch() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "aarch64"
            ;;
        *)
            fail "Unsupported architecture: $arch"
            ;;
    esac
}

install_miniforge() {
    local arch url tmp_dir installer
    arch="$(resolve_arch)"

    if [ "$MINIFORGE_VERSION" = "latest" ]; then
        url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-${arch}.sh"
    else
        url="https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-Linux-${arch}.sh"
    fi

    ensure_download_tool
    mkdir -p "$(dirname "$CONDA_INSTALL_PATH")"

    tmp_dir="$(mktemp -d)"
    installer="$tmp_dir/miniforge.sh"
    wget -O "$installer" "$url"
    bash "$installer" -b -p "$CONDA_INSTALL_PATH"
    rm -rf "$tmp_dir"
}

if [ -x "$CONDA_INSTALL_PATH/bin/conda" ]; then
    echo "Miniforge already installed at: $CONDA_INSTALL_PATH"
else
    install_miniforge
fi

chmod -R a+rX "$CONDA_INSTALL_PATH"

mkdir -p /etc/conda
"$CONDA_INSTALL_PATH/bin/conda" config --system --set channel_priority strict
"$CONDA_INSTALL_PATH/bin/conda" config --system --set always_yes true
"$CONDA_INSTALL_PATH/bin/conda" config --system --set show_channel_urls true

cat <<EOF_PROFILE > /etc/profile.d/conda.sh
# Managed by devcontainer feature: miniforge
if [ -d "$CONDA_INSTALL_PATH" ]; then
    export PATH="$CONDA_INSTALL_PATH/bin:\$PATH"
fi
EOF_PROFILE
chmod 0644 /etc/profile.d/conda.sh

"$CONDA_INSTALL_PATH/bin/conda" clean -afy

echo "Miniforge installation completed at: $CONDA_INSTALL_PATH"
