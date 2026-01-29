import { configureStore } from '@reduxjs/toolkit';
import { tutasApi } from './api/tutasApi';

export const store = configureStore({
  reducer: {
    [tutasApi.reducerPath]: tutasApi.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(tutasApi.middleware),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
