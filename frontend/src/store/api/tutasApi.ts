import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import type { Pipe, DashboardStats } from '../../types';

// API Key для доступа к API
// В production должен быть установлен через переменную окружения VITE_API_KEY
// Для development используется значение по умолчанию (можно изменить в .env)
const API_KEY = import.meta.env.VITE_API_KEY || import.meta.env.DEV ? 'dev-api-key-12345' : '';

export const tutasApi = createApi({
  reducerPath: 'tutasApi',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api/v1',
    prepareHeaders: (headers, { endpoint }) => {
      // Don't set Content-Type for image endpoints
      if (!endpoint.includes('qr-code') && !endpoint.includes('image')) {
        headers.set('Content-Type', 'application/json');
      }
      // Add Authorization header with API key
      headers.set('Authorization', `Bearer ${API_KEY}`);
      return headers;
    },
  }),
  tagTypes: ['Pipe', 'Stats'],
  endpoints: (builder) => ({
    getPipeByQr: builder.query<Pipe, string>({
      query: (qrCode) => `/pipes/qr/${qrCode}`,
      providesTags: ['Pipe'],
    }),
    getAllPipes: builder.query<Pipe[], void>({
      query: () => '/pipes',
      providesTags: ['Pipe'],
    }),
    getDashboardStats: builder.query<DashboardStats, void>({
      query: () => '/pipes/stats',
      providesTags: ['Stats'],
    }),
    createPipe: builder.mutation<Pipe, Partial<Pipe> & { company?: string }>({
      query: (pipeData) => ({
        url: '/pipes',
        method: 'POST',
        body: pipeData,
      }),
      invalidatesTags: ['Pipe', 'Stats'],
    }),
    getQrCodeImage: builder.query<string, { qrCode: string; size?: number }>({
      query: ({ qrCode, size = 300 }) => ({
        url: `/pipes/qr-code/${qrCode}/image?size=${size}`,
        responseHandler: (response) => response.blob(),
      }),
      transformResponse: async (response: Blob) => {
        return URL.createObjectURL(response);
      },
    }),
    getPipeQrCodeImage: builder.query<string, { pipeId: string; size?: number }>({
      query: ({ pipeId, size = 300 }) => ({
        url: `/pipes/${pipeId}/qr-code?size=${size}`,
        responseHandler: (response) => response.blob(),
      }),
      transformResponse: async (response: Blob) => {
        return URL.createObjectURL(response);
      },
    }),
  }),
});

export const { 
  useGetPipeByQrQuery, 
  useGetAllPipesQuery,
  useGetDashboardStatsQuery,
  useCreatePipeMutation,
  useGetQrCodeImageQuery,
  useGetPipeQrCodeImageQuery,
} = tutasApi;
