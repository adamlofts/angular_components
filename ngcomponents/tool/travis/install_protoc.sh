#!/usr/bin/env bash

# Only run externally during presubmits on Travis.

set -ev
PROTOC_PLUGIN_VERSION="20.0.0"
PROTOC_VERSION="3.13.0"

if type protoc > /dev/null; then
  echo "protoc already installed."

  # Activate dart protoc plugin.
  dart pub global activate protoc_plugin $PROTOC_PLUGIN_VERSION
  exit 0
fi

echo "Installing protoc..."

# Download protoc.
mkdir $HOME/protoc
pushd $HOME/protoc
wget https://github.com/google/protobuf/releases/download/v$PROTOC_VERSION/protoc-$PROTOC_VERSION-linux-x86_64.zip
unzip protoc-$PROTOC_VERSION-linux-x86_64.zip
popd

$HOME/protoc/bin/protoc --version

# Activate dart protoc plugin.
dart pub global activate protoc_plugin $PROTOC_PLUGIN_VERSION
