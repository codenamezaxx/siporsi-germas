import React from 'react';

export interface ChartDataPoint {
  name: string;
  value: number;
  secondaryValue?: number;
}

export interface RegionData {
  id: string;
  name: string;
  score: number;
  status: 'Baik' | 'Cukup' | 'Kurang';
}

export interface NavItem {
  label: string;
  path: string;
  icon?: React.ComponentType<{ className?: string }>;
}

export enum ReportType {
  EVALUASI_INSTANSI = 'evaluasi_instansi',
  LAPORAN_SEMESTER = 'laporan_semester'
}

export interface FormSubmission {
  instansi: string;
  periode: string;
  jenis: ReportType;
  data: Record<string, any>;
}