#!/bin/bash
# Analyze project status from tasks file

set -e

TASKS_FILE="$1"

if [ ! -f "$TASKS_FILE" ]; then
    echo "ERROR: Tasks file not found: $TASKS_FILE"
    exit 1
fi

# Extract feature name
FEATURE_NAME=$(basename "$TASKS_FILE" -tasks.md)

echo "╔═══════════════════════════════════════════════════════╗"
echo "║       PROJECT STATUS - ${FEATURE_NAME}                "
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "📊 PHASE OVERVIEW"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Initialize counters
TOTAL_TASKS=0
COMPLETED_TASKS=0
CURRENT_PHASE=""
PHASE_NUM=0

# Process tasks file line by line
while IFS= read -r line; do
    # Detect phase headers
    if [[ "$line" =~ ^##[[:space:]]Phase ]]; then
        # Save previous phase stats if any
        if [ -n "$CURRENT_PHASE" ] && [ "$PHASE_TASKS" -gt 0 ]; then
            PHASE_PCT=$((PHASE_COMPLETED * 100 / PHASE_TASKS))
            
            # Determine status
            if [ "$PHASE_COMPLETED" -eq "$PHASE_TASKS" ]; then
                STATUS="✅ Complete"
            elif [ "$PHASE_COMPLETED" -gt 0 ]; then
                STATUS="🔄 In Progress"
            else
                STATUS="⏸️  Not Started"
            fi
            
            echo "Phase $PHASE_NUM: $CURRENT_PHASE"
            echo "├─ Status: $STATUS"
            echo "├─ Tasks: $PHASE_COMPLETED/$PHASE_TASKS ($PHASE_PCT%)"
            echo "└─ Progress: $(generate_progress_bar $PHASE_PCT)"
            echo ""
        fi
        
        # Start new phase
        ((PHASE_NUM++))
        CURRENT_PHASE=$(echo "$line" | sed 's/## Phase [0-9]*: //')
        PHASE_TASKS=0
        PHASE_COMPLETED=0
    fi
    
    # Count tasks
    if [[ "$line" =~ ^-[[:space:]]\[[[:space:]xX]\][[:space:]]T[0-9]+ ]]; then
        ((PHASE_TASKS++))
        ((TOTAL_TASKS++))
        
        # Check if completed
        if [[ "$line" =~ ^-[[:space:]]\[x\] ]] || [[ "$line" =~ ^-[[:space:]]\[X\] ]]; then
            ((PHASE_COMPLETED++))
            ((COMPLETED_TASKS++))
        fi
    fi
done < "$TASKS_FILE"

# Output last phase
if [ -n "$CURRENT_PHASE" ] && [ "$PHASE_TASKS" -gt 0 ]; then
    PHASE_PCT=$((PHASE_COMPLETED * 100 / PHASE_TASKS))
    
    if [ "$PHASE_COMPLETED" -eq "$PHASE_TASKS" ]; then
        STATUS="✅ Complete"
    elif [ "$PHASE_COMPLETED" -gt 0 ]; then
        STATUS="🔄 In Progress"
    else
        STATUS="⏸️  Not Started"
    fi
    
    echo "Phase $PHASE_NUM: $CURRENT_PHASE"
    echo "├─ Status: $STATUS"
    echo "├─ Tasks: $PHASE_COMPLETED/$PHASE_TASKS ($PHASE_PCT%)"
    echo "└─ Progress: $(generate_progress_bar $PHASE_PCT)"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📈 OVERALL PROGRESS"
echo ""

# Calculate overall percentage
if [ "$TOTAL_TASKS" -gt 0 ]; then
    OVERALL_PCT=$((COMPLETED_TASKS * 100 / TOTAL_TASKS))
else
    OVERALL_PCT=0
fi

echo "Total Tasks:     $COMPLETED_TASKS/$TOTAL_TASKS ($OVERALL_PCT%)"
echo "Completed:       $COMPLETED_TASKS tasks"
echo "Remaining:       $((TOTAL_TASKS - COMPLETED_TASKS)) tasks"
echo ""
echo "Progress Bar: $(generate_progress_bar $OVERALL_PCT)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check MVP status
if grep -q "MVP" "$TASKS_FILE"; then
    echo "🎯 MVP STATUS"
    echo ""
    
    MVP_LINE=$(grep -m1 "MVP" "$TASKS_FILE" || echo "")
    if [ -n "$MVP_LINE" ]; then
        echo "Definition: $MVP_LINE"
    fi
    
    # Find MVP phase and check completion
    MVP_PHASE=$(grep -n "MVP" "$TASKS_FILE" | head -1 | cut -d: -f1)
    if [ -n "$MVP_PHASE" ]; then
        # Count tasks in MVP phase (simplified)
        MVP_TOTAL=$(awk -v start="$MVP_PHASE" 'NR>=start && /^## Phase/ && NR!=start {exit} /^- \[/ {count++} END {print count}' "$TASKS_FILE")
        MVP_DONE=$(awk -v start="$MVP_PHASE" 'NR>=start && /^## Phase/ && NR!=start {exit} /^- \[x\]/ || /^- \[X\]/ {count++} END {print count}' "$TASKS_FILE")
        
        if [ "$MVP_TOTAL" -gt 0 ]; then
            MVP_PCT=$((MVP_DONE * 100 / MVP_TOTAL))
            
            if [ "$MVP_PCT" -eq 100 ]; then
                echo "Status: ✅ Complete"
            elif [ "$MVP_PCT" -gt 0 ]; then
                echo "Status: 🔄 In Progress ($MVP_PCT%)"
            else
                echo "Status: ⏸️  Not Started"
            fi
        fi
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

# Find next uncompleted task
echo "📋 NEXT TASKS"
echo ""

NEXT_COUNT=0
while IFS= read -r line; do
    if [[ "$line" =~ ^-[[:space:]]\[[[:space:]]\][[:space:]]T[0-9]+ ]] && [ "$NEXT_COUNT" -lt 3 ]; then
        ((NEXT_COUNT++))
        TASK_ID=$(echo "$line" | grep -oE "T[0-9]+" | head -1)
        TASK_DESC=$(echo "$line" | sed 's/^- \[ \] T[0-9]*: //')
        echo "$NEXT_COUNT. $TASK_ID: $TASK_DESC"
    fi
done < "$TASKS_FILE"

if [ "$NEXT_COUNT" -eq 0 ]; then
    echo "🎉 All tasks complete!"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Last Updated: $(date '+%Y-%m-%d %H:%M:%S')"

# Helper function to generate progress bar
generate_progress_bar() {
    local percent=$1
    local filled=$((percent / 5))
    local empty=$((20 - filled))
    
    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "] %d%%" "$percent"
}

export -f generate_progress_bar
