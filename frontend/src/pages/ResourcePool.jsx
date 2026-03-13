import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Paper, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, TablePagination, IconButton, Typography,
  Grid, Card, CardContent, Chip, TextField, MenuItem, Button,
  Dialog, DialogTitle, DialogContent, DialogActions, Divider, Tooltip,
} from '@mui/material';
import { Add, Edit, Person, Description as FormIcon } from '@mui/icons-material';
import { getProjects } from '../services/api';

/* ── Resource Pool Data (organisation-wide) ── */
const RESOURCE_POOL = [];

/* ── Resource Edit Dialog ── */
function ResourceEditDialog({ open, onClose, resource, onSave }) {
  const [form, setForm] = useState({});

  useEffect(() => {
    if (resource) {
      setForm({
        id: resource.id, name: resource.name, role: resource.role, type: resource.type,
        unit: resource.unit, rate: String(resource.rate), allocation: String(resource.allocation),
        project: resource.project || '-', availability: resource.availability || 'Available',
      });
    }
  }, [resource]);

  const set = (f, v) => setForm(prev => ({ ...prev, [f]: v }));

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <Person color="primary" /> Resource Details
      </DialogTitle>
      <DialogContent>
        <Divider sx={{ mb: 2 }} />
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <TextField label="Resource ID" value={form.id || ''} onChange={e => set('id', e.target.value)} fullWidth size="small" />
          <TextField label="Resource Name" value={form.name || ''} onChange={e => set('name', e.target.value)} fullWidth size="small" required />
          <TextField label="Role" value={form.role || ''} onChange={e => set('role', e.target.value)} fullWidth size="small" />
          <TextField label="Type" value={form.type || ''} onChange={e => set('type', e.target.value)} fullWidth size="small" select>
            {['Labour', 'Equipment', 'Material'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
          </TextField>
          <Box sx={{ display: 'flex', gap: 2 }}>
            <TextField label="Unit" value={form.unit || ''} onChange={e => set('unit', e.target.value)} fullWidth size="small" />
            <TextField label="Rate (£)" type="number" value={form.rate || ''} onChange={e => set('rate', e.target.value)} fullWidth size="small" />
          </Box>
          <Box sx={{ display: 'flex', gap: 2 }}>
            <TextField label="Allocation (%)" value={form.allocation || ''} onChange={e => set('allocation', e.target.value)} fullWidth size="small" />
            <TextField label="Availability" value={form.availability || ''} onChange={e => set('availability', e.target.value)} fullWidth size="small" select>
              {['Available', 'Assigned', 'Partial', 'In Stock', 'Low Stock'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
            </TextField>
          </Box>
          <TextField label="Assigned Project" value={form.project || ''} onChange={e => set('project', e.target.value)} fullWidth size="small" />
        </Box>
      </DialogContent>
      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={() => { if (onSave) onSave(); onClose(); }}>Save Changes</Button>
      </DialogActions>
    </Dialog>
  );
}

/* ── Approval Dialog ── */
function ApprovalDialog({ open, onClose, item, onApprove }) {
  const [form, setForm] = useState({ requested_by: '', reason: '', change_description: '', priority: 'Normal', target_date: '' });

  useEffect(() => { if (open) setForm({ requested_by: '', reason: '', change_description: '', priority: 'Normal', target_date: '' }); }, [open]);

  const set = (f, v) => setForm(prev => ({ ...prev, [f]: v }));

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <FormIcon color="primary" /> Request Approval to Edit
      </DialogTitle>
      <DialogContent>
        <Typography variant="caption" color="text.secondary" sx={{ mb: 2, display: 'block' }}>
          Resource: <strong>{item?.name || '-'}</strong>
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <TextField label="Requested By" value={form.requested_by} onChange={e => set('requested_by', e.target.value)} fullWidth size="small" required />
          <TextField label="Reason for Change" value={form.reason} onChange={e => set('reason', e.target.value)} fullWidth size="small" required select>
            {['Resource Reallocation', 'Rate Adjustment', 'Project Transfer', 'Availability Update', 'New Assignment', 'Other'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
          </TextField>
          <TextField label="Description of Proposed Changes" value={form.change_description} onChange={e => set('change_description', e.target.value)} fullWidth size="small" required multiline rows={3} />
          <TextField label="Priority" value={form.priority} onChange={e => set('priority', e.target.value)} fullWidth size="small" select>
            {['Low', 'Normal', 'High', 'Urgent'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
          </TextField>
          <TextField label="Target Date" type="date" value={form.target_date} onChange={e => set('target_date', e.target.value)} fullWidth size="small" InputLabelProps={{ shrink: true }} />
        </Box>
      </DialogContent>
      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={() => { if (form.requested_by && form.reason && form.change_description) onApprove(item?.id); }} disabled={!form.requested_by || !form.reason || !form.change_description}>Submit for Approval</Button>
      </DialogActions>
    </Dialog>
  );
}

export default function ResourcePool() {
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [filterType, setFilterType] = useState('All');
  const [filterAvailability, setFilterAvailability] = useState('All');
  const [filterProject, setFilterProject] = useState('All');
  const [editDialog, setEditDialog] = useState({ open: false, resource: null, onSave: null });
  const [approvalDialog, setApprovalDialog] = useState({ open: false, item: null });
  const [approvalStatus, setApprovalStatus] = useState({});

  const projectNames = [...new Set(RESOURCE_POOL.map(r => r.project).filter(p => p !== '-'))];

  const filtered = RESOURCE_POOL.filter(r => {
    if (filterType !== 'All' && r.type !== filterType) return false;
    if (filterAvailability !== 'All' && r.availability !== filterAvailability) return false;
    if (filterProject !== 'All') {
      if (filterProject === 'Unassigned') return r.project === '-';
      if (r.project !== filterProject) return false;
    }
    return true;
  });

  const labourCount = RESOURCE_POOL.filter(r => r.type === 'Labour').length;
  const equipmentCount = RESOURCE_POOL.filter(r => r.type === 'Equipment').length;
  const materialCount = RESOURCE_POOL.filter(r => r.type === 'Material').length;
  const availableCount = RESOURCE_POOL.filter(r => r.availability === 'Available').length;
  const assignedCount = RESOURCE_POOL.filter(r => r.availability === 'Assigned').length;
  const partialCount = RESOURCE_POOL.filter(r => r.availability === 'Partial').length;

  const handleApprove = (id) => {
    setApprovalStatus(prev => ({ ...prev, [id]: 'approved' }));
    setApprovalDialog({ open: false, item: null });
  };

  const handleEditApproved = (r) => {
    setEditDialog({
      open: true, resource: r, onSave: () => {
        setApprovalStatus(prev => { const n = { ...prev }; delete n[r.id]; return n; });
      },
    });
  };

  const availChipColor = (a) => {
    if (a === 'Available') return 'success';
    if (a === 'Assigned') return 'primary';
    if (a === 'Partial') return 'warning';
    if (a === 'Low Stock') return 'error';
    return 'default';
  };

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} sx={{ mb: 3 }}>Resource Pool</Typography>

      {/* KPI Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        {[
          { label: 'Total Resources', val: RESOURCE_POOL.length, color: '#1976d2' },
          { label: 'Labour', val: labourCount, color: '#1565c0' },
          { label: 'Equipment', val: equipmentCount, color: '#ed6c02' },
          { label: 'Material', val: materialCount, color: '#9c27b0' },
          { label: 'Available', val: availableCount, color: '#2e7d32' },
          { label: 'Assigned', val: assignedCount, color: '#1976d2' },
          { label: 'Partial', val: partialCount, color: '#ed6c02' },
        ].map((s, i) => (
          <Grid item xs={6} sm={3} md key={i}>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} sx={{ color: s.color }}>{s.val}</Typography>
              <Typography variant="caption" color="text.secondary">{s.label}</Typography>
            </CardContent></Card>
          </Grid>
        ))}
      </Grid>

      {/* Filters & Table */}
      <Paper>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2 }}>
          <Box sx={{ display: 'flex', gap: 2 }}>
            <TextField select size="small" label="Type" value={filterType} onChange={e => { setFilterType(e.target.value); setPage(0); }} sx={{ minWidth: 140 }}>
              {['All', 'Labour', 'Equipment', 'Material'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
            </TextField>
            <TextField select size="small" label="Availability" value={filterAvailability} onChange={e => { setFilterAvailability(e.target.value); setPage(0); }} sx={{ minWidth: 140 }}>
              {['All', 'Available', 'Assigned', 'Partial', 'In Stock', 'Low Stock'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
            </TextField>
            <TextField select size="small" label="Project" value={filterProject} onChange={e => { setFilterProject(e.target.value); setPage(0); }} sx={{ minWidth: 200 }}>
              <MenuItem value="All">All Projects</MenuItem>
              {projectNames.map(p => <MenuItem key={p} value={p}>{p}</MenuItem>)}
              <MenuItem value="Unassigned">Unassigned</MenuItem>
            </TextField>
          </Box>
          <Button variant="contained" startIcon={<Add />} onClick={() => setEditDialog({
            open: true,
            resource: { id: '', name: '', role: '', type: 'Labour', unit: 'hrs', rate: 0, allocation: 0, project: '-', availability: 'Available' },
            onSave: null,
          })}>Add Resource</Button>
        </Box>
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                {['ID', 'Resource Name', 'Role', 'Type', 'Unit', 'Rate (£)', 'Allocation %', 'Project', 'Availability', 'Actions'].map(h => (
                  <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                ))}
              </TableRow>
            </TableHead>
            <TableBody>
              {filtered.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((r, idx) => (
                <TableRow key={r.id} sx={{ bgcolor: idx % 2 === 0 ? '#fafafa' : '#ffffff', '&:hover': { bgcolor: '#f0f4ff' } }}>
                  <TableCell><Typography variant="body2" color="text.secondary">{r.id}</Typography></TableCell>
                  <TableCell><Typography fontWeight={500}>{r.name}</Typography></TableCell>
                  <TableCell>{r.role !== '-' ? r.role : '-'}</TableCell>
                  <TableCell>
                    <Chip label={r.type} size="small"
                      color={r.type === 'Labour' ? 'primary' : r.type === 'Equipment' ? 'warning' : 'default'}
                      variant="outlined" />
                  </TableCell>
                  <TableCell>{r.unit}</TableCell>
                  <TableCell>£{r.rate.toLocaleString()}</TableCell>
                  <TableCell>{r.allocation !== '-' ? `${r.allocation}%` : '-'}</TableCell>
                  <TableCell>{r.project !== '-' ? r.project : '-'}</TableCell>
                  <TableCell>
                    <Chip label={r.availability} size="small" color={availChipColor(r.availability)} variant="outlined" />
                  </TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', gap: 0.5 }}>
                      <Tooltip title={approvalStatus[r.id] === 'approved' ? 'Approved' : 'Request Approval to Edit'}>
                        <span>
                          <IconButton size="small" color={approvalStatus[r.id] === 'approved' ? 'default' : 'primary'}
                            disabled={approvalStatus[r.id] === 'approved'}
                            onClick={() => setApprovalDialog({ open: true, item: r })}>
                            <FormIcon fontSize="small" />
                          </IconButton>
                        </span>
                      </Tooltip>
                      <Tooltip title={approvalStatus[r.id] === 'approved' ? 'Edit Resource' : 'Approval required before editing'}>
                        <span>
                          <IconButton size="small" color={approvalStatus[r.id] === 'approved' ? 'primary' : 'default'}
                            disabled={approvalStatus[r.id] !== 'approved'}
                            onClick={() => handleEditApproved(r)}>
                            <Edit fontSize="small" />
                          </IconButton>
                        </span>
                      </Tooltip>
                    </Box>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination component="div" count={filtered.length} page={page} onPageChange={(_, p) => setPage(p)}
          rowsPerPage={rowsPerPage} onRowsPerPageChange={e => { setRowsPerPage(+e.target.value); setPage(0); }} />
      </Paper>

      <ResourceEditDialog open={editDialog.open} onClose={() => setEditDialog({ open: false, resource: null, onSave: null })}
        resource={editDialog.resource} onSave={editDialog.onSave} />
      <ApprovalDialog open={approvalDialog.open} onClose={() => setApprovalDialog({ open: false, item: null })}
        item={approvalDialog.item} onApprove={handleApprove} />
    </Box>
  );
}
