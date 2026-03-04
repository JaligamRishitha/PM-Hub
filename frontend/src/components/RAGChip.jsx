import React from 'react';
import { Chip } from '@mui/material';

const RAG_COLORS = {
  Green: { bg: '#e8f5e9', color: '#2e7d32', border: '#4caf50' },
  Amber: { bg: '#fff8e1', color: '#f57f17', border: '#ffc107' },
  Red: { bg: '#ffebee', color: '#c62828', border: '#f44336' },
};

export default function RAGChip({ status, label, size = 'small' }) {
  const colors = RAG_COLORS[status] || RAG_COLORS.Green;
  return (
    <Chip
      label={label || status}
      size={size}
      sx={{
        bgcolor: colors.bg,
        color: colors.color,
        border: `1px solid ${colors.border}`,
        fontWeight: 600,
        fontSize: '0.75rem',
      }}
    />
  );
}
