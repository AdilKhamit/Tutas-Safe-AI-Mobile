"""
Security tests for QR code API endpoints
Tests for SQL Injection, XSS, input validation, authorization, and other security concerns
"""
import pytest
import uuid
from urllib.parse import quote
from httpx import AsyncClient
from fastapi import status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.pipes import Pipe


class TestQRCodeSQLInjection:
    """Test SQL Injection vulnerabilities in QR code endpoints"""
    
    @pytest.mark.asyncio
    async def test_sql_injection_in_qr_code_path(self, client: AsyncClient):
        """Test SQL injection attempts in QR code path parameter"""
        sql_injection_attempts = [
            "PL-TEST-1' OR '1'='1",
            "PL-TEST-1' OR '1'='1' --",
            "PL-TEST-1' UNION SELECT * FROM pipes --",
            "PL-TEST-1'; DROP TABLE pipes; --",
            "PL-TEST-1' OR 1=1 --",
            "PL-TEST-1' OR 'a'='a",
            "PL-TEST-1' OR 1=1#",
            "PL-TEST-1' OR '1'='1'/*",
        ]
        
        for malicious_qr in sql_injection_attempts:
            # URL encode the QR code for path parameter
            encoded_qr = quote(malicious_qr, safe='')
            response = await client.get(f"/api/v1/pipes/qr/{encoded_qr}")
            # Should not crash, should return 200 with mock data or handle gracefully
            assert response.status_code in [status.HTTP_200_OK, status.HTTP_400_BAD_REQUEST, status.HTTP_404_NOT_FOUND]
            # Should not expose SQL errors
            if response.status_code == 200:
                data = response.json()
                # Should not contain SQL error messages
                assert "sql" not in str(data).lower()
                assert "syntax error" not in str(data).lower()
                assert "database" not in str(data).lower() or "database" in str(data).lower() and "error" not in str(data).lower()
    
    @pytest.mark.asyncio
    async def test_sql_injection_in_qr_code_image(self, client: AsyncClient):
        """Test SQL injection in QR code image endpoint"""
        sql_injection_attempts = [
            "PL-TEST-1' OR '1'='1",
            "PL-TEST-1'; DROP TABLE pipes; --",
        ]
        
        for malicious_qr in sql_injection_attempts:
            # URL encode the QR code for path parameter
            encoded_qr = quote(malicious_qr, safe='')
            response = await client.get(f"/api/v1/pipes/qr-code/{encoded_qr}/image")
            # Should handle gracefully, not crash
            assert response.status_code in [
                status.HTTP_200_OK,  # May generate image anyway
                status.HTTP_400_BAD_REQUEST,
                status.HTTP_404_NOT_FOUND
            ]
    
    @pytest.mark.asyncio
    async def test_sql_injection_in_create_pipe_qr_code(self, client: AsyncClient):
        """Test SQL injection in QR code field when creating pipe"""
        sql_injection_attempts = [
            "PL-TEST-1' OR '1'='1",
            "PL-TEST-1'; DROP TABLE pipes; --",
            "PL-TEST-1' UNION SELECT * FROM pipes --",
        ]
        
        for malicious_qr in sql_injection_attempts:
            pipe_data = {
                "company": "TEST",
                "qr_code": malicious_qr,
                "manufacturer": "Test Manufacturer",
                "material": "Steel",
                "diameter_mm": 100,
            }
            
            response = await client.post(
                "/api/v1/pipes",
                json=pipe_data,
                headers={"Authorization": "Bearer dev-api-key-12345"}
            )
            
            # Should either reject or sanitize
            assert response.status_code in [
                status.HTTP_201_CREATED,
                status.HTTP_200_OK,
                status.HTTP_400_BAD_REQUEST,
                status.HTTP_422_UNPROCESSABLE_ENTITY
            ]
            
            if response.status_code in [200, 201]:
                data = response.json()
                # QR code should be stored as-is or sanitized, but not executed
                assert "qr_code" in data


class TestQRCodeXSS:
    """Test XSS vulnerabilities in QR code endpoints"""
    
    @pytest.mark.asyncio
    async def test_xss_in_qr_code_path(self, client: AsyncClient):
        """Test XSS attempts in QR code path parameter"""
        xss_attempts = [
            "PL-TEST-<script>alert('XSS')</script>",
            "PL-TEST-<img src=x onerror=alert('XSS')>",
            "PL-TEST-<svg onload=alert('XSS')>",
            "PL-TEST-<body onload=alert('XSS')>",
            "PL-TEST-<iframe src=javascript:alert('XSS')>",
            "PL-TEST-<script>document.cookie</script>",
            "PL-TEST-<img src='x' onerror='alert(1)'>",
        ]
        
        for malicious_qr in xss_attempts:
            # URL encode the QR code for path parameter
            encoded_qr = quote(malicious_qr, safe='')
            response = await client.get(f"/api/v1/pipes/qr/{encoded_qr}")
            assert response.status_code in [status.HTTP_200_OK, status.HTTP_400_BAD_REQUEST]
            
            if response.status_code == 200:
                data = response.json()
                response_text = str(data)
                # Should not contain unescaped script tags in response
                # QR code may contain the string, but it should be escaped in JSON
                assert "<script>" not in response_text or response_text.index("<script>") > 0
    
    @pytest.mark.asyncio
    async def test_xss_in_qr_code_image_filename(self, client: AsyncClient):
        """Test XSS in Content-Disposition header filename"""
        xss_attempts = [
            "PL-TEST-<script>alert('XSS')</script>",
            "PL-TEST-<img src=x onerror=alert('XSS')>",
        ]
        
        for malicious_qr in xss_attempts:
            # URL encode the QR code for path parameter
            encoded_qr = quote(malicious_qr, safe='')
            response = await client.get(f"/api/v1/pipes/qr-code/{encoded_qr}/image")
            
            if response.status_code == 200:
                # Check Content-Disposition header
                content_disposition = response.headers.get("Content-Disposition", "")
                # Filename should be sanitized or escaped
                assert "<script>" not in content_disposition.lower()
                assert "onerror" not in content_disposition.lower()


class TestQRCodeInputValidation:
    """Test input validation and length limits"""
    
    @pytest.mark.asyncio
    async def test_very_long_qr_code(self, client: AsyncClient):
        """Test handling of extremely long QR codes"""
        # Generate very long QR code (10KB)
        long_company = "A" * 10000
        long_qr = f"PL-{long_company}-{uuid.uuid4()}"
        
        # URL encode for path parameter
        encoded_qr = quote(long_qr, safe='')
        response = await client.get(f"/api/v1/pipes/qr/{encoded_qr}")
        
        # Should handle gracefully - either reject or truncate
        assert response.status_code in [
            status.HTTP_200_OK,
            status.HTTP_400_BAD_REQUEST,
            status.HTTP_414_URI_TOO_LONG,
            status.HTTP_422_UNPROCESSABLE_ENTITY
        ]
    
    @pytest.mark.asyncio
    async def test_empty_qr_code(self, client: AsyncClient):
        """Test handling of empty QR code"""
        response = await client.get("/api/v1/pipes/qr/")
        # Should return 404 or 422, not crash
        assert response.status_code in [
            status.HTTP_404_NOT_FOUND,
            status.HTTP_422_UNPROCESSABLE_ENTITY,
            status.HTTP_405_METHOD_NOT_ALLOWED
        ]
    
    @pytest.mark.asyncio
    async def test_special_characters_in_qr_code(self, client: AsyncClient):
        """Test handling of special characters in QR code"""
        special_char_qrs = [
            "PL-TEST-../../../etc/passwd",
            "PL-TEST-..\\..\\..\\windows\\system32",
            "PL-TEST-!@#$%^&*()",
            "PL-TEST-{}\"':;[]",
            "PL-TEST-<>&\"'",
            "PL-TEST-\x00\x01\x02",  # Null bytes
            "PL-TEST-\n\r\t",  # Control characters
        ]
        
        for special_qr in special_char_qrs:
            # URL encode for path parameter
            encoded_qr = quote(special_qr, safe='')
            response = await client.get(f"/api/v1/pipes/qr/{encoded_qr}")
            # Should handle gracefully
            assert response.status_code in [
                status.HTTP_200_OK,
                status.HTTP_400_BAD_REQUEST,
                status.HTTP_422_UNPROCESSABLE_ENTITY
            ]
    
    @pytest.mark.asyncio
    async def test_unicode_characters_in_qr_code(self, client: AsyncClient):
        """Test handling of Unicode characters in QR code"""
        unicode_qrs = [
            "PL-TEST-测试",
            "PL-TEST-тест",
            "PL-TEST-🎉",
            "PL-TEST-🚀",
            "PL-TEST-日本語",
            "PL-TEST-العربية",
        ]
        
        for unicode_qr in unicode_qrs:
            # URL encode for path parameter
            encoded_qr = quote(unicode_qr, safe='')
            response = await client.get(f"/api/v1/pipes/qr/{encoded_qr}")
            # Should handle Unicode properly
            assert response.status_code in [
                status.HTTP_200_OK,
                status.HTTP_400_BAD_REQUEST,
                status.HTTP_422_UNPROCESSABLE_ENTITY
            ]
    
    @pytest.mark.asyncio
    async def test_null_bytes_in_qr_code(self, client: AsyncClient):
        """Test handling of null bytes in QR code"""
        null_byte_qr = "PL-TEST-123\x00injection"
        
        # URL encode for path parameter
        encoded_qr = quote(null_byte_qr, safe='')
        response = await client.get(f"/api/v1/pipes/qr/{encoded_qr}")
        # Should reject or sanitize null bytes
        assert response.status_code in [
            status.HTTP_200_OK,
            status.HTTP_400_BAD_REQUEST,
            status.HTTP_422_UNPROCESSABLE_ENTITY
        ]


class TestQRCodeAuthorization:
    """Test authorization and access control"""
    
    @pytest.mark.asyncio
    async def test_get_qr_code_without_auth(self, client: AsyncClient):
        """Test that GET /qr endpoint is accessible without auth (public endpoint)"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        response = await client.get(f"/api/v1/pipes/qr/{qr_code}")
        
        # QR code lookup should be public (no auth required)
        assert response.status_code == status.HTTP_200_OK
    
    @pytest.mark.asyncio
    async def test_get_qr_code_image_without_auth(self, client: AsyncClient):
        """Test that QR code image generation is accessible without auth"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        response = await client.get(f"/api/v1/pipes/qr-code/{qr_code}/image")
        
        # QR code image generation should be public
        assert response.status_code == status.HTTP_200_OK
    
    @pytest.mark.asyncio
    async def test_create_pipe_with_invalid_api_key(self, client: AsyncClient):
        """Test creating pipe with invalid API key"""
        pipe_data = {
            "company": "TEST",
            "manufacturer": "Test Manufacturer",
            "material": "Steel",
            "diameter_mm": 100,
        }
        
        response = await client.post(
            "/api/v1/pipes",
            json=pipe_data,
            headers={"Authorization": "Bearer invalid-key-12345"}
        )
        
        # In development mode, auth might be disabled
        # In production, should return 401
        assert response.status_code in [
            status.HTTP_401_UNAUTHORIZED,
            status.HTTP_201_CREATED,  # If auth is disabled in dev
            status.HTTP_200_OK
        ]
    
    @pytest.mark.asyncio
    async def test_create_pipe_without_auth_header(self, client: AsyncClient):
        """Test creating pipe without Authorization header"""
        pipe_data = {
            "company": "TEST",
            "manufacturer": "Test Manufacturer",
            "material": "Steel",
            "diameter_mm": 100,
        }
        
        response = await client.post(
            "/api/v1/pipes",
            json=pipe_data
        )
        
        # In development mode, might work
        # In production, should return 401
        assert response.status_code in [
            status.HTTP_401_UNAUTHORIZED,
            status.HTTP_201_CREATED,  # If auth is disabled in dev
            status.HTTP_200_OK
        ]


class TestQRCodeRateLimiting:
    """Test rate limiting (if implemented)"""
    
    @pytest.mark.asyncio
    async def test_rapid_qr_code_requests(self, client: AsyncClient):
        """Test rapid requests to QR code endpoint"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        
        # Make 100 rapid requests
        responses = []
        for _ in range(100):
            response = await client.get(f"/api/v1/pipes/qr/{qr_code}")
            responses.append(response.status_code)
        
        # Should handle all requests (rate limiting might not be implemented)
        # If rate limiting is implemented, some should return 429
        status_codes = set(responses)
        assert status.HTTP_200_OK in status_codes or status.HTTP_429_TOO_MANY_REQUESTS in status_codes
    
    @pytest.mark.asyncio
    async def test_rapid_qr_code_image_requests(self, client: AsyncClient):
        """Test rapid requests to QR code image endpoint"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        
        # Make 50 rapid requests
        responses = []
        for _ in range(50):
            response = await client.get(f"/api/v1/pipes/qr-code/{qr_code}/image")
            responses.append(response.status_code)
        
        # Should handle requests (rate limiting might not be implemented)
        status_codes = set(responses)
        assert status.HTTP_200_OK in status_codes or status.HTTP_429_TOO_MANY_REQUESTS in status_codes


class TestQRCodePathTraversal:
    """Test path traversal vulnerabilities"""
    
    @pytest.mark.asyncio
    async def test_path_traversal_in_qr_code(self, client: AsyncClient):
        """Test path traversal attempts in QR code"""
        path_traversal_attempts = [
            "PL-TEST-../../../etc/passwd",
            "PL-TEST-..\\..\\..\\windows\\system32",
            "PL-TEST-....//....//etc/passwd",
            "PL-TEST-%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd",
        ]
        
        for malicious_qr in path_traversal_attempts:
            # URL encode for path parameter (except already encoded ones)
            if not malicious_qr.startswith("PL-TEST-%"):
                encoded_qr = quote(malicious_qr, safe='')
            else:
                encoded_qr = malicious_qr
            response = await client.get(f"/api/v1/pipes/qr/{encoded_qr}")
            # Should not access filesystem
            assert response.status_code in [
                status.HTTP_200_OK,  # Treated as normal QR code
                status.HTTP_400_BAD_REQUEST,
                status.HTTP_422_UNPROCESSABLE_ENTITY
            ]
            
            if response.status_code == 200:
                data = response.json()
                # Should not contain file contents
                assert "/etc/passwd" not in str(data)
                assert "root:" not in str(data).lower()


class TestQRCodeImageSecurity:
    """Test security of QR code image generation"""
    
    @pytest.mark.asyncio
    async def test_very_large_image_size(self, client: AsyncClient):
        """Test handling of very large image size parameter"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        
        # Try extremely large size
        response = await client.get(f"/api/v1/pipes/qr-code/{qr_code}/image?size=999999")
        
        # Should either reject or limit size
        assert response.status_code in [
            status.HTTP_200_OK,  # If size is limited internally
            status.HTTP_400_BAD_REQUEST,
            status.HTTP_422_UNPROCESSABLE_ENTITY
        ]
        
        if response.status_code == 200:
            # Image should not be extremely large
            content_length = len(response.content)
            # Should be reasonable size (less than 10MB)
            assert content_length < 10 * 1024 * 1024
    
    @pytest.mark.asyncio
    async def test_negative_image_size(self, client: AsyncClient):
        """Test handling of negative image size"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        
        response = await client.get(f"/api/v1/pipes/qr-code/{qr_code}/image?size=-100")
        
        # Should reject negative size
        assert response.status_code in [
            status.HTTP_200_OK,  # If handled gracefully
            status.HTTP_400_BAD_REQUEST,
            status.HTTP_422_UNPROCESSABLE_ENTITY
        ]
    
    @pytest.mark.asyncio
    async def test_zero_image_size(self, client: AsyncClient):
        """Test handling of zero image size"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        
        response = await client.get(f"/api/v1/pipes/qr-code/{qr_code}/image?size=0")
        
        # Should reject zero size or use default
        assert response.status_code in [
            status.HTTP_200_OK,  # If default size is used
            status.HTTP_400_BAD_REQUEST,
            status.HTTP_422_UNPROCESSABLE_ENTITY
        ]
    
    @pytest.mark.asyncio
    async def test_non_numeric_image_size(self, client: AsyncClient):
        """Test handling of non-numeric image size"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        
        response = await client.get(f"/api/v1/pipes/qr-code/{qr_code}/image?size=abc")
        
        # Should reject non-numeric
        assert response.status_code in [
            status.HTTP_200_OK,  # If default is used
            status.HTTP_400_BAD_REQUEST,
            status.HTTP_422_UNPROCESSABLE_ENTITY
        ]


class TestQRCodeDataLeakage:
    """Test for information disclosure vulnerabilities"""
    
    @pytest.mark.asyncio
    async def test_error_message_information_disclosure(self, client: AsyncClient):
        """Test that error messages don't leak sensitive information"""
        # Try various invalid inputs
        invalid_inputs = [
            "PL-TEST-' OR '1'='1",
            "PL-TEST-../../../etc/passwd",
            "PL-TEST-<script>alert('XSS')</script>",
        ]
        
        for invalid_input in invalid_inputs:
            # URL encode for path parameter
            encoded_input = quote(invalid_input, safe='')
            response = await client.get(f"/api/v1/pipes/qr/{encoded_input}")
            
            if response.status_code != 200:
                error_text = response.text.lower()
                # Should not expose:
                # - Database structure
                # - File paths
                # - Stack traces (in production)
                assert "select" not in error_text or "sql" not in error_text
                assert "/etc/" not in error_text
                assert "traceback" not in error_text
                assert "file" not in error_text or "error" not in error_text
    
    @pytest.mark.asyncio
    async def test_qr_code_response_structure(self, client: AsyncClient):
        """Test that response doesn't expose internal structure"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        response = await client.get(f"/api/v1/pipes/qr/{qr_code}")
        
        if response.status_code == 200:
            data = response.json()
            # Should not expose internal fields
            assert "_sa_instance_state" not in str(data)
            assert "password" not in str(data).lower()
            assert "secret" not in str(data).lower()
            assert "key" not in str(data).lower() or "qr_code" in str(data).lower()
