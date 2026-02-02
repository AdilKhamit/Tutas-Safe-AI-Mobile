"""
Pydantic schemas for authentication
"""
from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional
import uuid


class UserBase(BaseModel):
    """Base schema for User"""
    email: EmailStr
    full_name: Optional[str] = None


class UserCreate(UserBase):
    """Schema for creating a new user"""
    password: str


class UserResponse(UserBase):
    """Response schema for User"""
    id: uuid.UUID
    is_active: bool
    is_superuser: bool

    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    """Token response schema"""
    access_token: str
    refresh_token: Optional[str] = None
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Token data schema"""
    user_id: Optional[uuid.UUID] = None
    email: Optional[str] = None


class LoginRequest(BaseModel):
    """Login request schema"""
    email: EmailStr
    password: str


class RefreshTokenRequest(BaseModel):
    """Refresh token request schema"""
    refresh_token: str
