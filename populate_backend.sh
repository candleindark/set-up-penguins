#!/bin/bash

# Script to populate the backend with penguin data
# This script installs the penguins dataset and populates the backend store

set -e  # Exit on any error

# Source shared configuration
source "$(dirname "$0")/stack-config.sh"

# ============================================
# SETUP POPULATE ENVIRONMENT
# ============================================

echo "Setting up populate environment with micromamba..."

if micromamba env list | grep -qE "^[[:space:]]+$POPULATE_ENV_NAME"; then
    echo "⚠️  Warning: Environment '$POPULATE_ENV_NAME' already exists. Skipping environment creation."
else
    echo "Creating '$POPULATE_ENV_NAME' environment with Python..."
    micromamba create -y -n "$POPULATE_ENV_NAME" python
fi

# ============================================
# INSTALL PENGUINS DATASET
# ============================================

echo "Installing penguins dataset with all subdatasets..."
datalad install -r -s https://hub.datalad.org/edu/penguins.git "$DATASET_DIR"

echo "Downloading all data in the dataset..."
datalad get -r "$DATASET_DIR"

echo "Installing Python dependencies from dataset..."
micromamba run -n "$POPULATE_ENV_NAME" pip install -r "$DATASET_DIR/code/requirements.txt"
