#!/usr/bin/env python3
"""
Comprehensive test script for QR code functionality
Tests backend API, QR generation, and validation
"""
import sys
import uuid
import requests
import qrcode
from pathlib import Path
from typing import Optional, Tuple


class QRCodeTester:
    """Comprehensive QR code testing suite"""
    
    def __init__(self, api_url: str = "http://localhost:8000"):
        self.api_url = api_url
        self.test_results = []
        self.passed = 0
        self.failed = 0
    
    def log_test(self, name: str, passed: bool, message: str = ""):
        """Log test result"""
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{status}: {name}")
        if message:
            print(f"   {message}")
        self.test_results.append((name, passed, message))
        if passed:
            self.passed += 1
        else:
            self.failed += 1
    
    def test_qr_code_generation(self) -> Tuple[str, str]:
        """Test QR code generation script"""
        print("\n" + "="*60)
        print("TEST 1: QR Code Generation")
        print("="*60)
        
        try:
            from scripts.generate_qr import generate_qr_code
            
            company = "TEST"
            filename, qr_text = generate_qr_code(company=company, output_dir="qr_codes")
            
            # Validate QR code format
            parts = qr_text.split('-')
            is_valid = (
                len(parts) >= 3 and
                parts[0] == "PL" and
                parts[1] == company.upper()
            )
            
            # Check file exists
            file_exists = Path(filename).exists()
            
            if is_valid and file_exists:
                self.log_test("QR Code Generation", True, f"Generated: {qr_text}")
                return filename, qr_text
            else:
                self.log_test("QR Code Generation", False, 
                             f"Format valid: {is_valid}, File exists: {file_exists}")
                return None, None
        except Exception as e:
            self.log_test("QR Code Generation", False, f"Error: {e}")
            return None, None
    
    def test_qr_code_format_validation(self):
        """Test QR code format validation"""
        print("\n" + "="*60)
        print("TEST 2: QR Code Format Validation")
        print("="*60)
        
        valid_codes = [
            "PL-COMPANY-123e4567-e89b-12d3-a456-426614174000",
            "PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588",
            f"PL-TEST-{uuid.uuid4()}",
        ]
        
        invalid_codes = [
            "INVALID-FORMAT",
            "PL-",
            "PL-COMPANY",
            "",
        ]
        
        # Test valid codes
        for qr_code in valid_codes:
            parts = qr_code.split('-')
            is_valid = len(parts) >= 3 and parts[0] == "PL" and len(parts[1]) > 0
            self.log_test(f"Valid QR: {qr_code[:30]}...", is_valid)
        
        # Test invalid codes
        for qr_code in invalid_codes:
            parts = qr_code.split('-')
            is_invalid = not (len(parts) >= 3 and parts[0] == "PL" and len(parts[1]) > 0)
            self.log_test(f"Invalid QR: {qr_code[:30]}...", is_invalid)
    
    def test_backend_health(self) -> bool:
        """Test backend health endpoint"""
        print("\n" + "="*60)
        print("TEST 3: Backend Health Check")
        print("="*60)
        
        try:
            response = requests.get(f"{self.api_url}/health", timeout=5)
            if response.status_code == 200:
                self.log_test("Backend Health", True, "Backend is running")
                return True
            else:
                self.log_test("Backend Health", False, 
                             f"Status code: {response.status_code}")
                return False
        except requests.exceptions.ConnectionError:
            self.log_test("Backend Health", False, 
                         "Cannot connect to backend. Is it running?")
            return False
        except Exception as e:
            self.log_test("Backend Health", False, f"Error: {e}")
            return False
    
    def test_get_pipe_by_qr_code(self, qr_code: str):
        """Test GET /api/v1/pipes/qr/{qr_code} endpoint"""
        print("\n" + "="*60)
        print("TEST 4: Get Pipe by QR Code API")
        print("="*60)
        
        try:
            response = requests.get(
                f"{self.api_url}/api/v1/pipes/qr/{qr_code}",
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                has_required_fields = all(key in data for key in [
                    "qr_code", "id", "current_status"
                ])
                
                if has_required_fields and data["qr_code"] == qr_code:
                    self.log_test("Get Pipe by QR Code", True, 
                                 f"Retrieved pipe: {data.get('manufacturer', 'N/A')}")
                    return True
                else:
                    self.log_test("Get Pipe by QR Code", False, 
                                 "Missing required fields")
                    return False
            else:
                self.log_test("Get Pipe by QR Code", False, 
                             f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("Get Pipe by QR Code", False, f"Error: {e}")
            return False
    
    def test_create_pipe_with_qr(self, qr_code: Optional[str] = None):
        """Test creating a pipe with QR code"""
        print("\n" + "="*60)
        print("TEST 5: Create Pipe with QR Code")
        print("="*60)
        
        if qr_code is None:
            qr_code = f"PL-TEST-{uuid.uuid4()}"
        
        pipe_data = {
            "company": "TEST",
            "qr_code": qr_code,
            "manufacturer": "Test Manufacturer",
            "material": "Steel",
            "diameter_mm": 100,
            "wall_thickness_mm": 5.0,
            "length_meters": 100.0,
        }
        
        try:
            response = requests.post(
                f"{self.api_url}/api/v1/pipes",
                json=pipe_data,
                headers={
                    "Content-Type": "application/json",
                    "Authorization": "Bearer dev-api-key-12345"
                },
                timeout=10
            )
            
            if response.status_code in [200, 201]:
                data = response.json()
                if data.get("qr_code") == qr_code:
                    self.log_test("Create Pipe with QR Code", True, 
                                 f"Created pipe ID: {data.get('id')}")
                    return data
                else:
                    self.log_test("Create Pipe with QR Code", False, 
                                 "QR code mismatch")
                    return None
            else:
                self.log_test("Create Pipe with QR Code", False, 
                             f"Status code: {response.status_code}, "
                             f"Response: {response.text[:100]}")
                return None
        except Exception as e:
            self.log_test("Create Pipe with QR Code", False, f"Error: {e}")
            return None
    
    def test_get_qr_code_image(self, qr_code: str):
        """Test QR code image generation endpoint"""
        print("\n" + "="*60)
        print("TEST 6: QR Code Image Generation")
        print("="*60)
        
        try:
            response = requests.get(
                f"{self.api_url}/api/v1/pipes/qr-code/{qr_code}/image",
                timeout=10
            )
            
            if response.status_code == 200:
                content_type = response.headers.get("content-type", "")
                is_png = content_type == "image/png"
                has_content = len(response.content) > 0
                
                if is_png and has_content:
                    self.log_test("QR Code Image Generation", True, 
                                 f"Generated {len(response.content)} bytes PNG")
                    return True
                else:
                    self.log_test("QR Code Image Generation", False, 
                                 f"Content type: {content_type}, "
                                 f"Has content: {has_content}")
                    return False
            else:
                self.log_test("QR Code Image Generation", False, 
                             f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("QR Code Image Generation", False, f"Error: {e}")
            return False
    
    def test_qr_code_scanning_flow(self):
        """Test complete QR code scanning flow"""
        print("\n" + "="*60)
        print("TEST 7: Complete QR Code Scanning Flow")
        print("="*60)
        
        # Step 1: Create a pipe
        pipe = self.test_create_pipe_with_qr()
        if not pipe:
            self.log_test("QR Scanning Flow", False, "Failed to create pipe")
            return False
        
        qr_code = pipe["qr_code"]
        
        # Step 2: Get pipe by QR code
        if not self.test_get_pipe_by_qr_code(qr_code):
            self.log_test("QR Scanning Flow", False, "Failed to get pipe by QR")
            return False
        
        # Step 3: Generate QR code image
        if not self.test_get_qr_code_image(qr_code):
            self.log_test("QR Scanning Flow", False, "Failed to generate image")
            return False
        
        self.log_test("QR Scanning Flow", True, "All steps completed")
        return True
    
    def run_all_tests(self):
        """Run all tests"""
        print("\n" + "="*60)
        print("QR CODE COMPREHENSIVE TEST SUITE")
        print("="*60)
        
        # Test 1: QR Code Generation
        filename, qr_code = self.test_qr_code_generation()
        
        # Test 2: Format Validation
        self.test_qr_code_format_validation()
        
        # Test 3: Backend Health
        if not self.test_backend_health():
            print("\n⚠️  Backend is not running. Some tests will be skipped.")
            print("   Start backend with: make up")
            return
        
        # Test 4: Get Pipe by QR Code (with generated QR)
        if qr_code:
            self.test_get_pipe_by_qr_code(qr_code)
        
        # Test 5: Create Pipe
        pipe = self.test_create_pipe_with_qr()
        
        # Test 6: QR Code Image
        if qr_code:
            self.test_get_qr_code_image(qr_code)
        
        # Test 7: Complete Flow
        self.test_qr_code_scanning_flow()
        
        # Print summary
        print("\n" + "="*60)
        print("TEST SUMMARY")
        print("="*60)
        print(f"✅ Passed: {self.passed}")
        print(f"❌ Failed: {self.failed}")
        print(f"📊 Total:  {self.passed + self.failed}")
        print("="*60)
        
        if self.failed == 0:
            print("\n🎉 All tests passed!")
            return 0
        else:
            print(f"\n⚠️  {self.failed} test(s) failed")
            return 1


def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Test QR code functionality")
    parser.add_argument(
        "--api-url",
        default="http://localhost:8000",
        help="Backend API URL (default: http://localhost:8000)"
    )
    
    args = parser.parse_args()
    
    tester = QRCodeTester(api_url=args.api_url)
    exit_code = tester.run_all_tests()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
