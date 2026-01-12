#!/bin/bash
# Create safety checkpoint before refactoring

set -e

TARGET="${1:-.}"  # Default to current directory if not specified
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CHECKPOINT_DIR=".refactor-checkpoint-${TIMESTAMP}"

echo "📸 Creating Safety Checkpoint"
echo ""

# Create checkpoint directory
mkdir -p "$CHECKPOINT_DIR"

# Copy target files
if [ -f "$TARGET" ]; then
    # Single file
    cp "$TARGET" "$CHECKPOINT_DIR/"
    echo "✓ Backed up: $TARGET"
elif [ -d "$TARGET" ]; then
    # Directory
    cp -r "$TARGET" "$CHECKPOINT_DIR/"
    FILE_COUNT=$(find "$CHECKPOINT_DIR" -type f | wc -l)
    echo "✓ Backed up: $TARGET ($FILE_COUNT files)"
else
    # No target - backup everything
    git ls-files | while read -r file; do
        mkdir -p "$CHECKPOINT_DIR/$(dirname "$file")"
        cp "$file" "$CHECKPOINT_DIR/$file"
    done
    FILE_COUNT=$(find "$CHECKPOINT_DIR" -type f | wc -l)
    echo "✓ Backed up: All tracked files ($FILE_COUNT files)"
fi

# Save git commit info
git rev-parse HEAD > "$CHECKPOINT_DIR/.git-commit"
git rev-parse --abbrev-ref HEAD > "$CHECKPOINT_DIR/.git-branch"

COMMIT=$(cat "$CHECKPOINT_DIR/.git-commit")
BRANCH=$(cat "$CHECKPOINT_DIR/.git-branch")

echo ""
echo "Checkpoint created: $CHECKPOINT_DIR"
echo "Git commit: ${COMMIT:0:7}"
echo "Git branch: $BRANCH"
echo ""
echo "You can rollback with:"
echo "  bash .cursor/scripts/rollback-refactor.sh $TIMESTAMP"
echo ""
echo "Checkpoint saved ✓"

# Store checkpoint info for rollback
echo "CHECKPOINT_DIR=$CHECKPOINT_DIR" > .refactor-current.env
echo "TIMESTAMP=$TIMESTAMP" >> .refactor-current.env
echo "TARGET=$TARGET" >> .refactor-current.env
