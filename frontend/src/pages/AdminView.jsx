import React, { useEffect, useState } from 'react';
import {
  Box, Paper, Typography, Grid, Card, CardContent, Button, Table, TableBody,
  TableCell, TableContainer, TableHead, TableRow, Chip, Stack, IconButton,
  Dialog, DialogTitle, DialogContent, DialogActions, TextField, MenuItem,
  Alert, Snackbar, Avatar, Switch, FormControlLabel, LinearProgress,
} from '@mui/material';
import {
  AdminPanelSettings, PersonAdd, Edit, Block, CheckCircle, People,
  Security, Settings,
} from '@mui/icons-material';
import { useAuth } from '../context/AuthContext';
import { register, getProjects, getUsers, updateUser } from '../services/api';

const ROLES = [
  { value: 'admin', label: 'Admin' },
  { value: 'project_manager', label: 'Project Manager' },
  { value: 'commercial_manager', label: 'Commercial Manager' },
  { value: 'hse_officer', label: 'HSE Officer' },
];

const ROLE_COLORS = {
  admin: '#d32f2f',
  project_manager: '#1565c0',
  commercial_manager: '#2e7d32',
  hse_officer: '#7b1fa2',
};

export default function AdminView() {
  const { user: currentUser } = useAuth();
  const [users, setUsers] = useState([]);
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [snack, setSnack] = useState({ open: false, message: '', severity: 'success' });
  const [form, setForm] = useState({ email: '', full_name: '', password: 'password123', role: 'project_manager' });

  const showSnack = (msg, sev = 'success') => setSnack({ open: true, message: msg, severity: sev });

  const fetchUsers = async () => {
    try {
      const res = await getUsers();
      setUsers(res.data);
    } catch {
      setUsers([]);
    }
  };

  useEffect(() => {
    Promise.all([
      fetchUsers(),
      getProjects().then(r => setProjects(r.data)).catch(() => {}),
    ]).finally(() => setLoading(false));
  }, []);

  const handleCreate = async () => {
    try {
      await register(form);
      showSnack('User created successfully');
      setDialogOpen(false);
      setForm({ email: '', full_name: '', password: 'password123', role: 'project_manager' });
      fetchUsers();
    } catch (err) {
      showSnack(err.response?.data?.detail || 'Failed to create user', 'error');
    }
  };

  const toggleUserActive = async (userId, isActive) => {
    try {
      await updateUser(userId, { is_active: !isActive });
      showSnack(`User ${isActive ? 'deactivated' : 'activated'}`);
      fetchUsers();
    } catch {
      showSnack('Failed to update user status', 'error');
    }
  };

  // Statistics
  const usersByRole = ROLES.map(r => ({
    role: r.label,
    count: users.filter(u => u.role === r.value).length,
    color: ROLE_COLORS[r.value],
  }));
  const activeUsers = users.filter(u => u.is_active !== false).length;

  if (loading) return <LinearProgress />;

  // Only admin users should see this page
  if (currentUser?.role !== 'admin') {
    return (
      <Box sx={{ p: 4, textAlign: 'center' }}>
        <Security sx={{ fontSize: 64, color: '#ccc', mb: 2 }} />
        <Typography variant="h5" color="text.secondary">Access Denied</Typography>
        <Typography color="text.secondary">Only administrators can access this page.</Typography>
      </Box>
    );
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <AdminPanelSettings sx={{ fontSize: 32, color: '#d32f2f' }} />
          <Box>
            <Typography variant="h5" fontWeight={700}>Administration</Typography>
            <Typography variant="body2" color="text.secondary">
              Manage users, roles, and system settings
            </Typography>
          </Box>
        </Box>
        <Button variant="contained" startIcon={<PersonAdd />} onClick={() => setDialogOpen(true)}
          sx={{ bgcolor: '#1a2332', '&:hover': { bgcolor: '#2d3e50' } }}>
          Add User
        </Button>
      </Box>

      {/* Summary Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid item xs={6} sm={3}>
          <Card>
            <CardContent sx={{ textAlign: 'center', py: 2 }}>
              <People sx={{ color: '#1565c0', fontSize: 32, mb: 0.5 }} />
              <Typography variant="h4" fontWeight={700}>{users.length}</Typography>
              <Typography variant="caption" color="text.secondary">Total Users</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={6} sm={3}>
          <Card>
            <CardContent sx={{ textAlign: 'center', py: 2 }}>
              <CheckCircle sx={{ color: '#2e7d32', fontSize: 32, mb: 0.5 }} />
              <Typography variant="h4" fontWeight={700}>{activeUsers}</Typography>
              <Typography variant="caption" color="text.secondary">Active Users</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={6} sm={3}>
          <Card>
            <CardContent sx={{ textAlign: 'center', py: 2 }}>
              <Settings sx={{ color: '#ed6c02', fontSize: 32, mb: 0.5 }} />
              <Typography variant="h4" fontWeight={700}>{projects.length}</Typography>
              <Typography variant="caption" color="text.secondary">Total Projects</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={6} sm={3}>
          <Card>
            <CardContent sx={{ textAlign: 'center', py: 2 }}>
              <Security sx={{ color: '#7b1fa2', fontSize: 32, mb: 0.5 }} />
              <Typography variant="h4" fontWeight={700}>{ROLES.length}</Typography>
              <Typography variant="caption" color="text.secondary">User Roles</Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Users by Role */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        {usersByRole.map((r) => (
          <Grid item xs={6} sm={3} key={r.role}>
            <Card variant="outlined">
              <CardContent sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', py: 1.5 }}>
                <Box>
                  <Typography variant="body2" color="text.secondary">{r.role}</Typography>
                  <Typography variant="h5" fontWeight={700}>{r.count}</Typography>
                </Box>
                <Avatar sx={{ bgcolor: r.color, width: 36, height: 36, fontSize: 14 }}>
                  {r.count}
                </Avatar>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* Users Table */}
      <Paper sx={{ p: 3 }}>
        <Typography variant="h6" fontWeight={600} mb={2}>User Management</Typography>
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>User</TableCell>
                <TableCell>Email</TableCell>
                <TableCell>Role</TableCell>
                <TableCell align="center">Status</TableCell>
                <TableCell>Created</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {users.map((u) => (
                <TableRow key={u.id} hover>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                      <Avatar sx={{ width: 32, height: 32, bgcolor: ROLE_COLORS[u.role] || '#666', fontSize: 13 }}>
                        {u.full_name?.split(' ').map(n => n[0]).join('').toUpperCase()}
                      </Avatar>
                      <Typography fontWeight={600}>{u.full_name}</Typography>
                    </Box>
                  </TableCell>
                  <TableCell>{u.email}</TableCell>
                  <TableCell>
                    <Chip
                      label={ROLES.find(r => r.value === u.role)?.label || u.role}
                      size="small"
                      sx={{ bgcolor: ROLE_COLORS[u.role] || '#666', color: '#fff' }}
                    />
                  </TableCell>
                  <TableCell align="center">
                    <Chip
                      label={u.is_active !== false ? 'Active' : 'Inactive'}
                      size="small"
                      color={u.is_active !== false ? 'success' : 'default'}
                      variant="outlined"
                    />
                  </TableCell>
                  <TableCell>{u.created_at ? new Date(u.created_at).toLocaleDateString() : '-'}</TableCell>
                  <TableCell align="center">
                    {u.id !== currentUser?.id && (
                      <IconButton size="small"
                        onClick={() => toggleUserActive(u.id, u.is_active !== false)}
                        color={u.is_active !== false ? 'error' : 'success'}>
                        {u.is_active !== false ? <Block fontSize="small" /> : <CheckCircle fontSize="small" />}
                      </IconButton>
                    )}
                  </TableCell>
                </TableRow>
              ))}
              {users.length === 0 && (
                <TableRow>
                  <TableCell colSpan={6} align="center">
                    <Alert severity="info" sx={{ justifyContent: 'center' }}>
                      User listing requires the /api/auth/users endpoint. Users can still be created.
                    </Alert>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      {/* Create User Dialog */}
      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Create New User</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField label="Full Name" fullWidth value={form.full_name}
              onChange={e => setForm({ ...form, full_name: e.target.value })} required />
            <TextField label="Email" type="email" fullWidth value={form.email}
              onChange={e => setForm({ ...form, email: e.target.value })} required />
            <TextField label="Password" fullWidth value={form.password}
              onChange={e => setForm({ ...form, password: e.target.value })} required
              helperText="Default: password123" />
            <TextField select label="Role" fullWidth value={form.role}
              onChange={e => setForm({ ...form, role: e.target.value })}>
              {ROLES.map(r => <MenuItem key={r.value} value={r.value}>{r.label}</MenuItem>)}
            </TextField>
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleCreate}
            disabled={!form.email || !form.full_name}
            sx={{ bgcolor: '#1a2332', '&:hover': { bgcolor: '#2d3e50' } }}>
            Create User
          </Button>
        </DialogActions>
      </Dialog>

      <Snackbar open={snack.open} autoHideDuration={3000} onClose={() => setSnack({ ...snack, open: false })}>
        <Alert severity={snack.severity} onClose={() => setSnack({ ...snack, open: false })}>{snack.message}</Alert>
      </Snackbar>
    </Box>
  );
}
