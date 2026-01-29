# Deployment Guide

## Production Deployment

### Prerequisites

- Docker 20.10+ and Docker Compose 2.0+
- 4GB+ RAM available
- 10GB+ disk space
- Network access for pulling images

### Quick Deployment

```bash
# 1. Clone repository
git clone https://github.com/qrlbk/Tutas-AI.git
cd Tutas-AI

# 2. Configure environment
cp .env.example .env
# Edit .env with production values

# 3. Deploy
make init
```

### Step-by-Step Deployment

#### 1. Environment Configuration

```bash
cp .env.example .env
```

**Critical variables to update:**

```bash
# Security
POSTGRES_PASSWORD=<strong_password>
MINIO_ROOT_PASSWORD=<strong_password>
MINIO_ROOT_USER=<admin_username>

# Domain (if using Traefik)
DOMAIN=your-domain.com

# API Keys (if applicable)
AI_ENGINE_API_KEY=<optional>
```

#### 2. Build and Start

```bash
# Build all images
make build

# Start services
make up

# Wait for services to initialize
sleep 30

# Seed database (REQUIRED for demo)
make seed
```

#### 3. Verify Deployment

```bash
# Check service status
make status

# Check health
make health

# View logs
make logs
```

### Production Considerations

#### Security

1. **Change default passwords** in `.env`
2. **Enable SSL/TLS** via Traefik
3. **Restrict database access** (firewall rules)
4. **Use secrets management** (Docker secrets, Vault, etc.)
5. **Enable authentication** for MinIO console

#### Performance

1. **Resource limits**: Update `docker-compose.yaml` with appropriate limits
2. **Database tuning**: Configure PostgreSQL for your workload
3. **Caching**: Ensure Redis is properly configured
4. **CDN**: Consider CDN for frontend static assets

#### Monitoring

1. **Health checks**: Use `make health` or integrate monitoring tools
2. **Log aggregation**: Configure log forwarding (ELK, Loki, etc.)
3. **Metrics**: Add Prometheus/Grafana for metrics collection

### Scaling

#### Horizontal Scaling

```bash
# Scale backend services
docker-compose up -d --scale backend=3

# Scale frontend (behind load balancer)
docker-compose up -d --scale frontend=2
```

#### Database Scaling

- Use PostgreSQL read replicas for read-heavy workloads
- Consider TimescaleDB multi-node for large datasets

### Backup and Recovery

#### Database Backup

```bash
# Create backup
docker-compose exec db pg_dump -U postgres tutas_ai > backup_$(date +%Y%m%d).sql

# Restore backup
docker-compose exec -T db psql -U postgres tutas_ai < backup_20240116.sql
```

#### Automated Backups

Set up cron job or scheduled task:

```bash
# Daily backup script
0 2 * * * cd /path/to/tutas-ai && docker-compose exec -T db pg_dump -U postgres tutas_ai > /backups/tutas_ai_$(date +\%Y\%m\%d).sql
```

### Troubleshooting

#### Service Won't Start

```bash
# Check logs
make logs

# Check specific service
make logs-backend
make logs-db

# Restart service
docker-compose restart <service_name>
```

#### Database Issues

```bash
# Check database status
make shell-db

# Verify connections
docker-compose exec db pg_isready -U postgres

# Reset database (WARNING: deletes all data)
docker-compose down -v
make up
make seed
```

#### Port Conflicts

Update ports in `.env`:

```bash
BACKEND_PORT=8001
FRONTEND_PORT=3001
DB_PORT=5433
```

### Rollback

```bash
# Stop services
make down

# Checkout previous version
git checkout <previous_tag>

# Rebuild and restart
make rebuild
make up
```

### Maintenance

#### Regular Updates

```bash
# Pull latest code
git pull

# Rebuild images
make rebuild

# Restart services
make restart
```

#### Database Maintenance

```bash
# Vacuum database
make shell-db
VACUUM ANALYZE;

# Check database size
SELECT pg_size_pretty(pg_database_size('tutas_ai'));
```

## Development Deployment

For development environments:

```bash
# Use development overrides
docker-compose -f docker-compose.yaml -f docker-compose.dev.yaml up -d
```

## Docker Swarm Deployment

For production clusters:

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yaml tutas-ai
```

## Kubernetes Deployment

Kubernetes manifests available in `k8s/` directory (if provided).

```bash
kubectl apply -f k8s/
```

---

For additional support, see [README.md](README.md) or open an issue on GitHub.
