import React, { useState } from 'react';
import {
  Box, Button, Paper, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, TablePagination, IconButton, Typography, Alert, Snackbar,
} from '@mui/material';
import { Add, Edit, Delete } from '@mui/icons-material';
import { createProject, updateProject, deleteProject } from '../services/api';
import StatusChip from '../components/StatusChip';
import FormDialog from '../components/FormDialog';
import { useProject } from '../context/ProjectContext';

const PROJECT_FIELDS = [
  { name: 'name', label: 'Project Name', required: true },
  { name: 'code', label: 'Project Code' },
  { name: 'client', label: 'Client', required: true },
  { name: 'description', label: 'Description' },
  { name: 'start_date', label: 'Start Date', type: 'date', required: true },
  { name: 'end_date', label: 'End Date', type: 'date', required: true },
  { name: 'contract_completion_date', label: 'Contract Completion Date', type: 'date' },
  { name: 'status', label: 'Status', type: 'select', options: ['Active', 'Completed', 'At Risk', 'On Hold'] },
  { name: 'phase', label: 'Phase', type: 'select', options: ['Gate B', 'Gate C', 'Design Completion', 'Construction', 'Commissioned'] },
  { name: 'total_budget', label: 'Total Budget (\u00a3)', type: 'number' },
  { name: 'contract_value', label: 'Contract Value (\u00a3)', type: 'number' },
  { name: 'forecast_cost', label: 'Forecast Cost (\u00a3)', type: 'number' },
  { name: 'daily_ld_rate', label: 'Daily LD Rate (\u00a3)', type: 'number' },
  { name: 'ld_cap_pct', label: 'LD Cap (%)', type: 'number' },
  { name: 'location', label: 'Location' },
  { name: 'project_manager', label: 'Project Manager' },
];

export default function ProjectEPS() {
  const { projects, setSelectedProjectId, refreshProjects } = useProject();
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [dialog, setDialog] = useState({ open: false, title: '', fields: [], values: {}, onSubmit: null });
  const [snack, setSnack] = useState({ open: false, message: '', severity: 'success' });

  const showSnack = (message, severity = 'success') => setSnack({ open: true, message, severity });
  const openForm = (title, fields, values, onSubmit) => setDialog({ open: true, title, fields, values: { ...values }, onSubmit });
  const closeForm = () => setDialog({ ...dialog, open: false });
  const handleChange = (name, value) => setDialog((d) => ({ ...d, values: { ...d.values, [name]: value } }));

  const handleCreateProject = () => {
    openForm('New Project', PROJECT_FIELDS, { status: 'Active', phase: 'Gate B', total_budget: 0, contract_value: 0, forecast_cost: 0, daily_ld_rate: 0, ld_cap_pct: 10 }, async (vals) => {
      await createProject(vals);
      closeForm();
      refreshProjects();
      showSnack('Project created');
    });
  };

  const handleEditProject = (p) =>
    openForm('Edit Project', PROJECT_FIELDS, p, async (vals) => {
      await updateProject(p.id, vals);
      closeForm();
      refreshProjects();
      showSnack('Project updated');
    });

  const handleDeleteProject = async (id) => {
    if (!window.confirm('Delete this project? This will remove all related data.')) return;
    await deleteProject(id);
    refreshProjects();
    showSnack('Project deleted');
  };

  return (
    <Box>
      <Paper>
        <Box sx={{ display: 'flex', justifyContent: 'flex-end', p: 2 }}>
          <Button variant="contained" startIcon={<Add />} onClick={handleCreateProject}>New Project</Button>
        </Box>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                {['Code', 'Project Name', 'Client', 'Manager', 'Start', 'End', 'Budget', 'Contract', 'Status', 'Actions'].map((h) => (
                  <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                ))}
              </TableRow>
            </TableHead>
            <TableBody>
              {projects.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((p) => (
                <TableRow key={p.id} hover sx={{ cursor: 'pointer' }} onClick={() => setSelectedProjectId(p.id)}>
                  <TableCell><Typography variant="body2" color="text.secondary">{p.code || '-'}</Typography></TableCell>
                  <TableCell><Typography fontWeight={600}>{p.name}</Typography></TableCell>
                  <TableCell>{p.client}</TableCell>
                  <TableCell>{p.project_manager || '-'}</TableCell>
                  <TableCell>{p.start_date}</TableCell>
                  <TableCell>{p.end_date}</TableCell>
                  <TableCell>\u00a3{p.total_budget?.toLocaleString()}</TableCell>
                  <TableCell>\u00a3{(p.contract_value || 0).toLocaleString()}</TableCell>
                  <TableCell><StatusChip status={p.status} /></TableCell>
                  <TableCell onClick={(e) => e.stopPropagation()}>
                    <IconButton size="small" onClick={() => handleEditProject(p)}><Edit fontSize="small" /></IconButton>
                    <IconButton size="small" color="error" onClick={() => handleDeleteProject(p.id)}><Delete fontSize="small" /></IconButton>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination
          component="div" count={projects.length} page={page}
          onPageChange={(_, p) => setPage(p)}
          rowsPerPage={rowsPerPage}
          onRowsPerPageChange={(e) => { setRowsPerPage(+e.target.value); setPage(0); }}
        />
      </Paper>

      <FormDialog
        open={dialog.open} onClose={closeForm} onSubmit={dialog.onSubmit}
        title={dialog.title} fields={dialog.fields} values={dialog.values} onChange={handleChange}
      />
      <Snackbar open={snack.open} autoHideDuration={3000} onClose={() => setSnack({ ...snack, open: false })}>
        <Alert severity={snack.severity} onClose={() => setSnack({ ...snack, open: false })}>{snack.message}</Alert>
      </Snackbar>
    </Box>
  );
}
