#!/bin/bash

# Setup script for penguins service with frontend and backend
# This script creates the necessary directory structure and files

set -e  # Exit on any error

# Define the base directory for the stack
STACK_DIR="stack"

# Create the stack directory if it doesn't exist
echo "Creating stack directory..."
mkdir -p "$STACK_DIR"

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
echo "✅ Backend directory structure created successfully!"
echo ""
echo "Directory structure:"
echo "$STACK_DIR/"
echo "└── dump-penguins-service/"
echo "    └── store/"
echo "        ├── .dumpthings.yaml"
echo "        └── penguin_records/"
echo "            └── curated/"
echo "                └── .dumpthings.yaml"
