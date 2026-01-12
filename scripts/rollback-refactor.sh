#!/bin/bash
# Rollback refactoring changes to checkpoint

set -e

TIMESTAMP="$1"

if [ -z "$TIMESTAMP" ]; then
    echo "ERROR: No timestamp provided"
    echo "Usage: bash rollback-refactor.sh [timestamp]"
    echo ""
    echo "Available checkpoints:"
    ls -d .refactor-checkpoint-* 2>/dev/null || echo "  None found"
    exit 1
fi

CHECKPOINT_DIR=".refactor-checkpoint-${TIMESTAMP}"

if [ ! -d "$CHECKPOINT_DIR" ]; then
    echo "ERROR: Checkpoint not found: $CHECKPOINT_DIR"
    echo ""
    echo "Available checkpoints:"
    ls -d .refactor-checkpoint-* 2>/dev/null || echo "  None found"
    exit 1
fi

echo "⏮️  Rolling Back Refactoring"
echo ""
echo "Checkpoint: $CHECKPOINT_DIR"
echo ""

# Confirm rollback
read -p "This will restore files to checkpoint. Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Rollback cancelled"
    exit 0
fi

# Get checkpoint info
COMMIT=$(cat "$CHECKPOINT_DIR/.git-commit" 2>/dev/null || echo "unknown")
BRANCH=$(cat "$CHECKPOINT_DIR/.git-branch" 2>/dev/null || echo "unknown")

echo "Restoring from:"
echo "- Git commit: ${COMMIT:0:7}"
echo "- Git branch: $BRANCH"
echo ""

# Count files
FILE_COUNT=$(find "$CHECKPOINT_DIR" -type f ! -name '.git-*' | wc -l)
echo "Restoring $FILE_COUNT files..."

# Restore files
find "$CHECKPOINT_DIR" -type f ! -name '.git-*' | while read -r file; do
    RELATIVE_PATH="${file#$CHECKPOINT_DIR/}"
    TARGET_DIR=$(dirname "$RELATIVE_PATH")
    
    # Create directory if needed
    mkdir -p "$TARGET_DIR"
    
    # Copy file back
    cp "$file" "$RELATIVE_PATH"
done

echo ""
echo "✅ Rollback Complete"
echo ""
echo "Files restored to checkpoint state"
echo "Checkpoint preserved at: $CHECKPOINT_DIR"
echo ""
echo "Next steps:"
echo "1. Verify restoration: git diff"
echo "2. Run tests: pytest tests/"
echo "3. If satisfied, remove checkpoint: rm -rf $CHECKPOINT_DIR"
