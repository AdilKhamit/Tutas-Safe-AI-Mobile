# Tutas AI Frontend

React-based web portal for pipeline monitoring and management.

[![React](https://img.shields.io/badge/React-18-blue.svg)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)](https://www.typescriptlang.org/)
[![Vite](https://img.shields.io/badge/Vite-5.0-purple.svg)](https://vitejs.dev/)

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Setup](#setup)
- [Development](#development)
- [Build](#build)
- [Deployment](#deployment)

---

## Features

- ✅ **Interactive Dashboard** - Real-time monitoring with statistics
- ✅ **Map View** - Interactive maps showing pipeline locations
- ✅ **Defect Trends** - Charts showing defect trends over time
- ✅ **Responsive Design** - Works on desktop and mobile
- ✅ **Dark Theme** - Modern dark UI design
- ✅ **Real-time Updates** - Live data updates from API

---

## Tech Stack

- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Ant Design** - UI component library
- **Redux Toolkit** - State management
- **RTK Query** - Data fetching and caching
- **React Router** - Routing
- **React Leaflet** - Interactive maps
- **Recharts** - Charts and graphs

---

## Project Structure

```
src/
├── components/          # Reusable components
│   ├── Dashboard/
│   ├── MapView/
│   ├── Statistics/
│   └── Charts/
├── pages/              # Page components
│   ├── DashboardPage.tsx
│   └── AdminPanel.tsx
├── store/              # Redux store
│   ├── api/           # RTK Query API slices
│   └── slices/        # Redux slices
├── types/             # TypeScript types
│   └── index.ts
├── utils/             # Utility functions
│   └── api.ts
├── App.tsx            # Root component
├── main.tsx           # Entry point
└── index.css          # Global styles
```

---

## Setup

### Prerequisites

- Node.js 18+ and npm/yarn
- Backend API running (see [backend/README.md](../backend/README.md))

### Installation

```bash
# Install dependencies
npm install

# Or using yarn
yarn install
```

### Environment Variables

Create `.env` file:

```bash
VITE_API_BASE_URL=http://localhost:8000
VITE_API_KEY=dev-api-key-12345  # Optional for development
```

### Running

```bash
# Development server
npm run dev

# Or using yarn
yarn dev
```

The app will be available at `http://localhost:3000`

---

## Development

### Available Scripts

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint

# Type check
npm run type-check
```

### Code Style

We use:
- **ESLint** for linting
- **Prettier** for code formatting
- **TypeScript** for type checking

```bash
# Format code
npm run format

# Lint code
npm run lint

# Fix linting issues
npm run lint:fix
```

### API Integration

The frontend communicates with backend API through:

- **Development**: Vite proxy (`/api` → `http://localhost:8000`)
- **Production**: Nginx proxy (`/api` → `http://backend:8000`)

### State Management

We use Redux Toolkit with RTK Query:

```typescript
// Example: Fetching pipes
const { data, isLoading, error } = useGetPipesQuery();

// Example: Creating pipe
const [createPipe] = useCreatePipeMutation();
await createPipe(newPipe);
```

---

## Build

### Production Build

```bash
# Build for production
npm run build

# Output will be in dist/ directory
```

### Docker Build

```bash
# Build Docker image
docker build -t tutas-ai-frontend .

# Run container
docker run -p 80:80 tutas-ai-frontend
```

---

## Deployment

### Static Hosting

The frontend is a static application and can be deployed to:

- **Nginx** - Traditional web server
- **Vercel** - Serverless deployment
- **Netlify** - Static site hosting
- **AWS S3 + CloudFront** - Scalable hosting
- **GitHub Pages** - Free hosting for public repos

### Nginx Configuration

Example nginx configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Environment Configuration

For production, update environment variables:

```bash
VITE_API_BASE_URL=https://api.your-domain.com
```

Rebuild the application after changing environment variables.

---

## Features Overview

### Dashboard

- Real-time statistics cards
- Recent inspections list
- Critical pipes alert
- Quick actions

### Map View

- Interactive map with Leaflet
- Pipe locations marked
- Click to view details
- Filter by status

### Statistics

- Defect trends over time
- Inspection completion rates
- Pipe status distribution
- Material breakdown

### Admin Panel

- User management
- Pipe management
- System settings
- Data export

---

## Troubleshooting

### API Connection Issues

**Problem:** Cannot connect to backend API

**Solutions:**
1. Verify backend is running: `make up` or `docker-compose up`
2. Check `VITE_API_BASE_URL` in `.env`
3. Check CORS settings in backend
4. Verify network connectivity

### Build Issues

**Problem:** Build fails

**Solutions:**
1. Clear node_modules and reinstall: `rm -rf node_modules && npm install`
2. Clear Vite cache: `rm -rf node_modules/.vite`
3. Check TypeScript errors: `npm run type-check`
4. Verify Node.js version: `node --version` (should be 18+)

### Runtime Errors

**Problem:** App crashes or shows errors

**Solutions:**
1. Check browser console for errors
2. Verify API endpoints are correct
3. Check network tab for failed requests
4. Review Redux DevTools for state issues

---

## Additional Resources

- [React Documentation](https://react.dev/)
- [TypeScript Documentation](https://www.typescriptlang.org/)
- [Vite Documentation](https://vitejs.dev/)
- [Ant Design Documentation](https://ant.design/)
- [Redux Toolkit Documentation](https://redux-toolkit.js.org/)

---

## Support

For issues and questions:
- Check [Troubleshooting](#troubleshooting) section
- Review backend API documentation
- Contact project maintainers

---

## License

Proprietary Software. Developed for Tutas Safe AI.
