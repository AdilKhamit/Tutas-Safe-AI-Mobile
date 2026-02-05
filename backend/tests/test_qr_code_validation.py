"""
Tests for QR code format validation and utilities
"""
import pytest
import uuid
import re


class TestQRCodeValidation:
    """Test suite for QR code validation logic"""
    
    QR_CODE_PATTERN = re.compile(r'^PL-[A-Z0-9]+-[A-Za-z0-9\-]+$')
    
    def test_valid_qr_code_pattern(self):
        """Test valid QR code patterns"""
        valid_codes = [
            "PL-COMPANY-123e4567-e89b-12d3-a456-426614174000",
            "PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588",
            "PL-TEST-abc123",
            "PL-COMPANY-123",
            f"PL-COMPANY-{uuid.uuid4()}",
        ]
        
        for qr_code in valid_codes:
            assert self.QR_CODE_PATTERN.match(qr_code), f"QR code {qr_code} should be valid"
    
    def test_invalid_qr_code_pattern(self):
        """Test invalid QR code patterns"""
        invalid_codes = [
            "INVALID-FORMAT",
            "PL-",
            "PL-COMPANY",
            "COMPANY-123",
            "",
            "PL-COMPANY-",
            "pl-company-123",  # lowercase prefix
        ]
        
        for qr_code in invalid_codes:
            assert not self.QR_CODE_PATTERN.match(qr_code), f"QR code {qr_code} should be invalid"
    
    def test_qr_code_structure(self):
        """Test QR code structure parsing"""
        qr_code = "PL-COMPANY-123e4567-e89b-12d3-a456-426614174000"
        parts = qr_code.split('-')
        
        assert len(parts) >= 3
        assert parts[0] == "PL"
        assert parts[1] == "COMPANY"
        assert len(parts[2]) > 0
    
    def test_company_name_extraction(self):
        """Test extracting company name from QR code"""
        test_cases = [
            ("PL-COMPANY-123", "COMPANY"),
            ("PL-TUTAS-456", "TUTAS"),
            ("PL-MYCOMPANY-789", "MYCOMPANY"),
            ("PL-COMPANY-123e4567-e89b-12d3-a456-426614174000", "COMPANY"),
        ]
        
        for qr_code, expected_company in test_cases:
            parts = qr_code.split('-')
            company = parts[1] if len(parts) > 1 else "COMPANY"
            assert company == expected_company, f"Expected {expected_company}, got {company}"
    
    def test_uuid_extraction(self):
        """Test extracting UUID from QR code"""
        test_uuid = str(uuid.uuid4())
        qr_code = f"PL-COMPANY-{test_uuid}"
        
        parts = qr_code.split('-')
        # UUID is everything after company name
        uuid_part = '-'.join(parts[2:])
        
        assert uuid_part == test_uuid
    
    def test_qr_code_generation_format(self):
        """Test QR code generation follows correct format"""
        company = "TEST"
        pipe_uuid = str(uuid.uuid4())
        qr_code = f"PL-{company.upper()}-{pipe_uuid}"
        
        assert qr_code.startswith("PL-")
        assert qr_code.split('-')[1] == company.upper()
        assert self.QR_CODE_PATTERN.match(qr_code)


class TestQRCodeUtilities:
    """Test utility functions for QR codes"""
    
    @staticmethod
    def parse_qr_code(qr_code: str) -> dict:
        """Parse QR code into components"""
        parts = qr_code.split('-')
        if len(parts) < 3:
            return {"valid": False}
        
        return {
            "valid": True,
            "prefix": parts[0],
            "company": parts[1],
            "identifier": '-'.join(parts[2:]),
        }
    
    def test_parse_valid_qr_code(self):
        """Test parsing valid QR code"""
        qr_code = "PL-COMPANY-123e4567-e89b-12d3-a456-426614174000"
        parsed = self.parse_qr_code(qr_code)
        
        assert parsed["valid"] is True
        assert parsed["prefix"] == "PL"
        assert parsed["company"] == "COMPANY"
        assert parsed["identifier"] == "123e4567-e89b-12d3-a456-426614174000"
    
    def test_parse_invalid_qr_code(self):
        """Test parsing invalid QR code"""
        invalid_codes = [
            "INVALID",
            "PL-",
            "PL-COMPANY",
        ]
        
        for qr_code in invalid_codes:
            parsed = self.parse_qr_code(qr_code)
            assert parsed["valid"] is False
    
    def test_validate_qr_code_format(self):
        """Test QR code format validation function"""
        def validate_qr_code(qr_code: str) -> bool:
            if not qr_code:
                return False
            parts = qr_code.split('-')
            if len(parts) < 3:
                return False
            if parts[0] != "PL":
                return False
            if not parts[1]:
                return False
            return True
        
        assert validate_qr_code("PL-COMPANY-123") is True
        assert validate_qr_code("PL-TEST-456") is True
        assert validate_qr_code("INVALID") is False
        assert validate_qr_code("") is False
        assert validate_qr_code("PL-") is False
        assert validate_qr_code("PL-COMPANY") is False
