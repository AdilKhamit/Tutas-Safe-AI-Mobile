# Security Guidelines

Comprehensive security best practices and guidelines for the Tutas AI Platform.

---

## Table of Contents

- [Overview](#overview)
- [Environment Variables](#environment-variables)
- [Authentication](#authentication)
- [Database Security](#database-security)
- [API Security](#api-security)
- [Network Security](#network-security)
- [Secrets Management](#secrets-management)
- [Production Checklist](#production-checklist)
- [Reporting Security Issues](#reporting-security-issues)

---

## Overview

This document outlines security best practices for the Tutas AI Platform. **All developers and administrators must follow these guidelines**, especially when deploying to production environments.

**⚠️ CRITICAL:** Default credentials are for **development only** and **MUST be changed** before production deployment.

---

## Environment Variables

### Never Commit Secrets

**NEVER commit `.env` files to version control!**

All sensitive configuration must be stored in environment variables and excluded from version control via `.gitignore`.

### Required Environment Variables

#### Backend

```bash
# Database
POSTGRES_PASSWORD=<strong_password>
DATABASE_URL=postgresql+asyncpg://postgres:<password>@localhost:5432/tutas_ai

# Redis
REDIS_URL=redis://localhost:6379
REDIS_PASSWORD=<strong_password>

# MinIO
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=<strong_key>
MINIO_SECRET_KEY=<strong_secret>
MINIO_ROOT_PASSWORD=<strong_password>

# Security (CRITICAL - Change in production!)
SECRET_KEY=<generate-strong-random-key>
JWT_SECRET_KEY=<generate-strong-random-key>
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
API_KEYS=<comma-separated-list-of-api-keys>

# Environment
ENVIRONMENT=production  # or development
```

#### Mobile App

```bash
API_BASE_URL=https://api.your-domain.com
API_KEY=<your-api-key>  # Optional for development
```

#### Frontend

```bash
VITE_API_BASE_URL=https://api.your-domain.com
VITE_API_KEY=<your-api-key>  # Optional for development
```

### Generating Secure Keys

#### SECRET_KEY and JWT_SECRET_KEY

**Python:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

**OpenSSL:**
```bash
openssl rand -hex 32
```

**Recommended length:** 32+ characters

#### API Keys

```bash
# Generate multiple API keys
for i in {1..3}; do echo "API_KEY_$i=$(openssl rand -hex 16)"; done
```

---

## Authentication

### JWT Tokens

The platform uses JWT (JSON Web Tokens) for authentication:

- **Access Token**: Short-lived (30 minutes default)
- **Refresh Token**: Long-lived (7 days default)
- **Algorithm**: HS256
- **Storage**: Secure storage (mobile), HTTP-only cookies (web)

### Password Security

- **Hashing**: Passwords are hashed using bcrypt
- **Minimum Length**: 8 characters (enforced)
- **Complexity**: Recommended but not enforced
- **Storage**: Never stored in plain text

### Token Security

- Tokens are signed with `JWT_SECRET_KEY`
- Tokens include expiration time
- Refresh tokens are rotated on use
- Tokens are invalidated on logout

### Best Practices

- Use HTTPS/TLS for all authentication endpoints
- Implement rate limiting on auth endpoints
- Log authentication failures
- Implement account lockout after failed attempts
- Use secure token storage

---

## Database Security

### PostgreSQL Security

- **Strong Passwords**: Use complex passwords (16+ characters)
- **SSL/TLS**: Enable SSL connections in production
- **Access Control**: Restrict database access to backend only
- **Network Isolation**: Database should not be publicly accessible
- **Regular Updates**: Keep PostgreSQL updated

### Connection Security

```python
# Production database URL should use SSL
DATABASE_URL=postgresql+asyncpg://user:password@host:5432/db?ssl=require
```

### Backup Security

- **Encryption**: Encrypt database backups
- **Access Control**: Restrict backup access
- **Retention**: Follow retention policies
- **Testing**: Regularly test backup restoration

### Data Protection

- **Encryption at Rest**: Enable database encryption
- **PII Handling**: Handle personally identifiable information carefully
- **Data Retention**: Follow data retention policies
- **Access Logging**: Log database access

---

## API Security

### CORS Configuration

**Development:**
```python
allow_origins=["*"]  # For development only
```

**Production:**
```python
allow_origins=[
    "https://your-domain.com",
    "https://www.your-domain.com"
]
```

### Rate Limiting

Implement rate limiting to prevent abuse:

- **Authentication Endpoints**: 5 requests per minute per IP
- **API Endpoints**: 100 requests per minute per user
- **File Upload**: 10 requests per minute per user

### Input Validation

- Validate all input using Pydantic schemas
- Sanitize user input
- Use parameterized queries (SQLAlchemy handles this)
- Validate file uploads (type, size, content)

### API Authentication

**Development Mode:**
- API key authentication is optional
- JWT authentication available

**Production Mode:**
- API key or JWT authentication required
- All endpoints protected
- Rate limiting enforced

### Error Handling

- Don't expose sensitive information in error messages
- Log errors securely
- Return generic error messages to clients
- Include error IDs for support tracking

---

## Network Security

### HTTPS/TLS

- **Required in Production**: All traffic must use HTTPS
- **Certificate Management**: Use Let's Encrypt or commercial certificates
- **TLS Version**: Use TLS 1.2 or higher
- **Cipher Suites**: Use strong cipher suites only

### Firewall Configuration

- **Database**: Only accessible from backend
- **Backend API**: Accessible from frontend and mobile
- **MinIO**: Only accessible from backend
- **Redis**: Only accessible from backend

### Network Isolation

- Use Docker networks for service isolation
- Implement network policies
- Use VPN for administrative access
- Monitor network traffic

---

## Secrets Management

### Development

- Use `.env` files (not committed to git)
- Use strong default values
- Rotate secrets regularly

### Production

Use proper secrets management:

- **HashiCorp Vault**: Enterprise secrets management
- **AWS Secrets Manager**: For AWS deployments
- **Azure Key Vault**: For Azure deployments
- **Kubernetes Secrets**: For Kubernetes deployments
- **Docker Secrets**: For Docker Swarm

### Key Rotation

- Rotate secrets regularly (quarterly recommended)
- Rotate immediately if compromised
- Document rotation procedures
- Test rotation in staging first

---

## Production Checklist

Before deploying to production, ensure:

### Critical Security Items

- [ ] All default passwords changed
- [ ] Strong SECRET_KEY and JWT_SECRET_KEY generated
- [ ] API_KEYS configured and secured
- [ ] HTTPS/TLS enabled
- [ ] CORS origins restricted
- [ ] Database SSL/TLS enabled
- [ ] Rate limiting configured
- [ ] API authentication required
- [ ] Firewall rules configured
- [ ] Secrets management implemented
- [ ] Backup strategy configured
- [ ] Monitoring and logging enabled
- [ ] Security headers configured
- [ ] Regular security updates scheduled

### Additional Security Measures

- [ ] Security audit performed
- [ ] Penetration testing completed
- [ ] Incident response plan documented
- [ ] Security training completed
- [ ] Access control reviewed
- [ ] Logging and monitoring configured
- [ ] Disaster recovery plan in place

---

## Default Credentials

**⚠️ WARNING:** The following default credentials are for **development only**:

| Service | Username | Password | Status |
|---------|----------|----------|--------|
| Database | `postgres` | `postgres` | ⚠️ Change in production |
| MinIO | `minioadmin` | `minioadmin` | ⚠️ Change in production |
| API Key | `dev-api-key-12345` | N/A | ⚠️ Change in production |

**These MUST be changed before production deployment!**

---

## Security Headers

Configure security headers in production:

- **X-Content-Type-Options**: `nosniff`
- **X-Frame-Options**: `DENY`
- **X-XSS-Protection**: `1; mode=block`
- **Strict-Transport-Security**: `max-age=31536000; includeSubDomains`
- **Content-Security-Policy**: Configure appropriately

---

## Monitoring and Logging

### Security Monitoring

- Monitor authentication failures
- Track API usage patterns
- Monitor database access
- Alert on suspicious activity

### Logging

- Log all authentication attempts
- Log API access
- Log administrative actions
- Log security events
- **Never log passwords or tokens**

---

## Reporting Security Issues

If you discover a security vulnerability:

1. **Do NOT** create a public issue
2. **Do NOT** disclose the vulnerability publicly
3. Contact maintainers directly via secure channel
4. Provide detailed information about the vulnerability
5. Allow time for the issue to be fixed before disclosure
6. Follow responsible disclosure practices

### Contact Information

For security issues, contact the project maintainers directly.

---

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP API Security](https://owasp.org/www-project-api-security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CWE Top 25](https://cwe.mitre.org/top25/)

---

## Security Updates

This document is reviewed and updated regularly. Last updated: 2025-01-19

For questions or clarifications, contact the security team.

---

**Remember:** Security is everyone's responsibility. When in doubt, ask!
