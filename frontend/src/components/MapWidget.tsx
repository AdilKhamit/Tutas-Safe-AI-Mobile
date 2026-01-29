import React, { useMemo } from 'react';
import { MapContainer, TileLayer, Marker, Popup, Polyline, CircleMarker } from 'react-leaflet';
import { LatLngExpression } from 'leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import { useGetAllPipesQuery } from '../store/api/tutasApi';

// Fix for default marker icons in React-Leaflet
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

interface MapWidgetProps {
  pipes?: Array<{
    id: string;
    qr_code: string;
    location?: { lat: number; lon: number };
    risk_score?: number;
  }>;
}

const defaultCenter: LatLngExpression = [51.1694, 71.4491]; // Astana, Kazakhstan

// Dark theme tile layer
const darkTileLayer = 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

// Function to get color based on risk score
const getRiskColor = (riskScore: number | undefined): string => {
  if (!riskScore) return '#52c41a'; // Green for no data
  if (riskScore >= 0.7) return '#ff4d4f'; // Red - Critical
  if (riskScore >= 0.4) return '#faad14'; // Orange - Warning
  return '#52c41a'; // Green - Low risk
};

// Function to generate heatmap path between pipes
const generateHeatmapPath = (pipes: Array<{ location?: { lat: number; lon: number }; risk_score?: number }>): LatLngExpression[][] => {
  const paths: LatLngExpression[][] = [];
  const sortedPipes = [...pipes]
    .filter((p) => p.location && p.location.lat && p.location.lon)
    .sort((a, b) => (a.location!.lat + a.location!.lon) - (b.location!.lat + b.location!.lon));

  for (let i = 0; i < sortedPipes.length - 1; i++) {
    const current = sortedPipes[i];
    const next = sortedPipes[i + 1];
    
    if (current.location && next.location) {
      paths.push([
        [current.location.lat, current.location.lon],
        [next.location.lat, next.location.lon],
      ]);
    }
  }

  return paths;
};

export const MapWidget: React.FC<MapWidgetProps> = ({ pipes: propPipes }) => {
  // Get pipes from API if not provided via props
  const { data: apiPipes, isLoading } = useGetAllPipesQuery(undefined, {
    skip: propPipes !== undefined && propPipes.length > 0,
  });
  
  // Use prop pipes if provided, otherwise use API data
  const displayPipes = propPipes && propPipes.length > 0 
    ? propPipes 
    : (apiPipes || []);

  // Generate heatmap paths
  const heatmapPaths = useMemo(() => generateHeatmapPath(displayPipes), [displayPipes]);

  return (
    <MapContainer
      center={defaultCenter}
      zoom={13}
      style={{ height: '100%', width: '100%' }}
    >
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
        url={darkTileLayer}
      />
      {isLoading && (
        <div style={{ 
          position: 'absolute', 
          top: '50%', 
          left: '50%', 
          transform: 'translate(-50%, -50%)',
          zIndex: 1000,
          background: '#002140',
          color: '#fff',
          padding: '16px',
          borderRadius: '8px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.5)',
          border: '1px solid rgba(255, 255, 255, 0.1)'
        }}>
          Загрузка...
        </div>
      )}
      
      {/* Heatmap lines - colored paths between pipes */}
      {heatmapPaths.map((path, index) => {
        const pipe1 = displayPipes.find((p) => 
          p.location && 
          Math.abs(p.location.lat - path[0][0]) < 0.0001 &&
          Math.abs(p.location.lon - path[0][1]) < 0.0001
        );
        const pipe2 = displayPipes.find((p) => 
          p.location && 
          Math.abs(p.location.lat - path[1][0]) < 0.0001 &&
          Math.abs(p.location.lon - path[1][1]) < 0.0001
        );
        
        const avgRisk = pipe1 && pipe2 
          ? ((pipe1.risk_score || 0) + (pipe2.risk_score || 0)) / 2
          : pipe1?.risk_score || pipe2?.risk_score || 0;
        
        return (
          <Polyline
            key={`path-${index}`}
            positions={path}
            color={getRiskColor(avgRisk)}
            weight={4}
            opacity={0.6}
          />
        );
      })}
      
      {/* Markers with colored circles */}
      {displayPipes
        .filter((pipe) => pipe.location && pipe.location.lat && pipe.location.lon)
        .map((pipe) => {
          const position: LatLngExpression = [
            pipe.location!.lat, 
            pipe.location!.lon
          ];
          const riskScore = pipe.risk_score || 0;
          const riskColor = getRiskColor(riskScore);
          
          return (
            <React.Fragment key={pipe.id}>
              <CircleMarker
                center={position}
                radius={8 + (riskScore * 12)} // Size based on risk
                pathOptions={{
                  fillColor: riskColor,
                  fillOpacity: 0.7,
                  color: riskColor,
                  weight: 2,
                }}
              >
                <Popup>
                  <div style={{ color: '#000' }}>
                    <strong>QR: {pipe.qr_code}</strong>
                    <br />
                    <span style={{ color: riskColor, fontWeight: 'bold' }}>
                      Risk Score: {riskScore ? (riskScore * 100).toFixed(1) : 'N/A'}%
                    </span>
                    <br />
                    Status: {riskScore > 0.7 ? '🔴 Critical' : 
                            riskScore > 0.4 ? '🟠 Warning' : '🟢 Ok'}
                  </div>
                </Popup>
              </CircleMarker>
            </React.Fragment>
          );
        })}
    </MapContainer>
  );
};
