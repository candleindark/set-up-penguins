#!/bin/bash

# Shared configuration for stack scripts
# This file is meant to be sourced by other scripts

# shellcheck disable=SC2034  # Variables are used by scripts that source this file

# Directory structure
STACK_DIR="stack"

# Host configuration
HOST=localhost

# Backend configuration
BACKEND_DIR="$STACK_DIR/dump-penguins-service"
BACKEND_ENV_NAME="penguins-backend"
BACKEND_PORT=8111
READ_CURATED_TOKEN=read_curated_token
READ_COLLECTION_TOKEN=read_collection_token
WRITE_COLLECTION_TOKEN=write_collection_token

# Frontend configuration
FRONTEND_DIR="$STACK_DIR/penguins.edu.datalad.org-ui"
FRONTEND_ENV_NAME="penguins-frontend"
FRONTEND_PORT=8000

# Populate backend configuration
POPULATE_ENV_NAME="penguins-populate"

