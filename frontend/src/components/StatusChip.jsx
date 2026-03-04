import React from 'react';
import { Chip } from '@mui/material';

const STATUS_COLORS = {
  'On Time': 'success',
  'Completed': 'success',
  'Received': 'success',
  'Resolved': 'success',
  'Approved': 'success',
  'In Progress': 'warning',
  'Pending': 'warning',
  'Not Started': 'default',
  'Open': 'warning',
  'Under Investigation': 'warning',
  'Delayed': 'error',
  'At Risk': 'error',
  'Rejected': 'error',
  'Active': 'info',
  'On Hold': 'default',
  'Low': 'success',
  'Medium': 'warning',
  'High': 'error',
};

export default function StatusChip({ status, size = 'small' }) {
  return (
    <Chip
      label={status}
      color={STATUS_COLORS[status] || 'default'}
      size={size}
      variant="filled"
    />
  );
}
