#!/bin/bash

set -e

# ------------------------------
# Config
# ------------------------------
IMAGE="vyogo/erpnext:sne-version-15"
BENCH_DIR="/home/frappe/frappe-bench"
APPS_DIR="$BENCH_DIR/apps"
CONTAINER_NAME="frappe-app-creator"
COMPOSE_FILE="compose.yml"

# ------------------------------
# Usage
# ------------------------------
usage() {
  echo "Usage:"
  echo "  $0 <app_name> [--compose-update-only]"
  echo ""
  echo "Arguments:"
  echo "  <app_name>              Name of the Frappe custom app (required)"
  echo "  --compose-update-only   Skip app creation, only update compose.yml"
  echo ""
  echo "Examples:"
  echo "  $0 my_app"
  echo "  $0 my_app --compose-update-only"
  exit 1
}

# ------------------------------
# Parse args
# ------------------------------
APP_NAME=""
COMPOSE_UPDATE_ONLY="false"

for arg in "$@"; do
  case "$arg" in
    --compose-update-only)
      COMPOSE_UPDATE_ONLY="true"
      ;;
    *)
      if [ -z "$APP_NAME" ]; then
        APP_NAME="$arg"
      else
        echo "❌ Unknown argument: $arg"
        usage
      fi
      ;;
  esac
done

if [ -z "$APP_NAME" ]; then
  usage
fi

LOCAL_APP_PATH="$(pwd)/apps/$APP_NAME"

# ------------------------------
# Function: Update compose.yml
# ------------------------------
update_compose_file() {
  if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ $COMPOSE_FILE not found in current directory."
    return 1
  fi

  local volume_line="- ./apps/$APP_NAME:/home/frappe/frappe-bench/apps/$APP_NAME"

  if grep -qF "$volume_line" "$COMPOSE_FILE"; then
    echo "ℹ️ Volume for '$APP_NAME' already exists in $COMPOSE_FILE"
  else
    echo "🔧 Updating $COMPOSE_FILE to mount app..."

    awk -v vol="$volume_line" '
      $0 ~ /^ *frappe-sne:/ { in_service=1 }
      in_service && $0 ~ /^ *volumes:/ { print; print "      " vol; next }
      { print }
    ' "$COMPOSE_FILE" > "$COMPOSE_FILE.tmp" && mv "$COMPOSE_FILE.tmp" "$COMPOSE_FILE"

    echo "✅ Added volume mount for '$APP_NAME' to $COMPOSE_FILE"
  fi
}

# ------------------------------
# Compose-update-only mode
# ------------------------------
if [ "$COMPOSE_UPDATE_ONLY" = "true" ]; then
  echo "📦 Compose-update-only mode: Skipping app creation..."
  update_compose_file
  exit $?
fi

# ------------------------------
# Detect Docker or Podman
# ------------------------------
if command -v docker &> /dev/null; then
  CONTAINER_ENGINE="docker"
elif command -v podman &> /dev/null; then
  CONTAINER_ENGINE="podman"
else
  echo "❌ Error: Docker or Podman is required."
  exit 1
fi

# ------------------------------
# Prepare local folder
# ------------------------------
mkdir -p "$LOCAL_APP_PATH"

# ------------------------------
# Run container and create app
# ------------------------------
$CONTAINER_ENGINE run --rm -it \
  --name "$CONTAINER_NAME" \
  -v "$LOCAL_APP_PATH:$APPS_DIR/$APP_NAME" \
  "$IMAGE" \
  bash -c "
    set -e
    su - frappe -c '
      cd $BENCH_DIR &&
      bench new-app $APP_NAME
    '
  "

echo ""
echo "✅ App '$APP_NAME' created interactively."
echo "📁 Local path: $LOCAL_APP_PATH"

# ------------------------------
# Ask user if they want to update compose.yml
# ------------------------------
read -p "👉 Do you want to update compose.yml to mount this app? (y/N): " UPDATE_COMPOSE

if [[ "$UPDATE_COMPOSE" =~ ^[Yy]$ ]]; then
  update_compose_file
else
  echo "❎ Skipping compose.yml update."
fi
