import React, { useState } from 'react';
import {
  Box, Card, CardContent, TextField, Button, Typography, Alert, Stack,
} from '@mui/material';
import { Assessment } from '@mui/icons-material';
import { login } from '../services/api';
import { useAuth } from '../context/AuthContext';

export default function Login() {
  const { loginUser } = useAuth();
  const [email, setEmail] = useState('pm@pmhub.com');
  const [password, setPassword] = useState('password123');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      const res = await login(email, password);
      loginUser(res.data.access_token, res.data.user);
    } catch (err) {
      setError(err.response?.data?.detail || 'Login failed. Please check your credentials.');
      setSubmitting(false);
    }
  };

  return (
    <Box sx={{
      minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: 'linear-gradient(135deg, #1a2332 0%, #2d3e50 50%, #1a2332 100%)',
    }}>
      <Card sx={{ maxWidth: 440, width: '100%', mx: 2, boxShadow: '0 8px 32px rgba(0,0,0,0.3)' }}>
        <Box sx={{ bgcolor: '#1a2332', p: 3, textAlign: 'center' }}>
          <Assessment sx={{ fontSize: 48, color: '#4fc3f7', mb: 1 }} />
          <Typography variant="h4" fontWeight={800} sx={{ color: '#fff', letterSpacing: '1px' }}>PM Hub</Typography>
          <Typography sx={{ color: '#90caf9', fontSize: '0.85rem' }}>Project Management Intelligence Platform</Typography>
        </Box>
        <CardContent sx={{ p: 4 }}>
          {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
          <form onSubmit={handleSubmit}>
            <Stack spacing={2.5}>
              <TextField label="Email" fullWidth value={email} onChange={(e) => setEmail(e.target.value)} required />
              <TextField label="Password" type="password" fullWidth value={password} onChange={(e) => setPassword(e.target.value)} required />
              <Button
                variant="contained" size="large" type="submit" fullWidth disabled={submitting}
                sx={{ bgcolor: '#1a2332', '&:hover': { bgcolor: '#2d3e50' }, py: 1.5, fontWeight: 700 }}
              >
                {submitting ? 'Signing in...' : 'Sign In'}
              </Button>
            </Stack>
          </form>
          <Typography variant="caption" color="text.secondary" sx={{ mt: 3, display: 'block', textAlign: 'center' }}>
            Demo: pm@pmhub.com / cm@pmhub.com / hse@pmhub.com / admin@pmhub.com
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ display: 'block', textAlign: 'center' }}>
            Password: password123
          </Typography>
        </CardContent>
      </Card>
    </Box>
  );
}
