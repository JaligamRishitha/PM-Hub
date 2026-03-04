import React from 'react';
import {
  Box, Typography, Card, CardContent, List, ListItem, ListItemIcon, ListItemText, Chip,
} from '@mui/material';
import { InsertDriveFile, PictureAsPdf, Description, Shield, Gavel, Engineering, HealthAndSafety, AccountBalance, Assignment } from '@mui/icons-material';

const MOCK_DOCUMENTS = [
  { name: 'Policy Document', icon: <Gavel sx={{ color: '#1565c0' }} />, category: 'Policy', revision: 'Rev 3' },
  { name: 'Safety Measures', icon: <HealthAndSafety sx={{ color: '#d32f2f' }} />, category: 'Safety', revision: 'Rev 2' },
  { name: 'Assets to the Client', icon: <AccountBalance sx={{ color: '#2e7d32' }} />, category: 'Handover', revision: 'Rev 1' },
  { name: 'Project Charter', icon: <Assignment sx={{ color: '#ed6c02' }} />, category: 'Planning', revision: 'Rev 4' },
  { name: 'Risk Assessment Report', icon: <Shield sx={{ color: '#9c27b0' }} />, category: 'Risk', revision: 'Rev 2' },
  { name: 'Environmental Impact Statement', icon: <Description sx={{ color: '#00796b' }} />, category: 'Compliance', revision: 'Rev 1' },
  { name: 'Quality Assurance Plan', icon: <InsertDriveFile sx={{ color: '#1565c0' }} />, category: 'Quality', revision: 'Rev 3' },
  { name: 'Site Inspection Checklist', icon: <Engineering sx={{ color: '#546e7a' }} />, category: 'Inspection', revision: 'Rev 5' },
  { name: 'Contract Agreement', icon: <Gavel sx={{ color: '#4e342e' }} />, category: 'Contract', revision: 'Rev 1' },
  { name: 'Health & Safety Manual', icon: <HealthAndSafety sx={{ color: '#d32f2f' }} />, category: 'Safety', revision: 'Rev 6' },
  { name: 'Budget Estimate Report', icon: <PictureAsPdf sx={{ color: '#c62828' }} />, category: 'Finance', revision: 'Rev 2' },
  { name: 'Stakeholder Communication Plan', icon: <Description sx={{ color: '#1565c0' }} />, category: 'Planning', revision: 'Rev 1' },
];

export default function DocumentsView() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} sx={{ mb: 3 }}>Documents</Typography>

      <Card>
        <CardContent>
          <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 2 }}>
            Project Documents ({MOCK_DOCUMENTS.length})
          </Typography>
          <List disablePadding>
            {MOCK_DOCUMENTS.map((doc, idx) => (
              <ListItem
                key={idx}
                sx={{
                  borderBottom: idx < MOCK_DOCUMENTS.length - 1 ? '1px solid #f0f0f0' : 'none',
                  py: 1.2,
                }}
              >
                <ListItemIcon sx={{ minWidth: 40 }}>
                  {doc.icon}
                </ListItemIcon>
                <ListItemText
                  primary={<Typography fontWeight={500}>{doc.name}</Typography>}
                />
                <Chip label={doc.category} size="small" variant="outlined" sx={{ mr: 1.5 }} />
                <Typography variant="caption" color="text.secondary">{doc.revision}</Typography>
              </ListItem>
            ))}
          </List>
        </CardContent>
      </Card>
    </Box>
  );
}
