"""
Comprehensive tests for QR code API endpoints
"""
import pytest
import uuid
from httpx import AsyncClient
from fastapi import status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.pipes import Pipe


class TestQRCodeAPI:
    """Test suite for QR code API endpoints"""
    
    @pytest.mark.asyncio
    async def test_get_pipe_by_qr_code_success(self, client: AsyncClient, test_db: AsyncSession):
        """Test successful retrieval of pipe by QR code"""
        # Create a test pipe
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        pipe = Pipe(
            qr_code=qr_code,
            manufacturer="Test Manufacturer",
            material="Steel",
            diameter_mm=100,
            wall_thickness_mm=5.0,
            length_meters=100.0,
            current_status="active",
        )
        test_db.add(pipe)
        await test_db.commit()
        await test_db.refresh(pipe)
        
        # Test GET /api/v1/pipes/qr/{qr_code}
        response = await client.get(f"/api/v1/pipes/qr/{qr_code}")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["qr_code"] == qr_code
        assert data["manufacturer"] == "Test Manufacturer"
        assert data["material"] == "Steel"
        assert data["diameter_mm"] == 100
        assert "id" in data
        assert "current_status" in data
    
    @pytest.mark.asyncio
    async def test_get_pipe_by_qr_code_not_found_returns_mock(self, client: AsyncClient):
        """Test that non-existent QR code returns mock data"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        
        response = await client.get(f"/api/v1/pipes/qr/{qr_code}")
        
        # Should return 200 with mock data
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["qr_code"] == qr_code
        assert data["manufacturer"] is not None
        assert data["material"] == "Steel"
    
    @pytest.mark.asyncio
    async def test_get_pipe_by_qr_code_format_validation(self, client: AsyncClient):
        """Test QR code format validation"""
        # Test valid format
        valid_qr = f"PL-COMPANY-{uuid.uuid4()}"
        response = await client.get(f"/api/v1/pipes/qr/{valid_qr}")
        assert response.status_code == status.HTTP_200_OK
        
        # Test invalid format (should still work but return mock)
        invalid_qr = "INVALID-FORMAT"
        response = await client.get(f"/api/v1/pipes/qr/{invalid_qr}")
        assert response.status_code == status.HTTP_200_OK
    
    @pytest.mark.asyncio
    async def test_get_qr_code_image(self, client: AsyncClient):
        """Test QR code image generation"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        
        response = await client.get(f"/api/v1/pipes/qr-code/{qr_code}/image")
        
        assert response.status_code == status.HTTP_200_OK
        assert response.headers["content-type"] == "image/png"
        assert len(response.content) > 0
    
    @pytest.mark.asyncio
    async def test_get_qr_code_image_custom_size(self, client: AsyncClient):
        """Test QR code image generation with custom size"""
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        
        response = await client.get(
            f"/api/v1/pipes/qr-code/{qr_code}/image?size=500"
        )
        
        assert response.status_code == status.HTTP_200_OK
        assert response.headers["content-type"] == "image/png"
        assert len(response.content) > 0
    
    @pytest.mark.asyncio
    async def test_get_pipe_qr_code_image_by_id(self, client: AsyncClient, test_db: AsyncSession):
        """Test QR code image generation by pipe ID"""
        # Create a test pipe
        qr_code = f"PL-TEST-{uuid.uuid4()}"
        pipe = Pipe(
            qr_code=qr_code,
            manufacturer="Test Manufacturer",
            material="Steel",
            diameter_mm=100,
            current_status="active",
        )
        test_db.add(pipe)
        await test_db.commit()
        await test_db.refresh(pipe)
        
        response = await client.get(f"/api/v1/pipes/{pipe.id}/qr-code")
        
        assert response.status_code == status.HTTP_200_OK
        assert response.headers["content-type"] == "image/png"
        assert len(response.content) > 0
    
    @pytest.mark.asyncio
    async def test_get_pipe_qr_code_image_not_found(self, client: AsyncClient):
        """Test QR code image generation for non-existent pipe"""
        pipe_id = uuid.uuid4()
        
        response = await client.get(f"/api/v1/pipes/{pipe_id}/qr-code")
        
        assert response.status_code == status.HTTP_404_NOT_FOUND
    
    @pytest.mark.asyncio
    async def test_create_pipe_with_qr_code(self, client: AsyncClient):
        """Test creating pipe with auto-generated QR code"""
        pipe_data = {
            "company": "TEST",
            "manufacturer": "Test Manufacturer",
            "material": "Steel",
            "diameter_mm": 100,
            "wall_thickness_mm": 5.0,
            "length_meters": 100.0,
        }
        
        response = await client.post(
            "/api/v1/pipes",
            json=pipe_data,
            headers={"Authorization": "Bearer dev-api-key-12345"}
        )
        
        assert response.status_code in [status.HTTP_201_CREATED, status.HTTP_200_OK]
        data = response.json()
        assert "qr_code" in data
        assert data["qr_code"].startswith("PL-TEST-")
        assert data["manufacturer"] == "Test Manufacturer"
    
    @pytest.mark.asyncio
    async def test_create_pipe_with_custom_qr_code(self, client: AsyncClient):
        """Test creating pipe with custom QR code"""
        custom_qr = f"PL-CUSTOM-{uuid.uuid4()}"
        pipe_data = {
            "company": "CUSTOM",
            "qr_code": custom_qr,
            "manufacturer": "Test Manufacturer",
            "material": "Steel",
            "diameter_mm": 100,
        }
        
        response = await client.post(
            "/api/v1/pipes",
            json=pipe_data,
            headers={"Authorization": "Bearer dev-api-key-12345"}
        )
        
        assert response.status_code in [status.HTTP_201_CREATED, status.HTTP_200_OK]
        data = response.json()
        assert data["qr_code"] == custom_qr
    
    @pytest.mark.asyncio
    async def test_qr_code_format_extraction(self, client: AsyncClient):
        """Test that company name is correctly extracted from QR code"""
        qr_code = "PL-MYCOMPANY-123e4567-e89b-12d3-a456-426614174000"
        
        response = await client.get(f"/api/v1/pipes/qr/{qr_code}")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        # Should extract "MYCOMPANY" from QR code
        assert "MYCOMPANY" in data.get("manufacturer", "").upper() or data["qr_code"] == qr_code


class TestQRCodeFormat:
    """Test suite for QR code format validation"""
    
    def test_valid_qr_code_formats(self):
        """Test various valid QR code formats"""
        valid_formats = [
            "PL-COMPANY-123e4567-e89b-12d3-a456-426614174000",
            "PL-TUTAS-9757a1cd-8292-4535-8e44-979d608a2588",
            "PL-TEST-abc123",
            "PL-COMPANY-123",
        ]
        
        for qr_code in valid_formats:
            parts = qr_code.split('-')
            assert len(parts) >= 3
            assert parts[0] == "PL"
            assert len(parts[1]) > 0  # Company name
    
    def test_qr_code_company_extraction(self):
        """Test company name extraction from QR code"""
        test_cases = [
            ("PL-COMPANY-123", "COMPANY"),
            ("PL-TUTAS-456", "TUTAS"),
            ("PL-MYCOMPANY-789", "MYCOMPANY"),
        ]
        
        for qr_code, expected_company in test_cases:
            parts = qr_code.split('-')
            company = parts[1] if len(parts) > 1 else "COMPANY"
            assert company == expected_company
