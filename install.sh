#!/bin/bash
# Cursor Workflow Installer
# Copies all workflow files to .cursor/ directory

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║     Cursor AI-Assisted Development Workflow            ║"
echo "║                   Installer                            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if we're in the right directory
if [ ! -d "commands" ] || [ ! -d "scripts" ] || [ ! -d "templates" ]; then
    echo "❌ ERROR: Must run from workflow root directory"
    echo ""
    echo "Expected directory structure:"
    echo "  commands/    (10 command files)"
    echo "  scripts/     (20+ script files)"
    echo "  templates/   (4 template files)"
    echo ""
    exit 1
fi

# Create .cursor directory structure
echo "📁 Creating .cursor directory structure..."
mkdir -p .cursor/{commands,scripts,templates,agent-docs}
echo "   ✓ Created .cursor/commands/"
echo "   ✓ Created .cursor/scripts/"
echo "   ✓ Created .cursor/templates/"
echo "   ✓ Created .cursor/agent-docs/"
echo ""

# Copy commands
echo "📋 Installing commands..."
COMMAND_COUNT=$(ls commands/*.md 2>/dev/null | wc -l)
if [ "$COMMAND_COUNT" -gt 0 ]; then
    cp commands/*.md .cursor/commands/
    echo "   ✓ Installed $COMMAND_COUNT commands"
else
    echo "   ⚠️  No command files found in commands/"
fi
echo ""

# Copy scripts
echo "🔧 Installing scripts..."
SCRIPT_COUNT=$(ls scripts/*.sh 2>/dev/null | wc -l)
if [ "$SCRIPT_COUNT" -gt 0 ]; then
    cp scripts/*.sh .cursor/scripts/
    chmod +x .cursor/scripts/*.sh
    echo "   ✓ Installed $SCRIPT_COUNT scripts"
    echo "   ✓ Made scripts executable"
else
    echo "   ⚠️  No script files found in scripts/"
fi
echo ""

# Copy templates
echo "📄 Installing templates..."
TEMPLATE_COUNT=$(ls templates/*.md 2>/dev/null | wc -l)
if [ "$TEMPLATE_COUNT" -gt 0 ]; then
    cp templates/*.md .cursor/templates/
    echo "   ✓ Installed $TEMPLATE_COUNT templates"
else
    echo "   ⚠️  No template files found in templates/"
fi
echo ""

# Copy agent-docs if it exists
if [ -d "agent-docs" ]; then
    echo "📚 Installing agent-docs..."
    mkdir -p .cursor/agent-docs
    AGENT_DOCS_COUNT=$(ls agent-docs/*.md 2>/dev/null | wc -l)
    if [ "$AGENT_DOCS_COUNT" -gt 0 ]; then
        cp agent-docs/*.md .cursor/agent-docs/
        echo "   ✓ Installed $AGENT_DOCS_COUNT agent-docs files"
    else
        echo "   ⚠️  No agent-docs files found in agent-docs/"
    fi
    echo ""
fi

# Copy agents.md if it exists
if [ -f "agents.md" ]; then
    if [ -f ".cursor/agents.md" ]; then
        echo "⚠️  agents.md already exists"
        read -p "   Overwrite? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp agents.md .cursor/agents.md
            echo "   ✓ Overwrote .cursor/agents.md"
        else
            echo "   ⊘ Kept existing .cursor/agents.md"
        fi
    else
        cp agents.md .cursor/agents.md
        echo "   ✓ Installed agents.md template"
    fi
    echo ""
fi

# Create docs/specs directory for generated files
echo "📂 Creating docs directory structure..."
mkdir -p docs/specs
echo "   ✓ Created docs/specs/"
echo ""

# Verify installation
echo "🔍 Verifying installation..."
VERIFY_OK=true

if [ ! -d ".cursor/commands" ]; then
    echo "   ❌ .cursor/commands/ not found"
    VERIFY_OK=false
fi

if [ ! -d ".cursor/scripts" ]; then
    echo "   ❌ .cursor/scripts/ not found"
    VERIFY_OK=false
fi

if [ ! -d ".cursor/templates" ]; then
    echo "   ❌ .cursor/templates/ not found"
    VERIFY_OK=false
fi

if [ ! -d ".cursor/agent-docs" ]; then
    echo "   ❌ .cursor/agent-docs/ not found"
    VERIFY_OK=false
fi

INSTALLED_COMMANDS=$(ls .cursor/commands/*.md 2>/dev/null | wc -l)
if [ "$INSTALLED_COMMANDS" -lt 11 ]; then
    echo "   ⚠️  Expected 11 commands, found $INSTALLED_COMMANDS"
    VERIFY_OK=false
fi

INSTALLED_SCRIPTS=$(ls .cursor/scripts/*.sh 2>/dev/null | wc -l)
if [ "$INSTALLED_SCRIPTS" -lt 18 ]; then
    echo "   ⚠️  Expected 18+ scripts, found $INSTALLED_SCRIPTS"
    VERIFY_OK=false
fi

INSTALLED_TEMPLATES=$(ls .cursor/templates/*.md 2>/dev/null | wc -l)
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
    echo "   1. Open this project in Cursor IDE"
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
