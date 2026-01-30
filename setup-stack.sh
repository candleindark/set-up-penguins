#!/bin/bash

# Setup script for penguins service with frontend and backend
# This script creates the necessary directory structure and files

set -e  # Exit on any error

FRONTEND_PORT="8000"
BACKEND_PORT="8111"

# Define the base directory for the stack
STACK_DIR="stack"

# Remove existing stack directory if it exists (allows easy re-runs)
if [ -d "$STACK_DIR" ]; then
    echo "Removing existing stack directory..."
    rm -rf "$STACK_DIR"
fi

# Create the stack directory
echo "Creating stack directory..."
mkdir -p "$STACK_DIR"

# ============================================
# BACKEND SETUP
# ============================================

# Setup backend environment with micromamba (Python)
BACKEND_ENV_NAME="penguins-backend"

echo ""
echo "Setting up backend environment with micromamba..."

if micromamba env list | grep -qE "^[[:space:]]+$BACKEND_ENV_NAME"; then
    echo "⚠️  Warning: Environment '$BACKEND_ENV_NAME' already exists. Skipping environment creation."
else
    echo "Creating '$BACKEND_ENV_NAME' environment with Python..."
    micromamba create -y -n "$BACKEND_ENV_NAME" python

    # Install dump-things-service package from PyPI
    echo "Installing dump-things-service package from PyPI..."
    micromamba run -n "$BACKEND_ENV_NAME" pip install dump-things-service
fi

# Define the backend service directory
BACKEND_DIR="$STACK_DIR/dump-penguins-service"

# Create the backend directory structure
echo "Creating dump-penguins-service directory structure..."
mkdir -p "$BACKEND_DIR/store/penguin_records/curated"

# Create store/.dumpthings.yaml
echo "Creating store/.dumpthings.yaml..."
cat > "$BACKEND_DIR/store/.dumpthings.yaml" << 'EOF'
type: collections     # has to be "collections"
version: 1            # has to be 1

# All collections are listed in "collections"
collections:
  penguins:
    default_token: read_curated_access
    curated: penguin_records/curated
    incoming: penguin_records/incoming
    # backend:  # let this default to record_dir+stl
    auth_sources:
      - type: config
    # submission_tags: # Let this default
    # use_classes:  # Let this default to an empty list
    # ignore_classes:  # Let this default to an empty list

tokens:
  read_curated_access:
    user_id: anonymous
    collections:
      penguins:
        mode: READ_CURATED
        incoming_label: ""
    # hashed:  # Let it default to false

  read_collection_access:
    user_id: collection_reader
    collections:
      penguins:
        mode: READ_COLLECTION
        incoming_label: user_posted_penguin_records
    # hashed:  # Let it default to false

  full_access:
    user_id: full_access_user
    collections:
      penguins:
        mode: WRITE_COLLECTION
        incoming_label: user_posted_penguin_records
    # hashed:  # Let it default to false
EOF

# Create store/penguin_records/curated/.dumpthings.yaml
echo "Creating store/penguin_records/curated/.dumpthings.yaml..."
cat > "$BACKEND_DIR/store/penguin_records/curated/.dumpthings.yaml" << 'EOF'
type: records
version: 1
schema: https://concepts.datalad.org/s/demo-empirical-data/unreleased.yaml
format: yaml
idfx: digest-md5
EOF

echo ""
echo "✅ Backend setup complete!"
echo ""
echo "Directory structure:"
echo "$STACK_DIR/"
echo "└── dump-penguins-service/"
echo "    └── store/"
echo "        ├── .dumpthings.yaml"
echo "        └── penguin_records/"
echo "            └── curated/"
echo "                └── .dumpthings.yaml"

# ============================================
# FRONTEND SETUP
# ============================================

# Setup frontend dev environment with micromamba (Node.js)
FRONTEND_DEV_ENV_NAME="penguins-frontend"

echo ""
echo "Setting up frontend dev environment with micromamba..."

if micromamba env list | grep -qE "^[[:space:]]+$FRONTEND_DEV_ENV_NAME"; then
    echo "⚠️  Warning: Environment '$FRONTEND_DEV_ENV_NAME' already exists. Skipping environment creation."
else
    echo "Creating '$FRONTEND_DEV_ENV_NAME' environment with Node.js..."
    micromamba create -y -n "$FRONTEND_DEV_ENV_NAME" nodejs
fi

# Clone the frontend repository
FRONTEND_DIR="$STACK_DIR/penguins.edu.datalad.org-ui"

echo ""
echo "Cloning frontend repository (with submodules)..."
git clone --recurse-submodules https://hub.datalad.org/edu/penguins.edu.datalad.org-ui.git "$FRONTEND_DIR"

# Build the frontend app using Makefile
echo ""
echo "Installing frontend dev dependencies..."
micromamba run -n "$FRONTEND_DEV_ENV_NAME" make -C "$FRONTEND_DIR" install

echo ""
echo "Building frontend app..."
micromamba run -n "$FRONTEND_DEV_ENV_NAME" make -C "$FRONTEND_DIR" build

# Modify config.json to point to local backend
echo ""
echo "Configuring frontend to use local backend..."
jq ".service_base_url[0].url = \"http://0.0.0.0:${BACKEND_PORT}/penguins/\"" "$FRONTEND_DIR/dist/config.json" > "$FRONTEND_DIR/dist/config.json.tmp" && mv "$FRONTEND_DIR/dist/config.json.tmp" "$FRONTEND_DIR/dist/config.json"

echo ""
echo "✅ Frontend setup complete!"
echo "Frontend cloned to: $FRONTEND_DIR"
echo "Built app available in: $FRONTEND_DIR/dist"

# ============================================
# START SERVICES
# ============================================

echo ""
echo "Starting services..."

# Start backend service in the background
BACKEND_STORE_DIR="$(pwd)/$BACKEND_DIR/store"
echo ""
echo "Starting backend service on port $BACKEND_PORT..."
micromamba run -n "$BACKEND_ENV_NAME" dump-things-service --origins "http://localhost:${FRONTEND_PORT}" "$BACKEND_STORE_DIR" &
BACKEND_PID=$!
echo "Backend started with PID: $BACKEND_PID"

# Start frontend service in the background
echo ""
echo "Starting frontend service on port $FRONTEND_PORT..."
micromamba run -n "$FRONTEND_DEV_ENV_NAME" python -m http.server -d "$FRONTEND_DIR/dist" "$FRONTEND_PORT" &
FRONTEND_PID=$!
echo "Frontend started with PID: $FRONTEND_PID"

echo ""
echo "✅ All services started!"
echo ""
echo "Backend running at: http://0.0.0.0:$BACKEND_PORT"
echo "Frontend running at: http://localhost:$FRONTEND_PORT"
echo ""
echo "To stop the services gracefully:"
echo ""
echo "  Stop backend (PID: $BACKEND_PID):"
echo "    macOS:  kill -INT $BACKEND_PID"
echo "    Linux:  kill -SIGINT $BACKEND_PID"
echo ""
echo "  Stop frontend (PID: $FRONTEND_PID):"
echo "    macOS:  kill -INT $FRONTEND_PID"
echo "    Linux:  kill -SIGINT $FRONTEND_PID"
