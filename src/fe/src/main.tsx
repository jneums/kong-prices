import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import '@fontsource/inter';
import { BrowserRouter } from 'react-router';
import { QueryClient, QueryClientProvider } from 'react-query';
import { CssBaseline, CssVarsProvider } from '@mui/joy';

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <CssVarsProvider defaultMode="dark">
      <CssBaseline />

      <BrowserRouter>
        <QueryClientProvider client={queryClient}>
          <App />
        </QueryClientProvider>
      </BrowserRouter>
    </CssVarsProvider>
  </React.StrictMode>,
);
