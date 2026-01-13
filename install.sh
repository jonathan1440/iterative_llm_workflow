#!/bin/bash
# Cursor Workflow Installer
# Copies all workflow files to .cursor/ directory in target project
#
# Usage:
#   bash install.sh [target-directory]
#
# Examples:
#   bash install.sh                    # Install to current directory (if run from repo)
#   bash install.sh /path/to/project   # Install to specified project directory
#   bash install.sh ~/my-project        # Install to home directory project

set -e

# Get target directory from argument, default to current directory
TARGET_DIR="${1:-.}"

# Validate target directory exists (if not current directory)
if [ "$TARGET_DIR" != "." ] && [ ! -d "$TARGET_DIR" ]; then
    echo "❌ ERROR: Target directory does not exist: $TARGET_DIR"
    echo ""
    echo "Please create the directory first or use an existing path."
    echo ""
    exit 1
fi

# Convert to absolute path
if [ "$TARGET_DIR" != "." ]; then
    TARGET_DIR=$(cd "$TARGET_DIR" && pwd)
fi

# Get script directory (where install.sh is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════════════════════╗"
echo "║     Cursor AI-Assisted Development Workflow            ║"
echo "║                   Installer                            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Target directory: $TARGET_DIR"
echo ""

# Determine source directory (where workflow files are)
# First check if we're in the repo (current directory has workflow files)
if [ -d "commands" ] && [ -d "scripts" ] && [ -d "templates" ]; then
    SOURCE_DIR="."
    echo "✓ Found workflow files in current directory"
# Then check if script is in the repo (script directory has workflow files)
elif [ -d "$SCRIPT_DIR/commands" ] && [ -d "$SCRIPT_DIR/scripts" ] && [ -d "$SCRIPT_DIR/templates" ]; then
    SOURCE_DIR="$SCRIPT_DIR"
    echo "✓ Found workflow files in script directory"
else
    echo "❌ ERROR: Could not find workflow source files"
    echo ""
    echo "The installer needs access to the workflow repository files."
    echo ""
    echo "Option 1: Run from the workflow repository root:"
    echo "  cd /path/to/workflow-repo"
    echo "  bash install.sh [target-directory]"
    echo ""
    echo "Option 2: Download the repository first:"
    echo "  git clone [repo-url]"
    echo "  cd workflow-repo"
    echo "  bash install.sh [target-directory]"
    echo ""
    echo "Option 3: Extract repository zip file, then run install.sh from extracted directory"
    echo ""
    exit 1
fi

echo "📂 Source directory: $SOURCE_DIR"
echo ""

# Create .cursor directory structure in target
echo "📁 Creating .cursor directory structure in target..."
mkdir -p "$TARGET_DIR/.cursor/{commands,scripts,templates,agent-docs}"
echo "   ✓ Created $TARGET_DIR/.cursor/commands/"
echo "   ✓ Created $TARGET_DIR/.cursor/scripts/"
echo "   ✓ Created $TARGET_DIR/.cursor/templates/"
echo "   ✓ Created $TARGET_DIR/.cursor/agent-docs/"
echo ""

# Copy commands
echo "📋 Installing commands..."
COMMAND_COUNT=$(ls "$SOURCE_DIR/commands"/*.md 2>/dev/null | wc -l)
if [ "$COMMAND_COUNT" -gt 0 ]; then
    cp "$SOURCE_DIR/commands"/*.md "$TARGET_DIR/.cursor/commands/"
    echo "   ✓ Installed $COMMAND_COUNT commands"
else
    echo "   ⚠️  No command files found in $SOURCE_DIR/commands/"
fi
echo ""

# Copy scripts
echo "🔧 Installing scripts..."
SCRIPT_COUNT=$(ls "$SOURCE_DIR/scripts"/*.sh 2>/dev/null | wc -l)
if [ "$SCRIPT_COUNT" -gt 0 ]; then
    cp "$SOURCE_DIR/scripts"/*.sh "$TARGET_DIR/.cursor/scripts/"
    chmod +x "$TARGET_DIR/.cursor/scripts"/*.sh
    echo "   ✓ Installed $SCRIPT_COUNT scripts"
    echo "   ✓ Made scripts executable"
else
    echo "   ⚠️  No script files found in $SOURCE_DIR/scripts/"
fi
echo ""

# Copy templates
echo "📄 Installing templates..."
TEMPLATE_COUNT=$(ls "$SOURCE_DIR/templates"/*.md 2>/dev/null | wc -l)
if [ "$TEMPLATE_COUNT" -gt 0 ]; then
    cp "$SOURCE_DIR/templates"/*.md "$TARGET_DIR/.cursor/templates/"
    echo "   ✓ Installed $TEMPLATE_COUNT templates"
else
    echo "   ⚠️  No template files found in $SOURCE_DIR/templates/"
fi
echo ""

# Copy agent-docs if it exists
if [ -d "$SOURCE_DIR/agent-docs" ]; then
    echo "📚 Installing agent-docs..."
    mkdir -p "$TARGET_DIR/.cursor/agent-docs"
    AGENT_DOCS_COUNT=$(ls "$SOURCE_DIR/agent-docs"/*.md 2>/dev/null | wc -l)
    if [ "$AGENT_DOCS_COUNT" -gt 0 ]; then
        cp "$SOURCE_DIR/agent-docs"/*.md "$TARGET_DIR/.cursor/agent-docs/"
        echo "   ✓ Installed $AGENT_DOCS_COUNT agent-docs files"
    else
        echo "   ⚠️  No agent-docs files found in $SOURCE_DIR/agent-docs/"
    fi
    echo ""
fi

# Copy agents.md template if it exists
if [ -f "$SOURCE_DIR/templates/agents-example.md" ]; then
    if [ -f "$TARGET_DIR/.cursor/agents.md" ]; then
        echo "⚠️  agents.md already exists in target"
        read -p "   Overwrite? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$SOURCE_DIR/templates/agents-example.md" "$TARGET_DIR/.cursor/agents.md"
            echo "   ✓ Overwrote $TARGET_DIR/.cursor/agents.md"
        else
            echo "   ⊘ Kept existing $TARGET_DIR/.cursor/agents.md"
        fi
    else
        cp "$SOURCE_DIR/templates/agents-example.md" "$TARGET_DIR/.cursor/agents.md"
        echo "   ✓ Installed agents.md template"
    fi
    echo ""
fi

# Create docs/specs directory for generated files
echo "📂 Creating docs directory structure..."
mkdir -p "$TARGET_DIR/docs/specs"
echo "   ✓ Created $TARGET_DIR/docs/specs/"
echo ""

# Verify installation
echo "🔍 Verifying installation..."
VERIFY_OK=true

if [ ! -d "$TARGET_DIR/.cursor/commands" ]; then
    echo "   ❌ $TARGET_DIR/.cursor/commands/ not found"
    VERIFY_OK=false
fi

if [ ! -d "$TARGET_DIR/.cursor/scripts" ]; then
    echo "   ❌ $TARGET_DIR/.cursor/scripts/ not found"
    VERIFY_OK=false
fi

if [ ! -d "$TARGET_DIR/.cursor/templates" ]; then
    echo "   ❌ $TARGET_DIR/.cursor/templates/ not found"
    VERIFY_OK=false
fi

if [ ! -d "$TARGET_DIR/.cursor/agent-docs" ]; then
    echo "   ❌ $TARGET_DIR/.cursor/agent-docs/ not found"
    VERIFY_OK=false
fi

INSTALLED_COMMANDS=$(ls "$TARGET_DIR/.cursor/commands"/*.md 2>/dev/null | wc -l)
if [ "$INSTALLED_COMMANDS" -lt 11 ]; then
    echo "   ⚠️  Expected 11 commands, found $INSTALLED_COMMANDS"
    VERIFY_OK=false
fi

INSTALLED_SCRIPTS=$(ls "$TARGET_DIR/.cursor/scripts"/*.sh 2>/dev/null | wc -l)
if [ "$INSTALLED_SCRIPTS" -lt 18 ]; then
    echo "   ⚠️  Expected 18+ scripts, found $INSTALLED_SCRIPTS"
    VERIFY_OK=false
fi

INSTALLED_TEMPLATES=$(ls "$TARGET_DIR/.cursor/templates"/*.md 2>/dev/null | wc -l)
if [ "$INSTALLED_TEMPLATES" -lt 4 ]; then
    echo "   ⚠️  Expected 4 templates, found $INSTALLED_TEMPLATES"
    VERIFY_OK=false
fi

if [ "$VERIFY_OK" = true ]; then
    echo "   ✓ All files installed correctly"
    echo ""
    
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║              ✅ Installation Complete!                 ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo "📊 Installed:"
    echo "   • $INSTALLED_COMMANDS commands"
    echo "   • $INSTALLED_SCRIPTS scripts"
    echo "   • $INSTALLED_TEMPLATES templates"
    echo ""
    echo "🚀 Quick Start:"
    echo "   1. Open $TARGET_DIR in Cursor IDE"
    echo "   2. Run: /init-project \"My Project Name\""
    echo "   3. Follow the workflow in README.md"
    echo ""
    echo "📚 Documentation:"
    echo "   • README.md - Complete workflow guide"
    echo "   • QUICK-REFERENCE.md - Command cheat sheet"
    echo "   • NEW-COMMANDS-README.md - Detailed command docs"
    echo ""
    echo "💡 Test your installation:"
    echo "   /init-project \"Test Project\""
    echo ""
else
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║        ⚠️  Installation Completed with Warnings        ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo "Some files may be missing. Check the warnings above."
    echo "You can still use the workflow, but some commands may not work."
    echo ""
fi

echo "Need help? Check README.md or the troubleshooting section."
echo ""
