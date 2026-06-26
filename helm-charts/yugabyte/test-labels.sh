#!/bin/bash
# Script to test that all objects have Yugabyte labels

set -e

RELEASE_NAME="test-yugabyte"
NAMESPACE="default"

echo "=== Testing Helm Chart Labels ==="
echo ""

# 1. Lint the chart
echo "1. Running helm lint..."
helm lint . || echo "WARNING: Lint found issues"
echo ""

# 2. Render templates and save to file
echo "2. Rendering templates..."
# Check if custom labels should be tested
if [ -n "$TEST_CUSTOM_LABELS" ] && [ "$TEST_CUSTOM_LABELS" = "true" ]; then
    echo "  Rendering with custom labels (commonLabels)..."
    helm template $RELEASE_NAME . \
        --set commonLabels.environment=test \
        --set commonLabels.team=platform \
        --set commonLabels.cost-center=data-infra \
        > /tmp/rendered-templates.yaml
else
    helm template $RELEASE_NAME . > /tmp/rendered-templates.yaml
fi
echo "Templates rendered to /tmp/rendered-templates.yaml"
echo ""

# 3. Check that all objects have labels
echo "3. Checking for objects with labels..."
objects_with_labels=$(grep -A 5 "^kind:" /tmp/rendered-templates.yaml | grep -B 5 "labels:" | grep "^kind:" | wc -l)
echo "Found $objects_with_labels objects with labels"
echo ""

# 4. Check for specific label patterns
echo "4. Checking for Yugabyte label patterns..."
echo ""

echo "Checking for 'yugabyte.labels' template output (heritage, release, chart, component):"
if grep -q "heritage:" /tmp/rendered-templates.yaml && grep -q "release:" /tmp/rendered-templates.yaml && grep -q "chart:" /tmp/rendered-templates.yaml && grep -q "component:" /tmp/rendered-templates.yaml; then
    echo "✓ Found heritage, release, chart, and component labels"
else
    echo "✗ Missing standard labels"
fi
echo ""

echo "Checking for app labels (app or app.kubernetes.io/name):"
if grep -q "app:" /tmp/rendered-templates.yaml || grep -q "app.kubernetes.io/name:" /tmp/rendered-templates.yaml; then
    echo "✓ Found app labels"
else
    echo "✗ Missing app labels"
fi
echo ""

# Check for custom labels if commonLabels are provided
if [ "$TEST_CUSTOM_LABELS" = "true" ]; then
    echo "Checking for custom labels (commonLabels)..."
    # Extract labels section more precisely - look for lines after "labels:" and before next top-level key
    custom_labels=$(awk '/labels:/ {flag=1; next} /^[a-zA-Z]/ && flag {flag=0} flag && /^[[:space:]]+[a-zA-Z0-9_.-]+:/ {print}' /tmp/rendered-templates.yaml | \
        grep -vE "^\s+(app|release|chart|component|heritage|service-type|scope|serviceName|app\.kubernetes\.io/name):" | \
        sed 's/:.*//' | sed 's/^\s*//' | sort -u)

    # Also check for the specific custom labels we set
    if grep -q "environment: test" /tmp/rendered-templates.yaml || \
       grep -q "team: platform" /tmp/rendered-templates.yaml || \
       grep -q "cost-center: data-infra" /tmp/rendered-templates.yaml; then
        echo "✓ Found custom labels from commonLabels"
        echo "  Custom labels detected:"
        grep -E "(environment|team|cost-center):" /tmp/rendered-templates.yaml | head -3 | sed 's/^/    /'
    elif [ -n "$custom_labels" ]; then
        custom_count=$(echo "$custom_labels" | wc -l)
        echo "✓ Found custom labels ($custom_count unique custom label keys)"
        echo "  Sample custom labels found:"
        echo "$custom_labels" | head -5 | sed 's/^/    - /'
    else
        echo "ℹ No custom labels detected in rendered output"
    fi
    echo ""
    
    # Test that chart-managed labels cannot be overridden
    echo "Checking that chart-managed labels are protected from commonLabels override..."
    if grep -q "heritage: Helm" /tmp/rendered-templates.yaml || grep -q "heritage: Tiller" /tmp/rendered-templates.yaml; then
        echo "✓ heritage label is protected (not overridden by commonLabels)"
    else
        echo "✗ heritage label may have been overridden"
    fi
    
    if grep -q "release: \"$RELEASE_NAME\"" /tmp/rendered-templates.yaml || grep -q "release: $RELEASE_NAME" /tmp/rendered-templates.yaml; then
        echo "✓ release label is protected (not overridden by commonLabels)"
    else
        echo "✗ release label may have been overridden"
    fi
    
    if grep -q "chart: \"yugabyte\"" /tmp/rendered-templates.yaml || grep -q "chart: yugabyte" /tmp/rendered-templates.yaml; then
        echo "✓ chart label is protected (not overridden by commonLabels)"
    else
        echo "✗ chart label may have been overridden"
    fi
    
    if grep -q "component: \"yugabytedb\"" /tmp/rendered-templates.yaml || grep -q "component: yugabytedb" /tmp/rendered-templates.yaml; then
        echo "✓ component label is protected (not overridden by commonLabels)"
    else
        echo "✗ component label may have been overridden"
    fi
    
    # Check app labels are protected (service-specific)
    if grep -q "app: \"yb-master\"" /tmp/rendered-templates.yaml || grep -q "app: \"yb-tserver\"" /tmp/rendered-templates.yaml || \
       grep -q "app.kubernetes.io/name: \"yb-master\"" /tmp/rendered-templates.yaml || grep -q "app.kubernetes.io/name: \"yb-tserver\"" /tmp/rendered-templates.yaml; then
        echo "✓ app/app.kubernetes.io/name labels are protected (service-specific, not overridden)"
    else
        echo "✗ app labels may have been overridden"
    fi
    echo ""
fi

# 5. Check specific object types
echo "5. Checking specific object types for labels..."
echo ""

check_object_labels() {
    local kind=$1
    local count=$(grep -c "^kind: $kind" /tmp/rendered-templates.yaml || echo "0")
    if [ "$count" -gt 0 ]; then
        local with_labels=$(grep -A 10 "^kind: $kind" /tmp/rendered-templates.yaml | grep -c "labels:" || echo "0")
        if [ "$with_labels" -eq "$count" ]; then
            echo "✓ All $count $kind objects have labels"
        else
            echo "✗ Some $kind objects missing labels ($with_labels/$count)"
        fi
    else
        echo "- No $kind objects found"
    fi
}

check_object_labels "Secret"
check_object_labels "ConfigMap"
check_object_labels "Service"
check_object_labels "StatefulSet"
check_object_labels "ServiceMonitor"
check_object_labels "Job"
check_object_labels "Certificate"
check_object_labels "Issuer"
check_object_labels "PodDisruptionBudget"
check_object_labels "OpenTelemetryCollector"
echo ""

# 6. Show sample of labels from different objects
echo "6. Sample labels from rendered objects:"
echo ""
# Function to extract complete labels section (until next top-level key)
extract_labels_section() {
    local kind=$1
    awk -v kind="$kind" '
    /^kind: / && $2 == kind {found=1; next}
    found && /labels:/ {in_labels=1; print; next}
    in_labels && /^[a-zA-Z]/ && !/^  / {in_labels=0; found=0; exit}
    in_labels {print}
    ' /tmp/rendered-templates.yaml | head -20
}

echo "--- Sample Secret labels ---"
extract_labels_section "Secret" | head -12
echo ""

echo "--- Sample ConfigMap labels ---"
extract_labels_section "ConfigMap" | head -12
echo ""

echo "--- Sample Service labels ---"
extract_labels_section "Service" | head -20
echo ""

# 7. Count objects without labels (should be minimal - only NOTES.txt, etc.)
echo "7. Checking for objects without labels..."
objects_without_labels=0
current_kind=""
in_object=false
while IFS= read -r line; do
    if [[ "$line" =~ ^kind: ]]; then
        current_kind=$(echo "$line" | awk '{print $2}')
        in_object=true
        has_labels=false
    elif [[ "$line" =~ ^--- ]] && [ "$in_object" = true ]; then
        if [ "$has_labels" = false ] && [ -n "$current_kind" ]; then
            echo "  - $current_kind (missing labels)"
            objects_without_labels=$((objects_without_labels + 1))
        fi
        in_object=false
        current_kind=""
        has_labels=false
    elif [[ "$line" =~ labels: ]] && [ "$in_object" = true ]; then
        has_labels=true
    fi
done < /tmp/rendered-templates.yaml

# Check last object if file doesn't end with ---
if [ "$in_object" = true ] && [ "$has_labels" = false ] && [ -n "$current_kind" ]; then
    echo "  - $current_kind (missing labels)"
    objects_without_labels=$((objects_without_labels + 1))
fi

if [ "$objects_without_labels" -eq 0 ]; then
    echo "✓ All objects have labels"
else
    echo "⚠ Found $objects_without_labels objects without labels"
fi
echo ""

echo "=== Testing Complete ==="
echo ""
echo "To inspect the rendered templates:"
echo "  cat /tmp/rendered-templates.yaml"
echo ""
echo "To check a specific object type:"
echo "  grep -A 20 '^kind: Secret' /tmp/rendered-templates.yaml | head -25"
echo ""
echo "To test with custom labels:"
echo "  TEST_CUSTOM_LABELS=true ./test-labels.sh"
echo "  # or"
echo "  helm template test-release . --set commonLabels.environment=prod --set commonLabels.team=platform"
echo ""
echo "To test that chart-managed labels are protected:"
echo "  helm template test-release . --set commonLabels.heritage=overridden --set commonLabels.release=overridden --set commonLabels.chart=overridden --set commonLabels.component=overridden --set commonLabels.app=overridden"
echo "  # Chart-managed labels (heritage, release, chart, component, app, app.kubernetes.io/name) should NOT be overridden"
echo ""

