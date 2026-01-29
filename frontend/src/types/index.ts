/**
 * Type definitions for Tutas Ai Frontend
 */

export interface Pipe {
  id: string;
  qr_code: string;
  manufacturer?: string;
  production_date?: string;
  material?: string;
  diameter_mm?: number;
  wall_thickness_mm?: number;
  length_meters?: number;
  current_status: string;
  risk_score?: number;
  predicted_lifetime_years?: number;
  location?: {
    lat: number;
    lon: number;
  };
}

export interface DashboardStats {
  total_length: number;
  total_inspections: number;
  critical_defects: number;
  active_pipes: number;
}

export interface DefectTrend {
  date: string;
  count: number;
  critical: number;
}
