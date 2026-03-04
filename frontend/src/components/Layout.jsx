import React, { useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import {
  AppBar, Box, CssBaseline, Toolbar, Typography, Avatar, Menu, MenuItem, Chip,
  Divider, IconButton,
} from '@mui/material';
import { Logout, Assessment } from '@mui/icons-material';
import { useAuth } from '../context/AuthContext';
import { useProject } from '../context/ProjectContext';
import StatusChip from './StatusChip';

const ROLE_LABELS = {
  project_manager: 'Project Manager',
  commercial_manager: 'Commercial Manager',
  hse_officer: 'HSE Officer',
  admin: 'Admin',
};

const PRIMARY_TABS = [
  { label: 'Dashboards', path: '/' },
  { label: 'Resources', path: '/resources' },
  { label: 'Simulation Lab', path: '/simulation' },
  { label: 'Reports', path: '/reports' },
];

const SUB_TABS = {
  '/projects': [
    { label: 'Activities', path: '/projects/activities' },
    { label: 'Commercial', path: '/projects/commercial' },
    { label: 'Risk & Issues', path: '/projects/risk-issues' },
    { label: 'Safety', path: '/projects/safety' },
    { label: 'Documents', path: '/projects/documents' },
  ],
};

function getPrimaryPath(pathname) {
  if (pathname.startsWith('/projects')) return '/projects';
  if (pathname.startsWith('/resources')) return '/resources';
  if (pathname.startsWith('/simulation')) return '/simulation';
  if (pathname.startsWith('/reports')) return '/reports';
  if (pathname === '/portfolio') return '/portfolio';
  return '/';
}

function getSubTabIndex(primaryPath, pathname) {
  const tabs = SUB_TABS[primaryPath];
  if (!tabs) return 0;
  const idx = tabs.findIndex((t) => t.path === pathname);
  return idx >= 0 ? idx : 0;
}

/* P6-style tab button — light bg, active = navy fill */
function PrimaryTab({ label, active, onClick }) {
  return (
    <Box
      onClick={onClick}
      sx={{
        display: 'flex',
        alignItems: 'center',
        gap: 0.3,
        px: 1.8,
        py: 0.6,
        cursor: 'pointer',
        borderRadius: '4px 4px 0 0',
        fontSize: '0.82rem',
        fontWeight: active ? 600 : 500,
        userSelect: 'none',
        whiteSpace: 'nowrap',
        transition: 'background 0.15s, color 0.15s',
        bgcolor: active ? '#4e5b6e' : '#f5f7fa',
        color: active ? '#fff' : '#3b4a5a',
        border: active ? '1px solid #4e5b6e' : '1px solid #b0b8c1',
        borderBottom: active ? '1px solid #4e5b6e' : '1px solid #b0b8c1',
        '&:hover': {
          bgcolor: active ? '#4e5b6e' : '#e8ebef',
        },
      }}
    >
      {label}
    </Box>
  );
}

function ProjectBar() {
  const { selectedProject } = useProject();

  if (!selectedProject) return null;

  return (
    <Box
      sx={{
        display: 'flex',
        alignItems: 'center',
        gap: 2,
        px: 2,
        py: 0.75,
        bgcolor: '#fff',
        borderBottom: '1px solid #e0e0e0',
      }}
    >
      <Typography variant="subtitle1" fontWeight={700} sx={{ color: '#1a2332' }}>
        {selectedProject.name}
      </Typography>
      <StatusChip status={selectedProject.status} />
      {selectedProject.project_manager && (
        <Chip label={selectedProject.project_manager} size="small" variant="outlined" />
      )}
      {selectedProject.client && (
        <Typography variant="body2" color="text.secondary">
          {selectedProject.client}
        </Typography>
      )}
    </Box>
  );
}

export default function Layout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [anchorEl, setAnchorEl] = useState(null);

  const primaryPath = getPrimaryPath(location.pathname);
  const subTabs = SUB_TABS[primaryPath] || null;
  const subIndex = getSubTabIndex(primaryPath, location.pathname);
  const isProjectsRoute = location.pathname.startsWith('/projects');

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <CssBaseline />

      {/* AppBar — same bg as body container */}
      <AppBar position="fixed" sx={{ bgcolor: '#f5f7fa', zIndex: (t) => t.zIndex.appBar + 2, borderBottom: '1px solid #e0e0e0' }} elevation={0}>
        <Toolbar sx={{ minHeight: '44px !important', px: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mr: 3 }}>
            <Assessment sx={{ fontSize: 26, color: '#4e5b6e' }} />
            <Typography variant="subtitle1" fontWeight={800} sx={{ color: '#1a2332', letterSpacing: '0.5px' }}>
              PM Hub
            </Typography>
          </Box>

          <Box sx={{ flexGrow: 1 }} />

          {user && (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
              <Chip
                label={ROLE_LABELS[user.role] || user.role}
                size="small"
                sx={{ color: '#4e5b6e', borderColor: '#9ca3af', fontSize: '0.7rem' }}
                variant="outlined"
              />
              <IconButton onClick={(e) => setAnchorEl(e.currentTarget)} sx={{ p: 0.5 }}>
                <Avatar sx={{ width: 30, height: 30, bgcolor: '#4e5b6e', fontSize: 12, fontWeight: 700 }}>
                  {user.full_name?.split(' ').map((n) => n[0]).join('').toUpperCase()}
                </Avatar>
              </IconButton>
              <Menu anchorEl={anchorEl} open={Boolean(anchorEl)} onClose={() => setAnchorEl(null)}>
                <MenuItem disabled>
                  <Typography variant="body2" fontWeight={600}>{user.full_name}</Typography>
                </MenuItem>
                <MenuItem disabled>
                  <Typography variant="caption" color="text.secondary">{user.email}</Typography>
                </MenuItem>
                <Divider />
                <MenuItem onClick={() => { setAnchorEl(null); logout(); navigate('/login'); }}>
                  <Logout fontSize="small" sx={{ mr: 1 }} /> Logout
                </MenuItem>
              </Menu>
            </Box>
          )}
        </Toolbar>
      </AppBar>

      {/* Primary Tabs — light bar, P6 tab shapes */}
      <Box
        sx={{
          mt: '44px',
          display: 'flex',
          alignItems: 'flex-end',
          gap: 0.5,
          px: 1.5,
          pt: 0.5,
          bgcolor: '#f5f7fa',
          borderBottom: '2px solid #4e5b6e',
        }}
      >
        {PRIMARY_TABS.map((t) => (
          <PrimaryTab
            key={t.path}
            label={t.label}
            active={getPrimaryPath(location.pathname) === t.path}
            onClick={() => navigate(t.path)}
          />
        ))}
      </Box>

      {/* Sub-Tabs Bar — light gray, bold active text */}
      {subTabs && (
        <Box
          sx={{
            display: 'flex',
            alignItems: 'center',
            gap: 0,
            bgcolor: '#e8e8e8',
            borderBottom: '1px solid #d0d0d0',
          }}
        >
          {subTabs.map((t, idx) => (
            <Box
              key={t.path}
              onClick={() => navigate(t.path)}
              sx={{
                px: 2,
                py: 0.9,
                cursor: 'pointer',
                fontSize: '0.8rem',
                fontWeight: subIndex === idx ? 700 : 400,
                color: subIndex === idx ? '#1a1a1a' : '#5f6368',
                userSelect: 'none',
                whiteSpace: 'nowrap',
                borderBottom: subIndex === idx ? '2px solid #4e5b6e' : '2px solid transparent',
                transition: 'color 0.15s, font-weight 0.15s',
                '&:hover': {
                  color: '#1a1a1a',
                  bgcolor: '#dcdcdc',
                },
              }}
            >
              {t.label}
            </Box>
          ))}
        </Box>
      )}

      {/* Project Selection Bar (only for /projects routes) */}
      {isProjectsRoute && <ProjectBar />}

      {/* Main Content — full width */}
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          bgcolor: '#f5f7fa',
          overflow: 'auto',
        }}
      >
        <Outlet />
      </Box>
    </Box>
  );
}
