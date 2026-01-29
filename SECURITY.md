# 🔒 Security Guidelines

## ⚠️ Important Security Notes

This document outlines security best practices for the Tutas Ai platform.

## Environment Variables

**NEVER commit `.env` files to version control!**

All sensitive configuration should be stored in environment variables:

### Required Environment Variables

#### Backend (.env)
```bash
# Database
POSTGRES_PASSWORD=<strong_password>
DATABASE_URL=postgresql+asyncpg://postgres:<password>@localhost:5432/tutas_ai

# Redis
REDIS_PASSWORD=<strong_password>

# MinIO
MINIO_ROOT_PASSWORD=<strong_password>

# Security (CRITICAL - Change in production!)
SECRET_KEY=<generate-strong-random-key>
JWT_SECRET_KEY=<generate-strong-random-key>
API_KEYS=<comma-separated-list-of-api-keys>

# Environment
ENVIRONMENT=production  # or development
```

#### Mobile App (mobile/.env)
```bash
API_BASE_URL=http://your-server-ip:8000
API_KEY=<your-api-key>
```

#### Frontend (.env)
```bash
VITE_API_KEY=<your-api-key>
```

## Generating Secure Keys

### Generate SECRET_KEY and JWT_SECRET_KEY:
```bash
# Python
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# OpenSSL
openssl rand -hex 32
```

### Generate API Keys:
```bash
# Generate multiple API keys
for i in {1..3}; do echo "API_KEY_$i=$(openssl rand -hex 16)"; done
```

## Default Credentials

**⚠️ WARNING:** The following default credentials are for **development only**:

- Database: `postgres/postgres`
- MinIO: `minioadmin/minioadmin`
- API Key: `dev-api-key-12345`

**These MUST be changed in production!**

## Production Checklist

Before deploying to production:

- [ ] Change all default passwords
- [ ] Generate strong SECRET_KEY and JWT_SECRET_KEY
- [ ] Set up proper API_KEYS
- [ ] Enable HTTPS/TLS
- [ ] Configure firewall rules
- [ ] Set ENVIRONMENT=production
- [ ] Review and restrict CORS origins
- [ ] Enable database encryption
- [ ] Set up proper backup strategy
- [ ] Configure rate limiting
- [ ] Enable API authentication in production mode

## API Authentication

The API supports Bearer token authentication:

```bash
curl -H "Authorization: Bearer <api_key>" http://localhost:8000/api/v1/pipes
```

In development mode, authentication is optional. In production, it's required.

## Database Security

- Use strong passwords for PostgreSQL
- Enable SSL/TLS connections in production
- Restrict database access to backend only
- Regular backups with encryption

## Secrets Management

For production, consider using:
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault
- Kubernetes Secrets

## Reporting Security Issues

If you discover a security vulnerability, please report it responsibly:
- Do NOT create a public issue
- Contact the maintainers directly
- Allow time for the issue to be fixed before disclosure
