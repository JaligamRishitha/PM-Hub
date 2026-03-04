import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ProjectProvider } from './context/ProjectContext';
import Layout from './components/Layout';
import ProjectWorkspace from './components/ProjectWorkspace';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import PortfolioView from './pages/PortfolioView';
import ProjectActivities from './pages/ProjectActivities';
import CommercialView from './pages/CommercialView';
import RiskIssuesView from './pages/RiskIssuesView';
import SafetyView from './pages/SafetyView';
import DocumentsView from './pages/DocumentsView';
import SimulationLab from './pages/SimulationLab';
import ReportsView from './pages/ReportsView';
import ResourcePool from './pages/ResourcePool';

const theme = createTheme({
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
  },
  palette: {
    primary: { main: '#1565c0' },
    background: { default: '#f5f7fa' },
  },
  components: {
    MuiCard: {
      styleOverrides: {
        root: { borderRadius: 12, boxShadow: '0 1px 3px rgba(0,0,0,0.08)' },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: { borderRadius: 12 },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: { textTransform: 'none', borderRadius: 8, fontWeight: 600 },
      },
    },
    MuiTableCell: {
      styleOverrides: {
        head: { fontWeight: 600, fontSize: '0.8rem', color: '#546e7a' },
      },
    },
  },
});

function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();
  if (loading) return null;
  if (!user) return <Navigate to="/login" replace />;
  return children;
}

function AppRoutes() {
  const { user, loading } = useAuth();
  if (loading) return null;

  return (
    <Routes>
      <Route path="/login" element={user ? <Navigate to="/" replace /> : <Login />} />
      <Route
        element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }
      >
        {/* Dashboard & Portfolio */}
        <Route path="/" element={<Dashboard />} />
        <Route path="/portfolio" element={<PortfolioView />} />

        {/* Projects — nested under /projects with ProjectWorkspace wrapper */}
        <Route path="/projects" element={<ProjectWorkspace />}>
          <Route index element={<Navigate to="/projects/activities" replace />} />
          <Route path="activities" element={<ProjectActivities />} />
          <Route path="commercial" element={<CommercialView />} />
          <Route path="risk-issues" element={<RiskIssuesView />} />
          <Route path="safety" element={<SafetyView />} />
          <Route path="documents" element={<DocumentsView />} />
        </Route>

        {/* Resources — resource pool */}
        <Route path="/resources" element={<ResourcePool />} />

        {/* Simulation & Reports — top-level */}
        <Route path="/simulation" element={<SimulationLab />} />
        <Route path="/reports" element={<ReportsView />} />

        {/* Old route redirects */}
        <Route path="/commercial" element={<Navigate to="/projects/commercial" replace />} />
        <Route path="/risk-issues" element={<Navigate to="/projects/risk-issues" replace />} />
        <Route path="/safety" element={<Navigate to="/projects/safety" replace />} />
        <Route path="/documents" element={<Navigate to="/projects/documents" replace />} />
        <Route path="/resources/simulation" element={<Navigate to="/simulation" replace />} />
        <Route path="/resources/reports" element={<Navigate to="/reports" replace />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <BrowserRouter>
        <AuthProvider>
          <ProjectProvider>
            <AppRoutes />
          </ProjectProvider>
        </AuthProvider>
      </BrowserRouter>
    </ThemeProvider>
  );
}
