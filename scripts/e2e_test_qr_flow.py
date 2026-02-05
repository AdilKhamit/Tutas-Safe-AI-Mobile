#!/usr/bin/env python3
"""
E2E Test for complete QR code flow
Tests: Create pipe → Generate QR → Scan QR → Get pipe data → Download QR image
"""
import sys
import uuid
import requests
import time
from pathlib import Path
from typing import Optional, Dict, Any


class QRCodeE2ETester:
    """End-to-end test for QR code complete flow"""
    
    def __init__(self, api_url: str = "http://localhost:8000"):
        self.api_url = api_url
        self.test_results = []
        self.passed = 0
        self.failed = 0
        self.created_pipe: Optional[Dict[str, Any]] = None
    
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
    
    def step_1_check_backend_health(self) -> bool:
        """Step 1: Check backend is running"""
        print("\n" + "="*60)
        print("STEP 1: Backend Health Check")
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
    
    def step_2_create_pipe(self) -> bool:
        """Step 2: Create a new pipe with QR code"""
        print("\n" + "="*60)
        print("STEP 2: Create Pipe")
        print("="*60)
        
        pipe_data = {
            "company": "E2E-TEST",
            "manufacturer": "E2E Test Manufacturer",
            "material": "Steel",
            "diameter_mm": 150,
            "wall_thickness_mm": 6.0,
            "length_meters": 200.0,
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
                self.created_pipe = response.json()
                qr_code = self.created_pipe.get("qr_code", "")
                
                # Validate QR code format
                is_valid = (
                    qr_code.startswith("PL-E2E-TEST-") and
                    len(qr_code) > 15
                )
                
                if is_valid:
                    self.log_test("Create Pipe", True, 
                                 f"Created pipe with QR: {qr_code}")
                    return True
                else:
                    self.log_test("Create Pipe", False, 
                                 f"Invalid QR code format: {qr_code}")
                    return False
            else:
                self.log_test("Create Pipe", False, 
                             f"Status code: {response.status_code}, "
                             f"Response: {response.text[:100]}")
                return False
        except Exception as e:
            self.log_test("Create Pipe", False, f"Error: {e}")
            return False
    
    def step_3_get_pipe_by_qr_code(self) -> bool:
        """Step 3: Get pipe data by scanning QR code"""
        print("\n" + "="*60)
        print("STEP 3: Get Pipe by QR Code (Simulate Scan)")
        print("="*60)
        
        if not self.created_pipe:
            self.log_test("Get Pipe by QR Code", False, 
                         "No pipe created in previous step")
            return False
        
        qr_code = self.created_pipe.get("qr_code", "")
        if not qr_code:
            self.log_test("Get Pipe by QR Code", False, 
                         "No QR code in created pipe")
            return False
        
        try:
            response = requests.get(
                f"{self.api_url}/api/v1/pipes/qr/{qr_code}",
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                
                # Verify we got the correct pipe
                if data.get("qr_code") == qr_code:
                    has_required_fields = all(key in data for key in [
                        "id", "qr_code", "current_status"
                    ])
                    
                    if has_required_fields:
                        self.log_test("Get Pipe by QR Code", True, 
                                     f"Retrieved pipe: {data.get('manufacturer', 'N/A')}")
                        return True
                    else:
                        self.log_test("Get Pipe by QR Code", False, 
                                     "Missing required fields")
                        return False
                else:
                    self.log_test("Get Pipe by QR Code", False, 
                                 "QR code mismatch")
                    return False
            else:
                self.log_test("Get Pipe by QR Code", False, 
                             f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("Get Pipe by QR Code", False, f"Error: {e}")
            return False
    
    def step_4_generate_qr_code_image(self) -> bool:
        """Step 4: Generate QR code image"""
        print("\n" + "="*60)
        print("STEP 4: Generate QR Code Image")
        print("="*60)
        
        if not self.created_pipe:
            self.log_test("Generate QR Code Image", False, 
                         "No pipe created")
            return False
        
        qr_code = self.created_pipe.get("qr_code", "")
        if not qr_code:
            self.log_test("Generate QR Code Image", False, 
                         "No QR code available")
            return False
        
        try:
            response = requests.get(
                f"{self.api_url}/api/v1/pipes/qr-code/{qr_code}/image?size=400",
                timeout=10
            )
            
            if response.status_code == 200:
                content_type = response.headers.get("content-type", "")
                is_png = content_type == "image/png"
                has_content = len(response.content) > 0
                
                if is_png and has_content:
                    # Optionally save the image
                    output_dir = Path("qr_codes")
                    output_dir.mkdir(exist_ok=True)
                    filename = output_dir / f"e2e_test_{qr_code.replace('-', '_')}.png"
                    filename.write_bytes(response.content)
                    
                    self.log_test("Generate QR Code Image", True, 
                                 f"Generated {len(response.content)} bytes PNG, "
                                 f"saved to {filename}")
                    return True
                else:
                    self.log_test("Generate QR Code Image", False, 
                                 f"Content type: {content_type}, "
                                 f"Has content: {has_content}")
                    return False
            else:
                self.log_test("Generate QR Code Image", False, 
                             f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("Generate QR Code Image", False, f"Error: {e}")
            return False
    
    def step_5_get_qr_code_by_pipe_id(self) -> bool:
        """Step 5: Get QR code image by pipe ID"""
        print("\n" + "="*60)
        print("STEP 5: Get QR Code Image by Pipe ID")
        print("="*60)
        
        if not self.created_pipe:
            self.log_test("Get QR Code by Pipe ID", False, 
                         "No pipe created")
            return False
        
        pipe_id = self.created_pipe.get("id", "")
        if not pipe_id:
            self.log_test("Get QR Code by Pipe ID", False, 
                         "No pipe ID available")
            return False
        
        try:
            response = requests.get(
                f"{self.api_url}/api/v1/pipes/{pipe_id}/qr-code?size=300",
                timeout=10
            )
            
            if response.status_code == 200:
                content_type = response.headers.get("content-type", "")
                is_png = content_type == "image/png"
                has_content = len(response.content) > 0
                
                if is_png and has_content:
                    self.log_test("Get QR Code by Pipe ID", True, 
                                 f"Generated {len(response.content)} bytes PNG")
                    return True
                else:
                    self.log_test("Get QR Code by Pipe ID", False, 
                                 f"Content type: {content_type}, "
                                 f"Has content: {has_content}")
                    return False
            else:
                self.log_test("Get QR Code by Pipe ID", False, 
                             f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("Get QR Code by Pipe ID", False, f"Error: {e}")
            return False
    
    def step_6_validate_qr_code_format(self) -> bool:
        """Step 6: Validate QR code format throughout the flow"""
        print("\n" + "="*60)
        print("STEP 6: Validate QR Code Format")
        print("="*60)
        
        if not self.created_pipe:
            self.log_test("Validate QR Code Format", False, 
                         "No pipe created")
            return False
        
        qr_code = self.created_pipe.get("qr_code", "")
        if not qr_code:
            self.log_test("Validate QR Code Format", False, 
                         "No QR code available")
            return False
        
        # Validate format: PL-{COMPANY}-{UUID}
        parts = qr_code.split('-')
        is_valid = (
            len(parts) >= 3 and
            parts[0] == "PL" and
            parts[1] == "E2E-TEST" and
            len(parts[2]) > 0
        )
        
        if is_valid:
            self.log_test("Validate QR Code Format", True, 
                         f"QR code format is valid: {qr_code}")
            return True
        else:
            self.log_test("Validate QR Code Format", False, 
                         f"Invalid QR code format: {qr_code}")
            return False
    
    def run_full_flow(self) -> int:
        """Run complete E2E flow"""
        print("\n" + "="*60)
        print("QR CODE E2E TEST - COMPLETE FLOW")
        print("="*60)
        print(f"API URL: {self.api_url}")
        print("="*60)
        
        # Step 1: Check backend
        if not self.step_1_check_backend_health():
            print("\n⚠️  Backend is not running. Cannot continue E2E test.")
            print("   Start backend with: make up")
            return 1
        
        # Step 2: Create pipe
        if not self.step_2_create_pipe():
            print("\n❌ Failed to create pipe. Cannot continue.")
            return 1
        
        # Step 3: Get pipe by QR code (simulate scan)
        if not self.step_3_get_pipe_by_qr_code():
            print("\n❌ Failed to get pipe by QR code.")
            return 1
        
        # Step 4: Generate QR code image
        if not self.step_4_generate_qr_code_image():
            print("\n❌ Failed to generate QR code image.")
            return 1
        
        # Step 5: Get QR code by pipe ID
        if not self.step_5_get_qr_code_by_pipe_id():
            print("\n❌ Failed to get QR code by pipe ID.")
            return 1
        
        # Step 6: Validate QR code format
        if not self.step_6_validate_qr_code_format():
            print("\n❌ QR code format validation failed.")
            return 1
        
        # Print summary
        print("\n" + "="*60)
        print("E2E TEST SUMMARY")
        print("="*60)
        print(f"✅ Passed: {self.passed}")
        print(f"❌ Failed: {self.failed}")
        print(f"📊 Total:  {self.passed + self.failed}")
        print("="*60)
        
        if self.created_pipe:
            print(f"\n📋 Created Pipe:")
            print(f"   ID: {self.created_pipe.get('id')}")
            print(f"   QR Code: {self.created_pipe.get('qr_code')}")
            print(f"   Manufacturer: {self.created_pipe.get('manufacturer')}")
        
        if self.failed == 0:
            print("\n🎉 All E2E tests passed!")
            print("\n✅ Complete flow verified:")
            print("   1. Backend health check ✓")
            print("   2. Create pipe with QR code ✓")
            print("   3. Get pipe by QR code (scan simulation) ✓")
            print("   4. Generate QR code image ✓")
            print("   5. Get QR code by pipe ID ✓")
            print("   6. Validate QR code format ✓")
            return 0
        else:
            print(f"\n⚠️  {self.failed} test(s) failed")
            return 1


def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="E2E test for QR code flow")
    parser.add_argument(
        "--api-url",
        default="http://localhost:8000",
        help="Backend API URL (default: http://localhost:8000)"
    )
    
    args = parser.parse_args()
    
    tester = QRCodeE2ETester(api_url=args.api_url)
    exit_code = tester.run_full_flow()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
