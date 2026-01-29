# Tutas Ai Frontend

React-based web portal for pipeline monitoring and management.

## Tech Stack

- **React 18** + **TypeScript**
- **Vite** - Build tool
- **Ant Design** - UI Component Library
- **Redux Toolkit** + **RTK Query** - State Management
- **React Router** - Routing
- **React Leaflet** - Maps
- **Recharts** - Charts and Graphs

## Features

- **Dashboard**: Real-time monitoring with statistics cards
- **Map View**: Interactive map showing pipeline locations
- **Defect Trends**: Charts showing defect trends over time
- **Responsive Design**: Works on desktop and mobile

## Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Docker

```bash
# Build
docker build -t tutas-ai-frontend .

# Run
docker run -p 80:80 tutas-ai-frontend
```

## API Integration

Frontend communicates with backend API through:
- Development: Vite proxy (`/api` → `http://localhost:8000`)
- Production: Nginx proxy (`/api` → `http://backend:8000`)

## Structure

```
src/
├── components/     # Reusable components
├── pages/          # Page components
├── store/          # Redux store and API
├── types/          # TypeScript types
└── utils/          # Utility functions
```
