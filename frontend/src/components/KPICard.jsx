import React from 'react';
import { Card, CardContent, Typography, Box } from '@mui/material';

export default function KPICard({ title, value, subtitle, icon, color = '#1976d2', trend, onClick }) {
  return (
    <Card
      sx={{
        cursor: onClick ? 'pointer' : 'default',
        transition: 'transform 0.2s, box-shadow 0.2s',
        '&:hover': onClick ? { transform: 'translateY(-2px)', boxShadow: 4 } : {},
        height: '100%',
      }}
      onClick={onClick}
    >
      <CardContent sx={{ p: 2.5 }}>
        <Box sx={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
          <Box>
            <Typography variant="body2" color="text.secondary" fontWeight={500} sx={{ mb: 0.5 }}>
              {title}
            </Typography>
            <Typography variant="h4" fontWeight={700} sx={{ color, lineHeight: 1.2 }}>
              {value}
            </Typography>
            {subtitle && (
              <Typography variant="caption" color="text.secondary" sx={{ mt: 0.5, display: 'block' }}>
                {subtitle}
              </Typography>
            )}
          </Box>
          {icon && (
            <Box
              sx={{
                bgcolor: `${color}15`,
                borderRadius: 2,
                p: 1,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {React.cloneElement(icon, { sx: { color, fontSize: 28 } })}
            </Box>
          )}
        </Box>
        {trend !== undefined && (
          <Typography
            variant="caption"
            sx={{
              mt: 1,
              display: 'block',
              color: trend >= 0 ? '#2e7d32' : '#c62828',
              fontWeight: 600,
            }}
          >
            {trend >= 0 ? '+' : ''}{trend}% vs last period
          </Typography>
        )}
      </CardContent>
    </Card>
  );
}
