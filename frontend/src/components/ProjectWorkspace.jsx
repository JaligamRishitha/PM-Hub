import React from 'react';
import { Outlet } from 'react-router-dom';
import { Box } from '@mui/material';
import ProjectDetailPanel from './ProjectDetailPanel';

export default function ProjectWorkspace() {
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <Box sx={{ flex: 1, overflow: 'auto' }}>
        <Outlet />
      </Box>
      <ProjectDetailPanel />
    </Box>
  );
}
