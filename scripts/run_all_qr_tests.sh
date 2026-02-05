#!/bin/bash
# Comprehensive QR code testing script
# Runs all QR code related tests: backend API, validation, and integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}QR CODE COMPREHENSIVE TEST SUITE${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if backend is running
echo -e "${YELLOW}Checking backend status...${NC}"
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend is running${NC}"
    BACKEND_RUNNING=true
else
    echo -e "${RED}✗ Backend is not running${NC}"
    echo -e "${YELLOW}  Start backend with: make up${NC}"
    BACKEND_RUNNING=false
fi
echo ""

# Test 1: QR Code Generation
echo -e "${BLUE}TEST 1: QR Code Generation${NC}"
echo "----------------------------------------"
cd "$PROJECT_ROOT"
if python3 scripts/generate_qr.py TEST > /dev/null 2>&1; then
    echo -e "${GREEN}✓ QR code generation works${NC}"
else
    echo -e "${RED}✗ QR code generation failed${NC}"
fi
echo ""

# Test 2: Backend API Tests (if backend is running)
if [ "$BACKEND_RUNNING" = true ]; then
    echo -e "${BLUE}TEST 2: Backend API Tests${NC}"
    echo "----------------------------------------"
    cd "$PROJECT_ROOT/backend"
    
    # Check if pytest is available
    if command -v pytest &> /dev/null; then
        if [ -d "tests" ]; then
            echo "Running pytest..."
            if pytest tests/test_qr_code_api.py tests/test_qr_code_validation.py -v; then
                echo -e "${GREEN}✓ Backend API tests passed${NC}"
            else
                echo -e "${RED}✗ Backend API tests failed${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ Tests directory not found, skipping pytest${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ pytest not found, skipping backend tests${NC}"
        echo "  Install with: pip install pytest pytest-asyncio httpx"
    fi
    echo ""
    
    # Test 3: Python Test Script
    echo -e "${BLUE}TEST 3: Python Integration Tests${NC}"
    echo "----------------------------------------"
    cd "$PROJECT_ROOT"
    if python3 scripts/test_qr_codes.py --api-url http://localhost:8000; then
        echo -e "${GREEN}✓ Integration tests passed${NC}"
    else
        echo -e "${RED}✗ Integration tests failed${NC}"
    fi
    echo ""
    
    # Test 3.5: E2E Full Flow Test
    echo -e "${BLUE}TEST 3.5: E2E Full Flow Test${NC}"
    echo "----------------------------------------"
    cd "$PROJECT_ROOT"
    if python3 scripts/e2e_test_qr_flow.py --api-url http://localhost:8000; then
        echo -e "${GREEN}✓ E2E full flow test passed${NC}"
    else
        echo -e "${RED}✗ E2E full flow test failed${NC}"
    fi
    echo ""
else
    echo -e "${YELLOW}Skipping backend tests (backend not running)${NC}"
    echo ""
fi

# Test 4: Mobile Tests (if Flutter is available)
echo -e "${BLUE}TEST 4: Mobile Integration Tests${NC}"
echo "----------------------------------------"
cd "$PROJECT_ROOT/mobile"

if command -v flutter &> /dev/null; then
    if [ -d "integration_test" ]; then
        echo "Running Flutter integration tests..."
        if flutter test integration_test/qr_scan_flow_test.dart; then
            echo -e "${GREEN}✓ Mobile integration tests passed${NC}"
        else
            echo -e "${RED}✗ Mobile integration tests failed${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ integration_test directory not found${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Flutter not found, skipping mobile tests${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}TEST SUMMARY${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}All QR code tests completed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Ensure backend is running: make up"
echo "  2. Run full test suite: python3 scripts/test_qr_codes.py"
echo "  3. Test QR scanning in mobile app"
echo ""
