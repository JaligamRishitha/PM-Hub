import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Button, Tab, Tabs, Paper, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, TablePagination, IconButton, Typography, MenuItem,
  TextField, Tooltip, LinearProgress, Alert, Snackbar, Grid, Card, CardContent, Chip,
} from '@mui/material';
import { Add, Edit, Delete, Timeline as TimelineIcon, Flag, FlagCircle } from '@mui/icons-material';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip as RTooltip,
  ResponsiveContainer, ReferenceLine,
} from 'recharts';
import {
  getProjects, createProject, updateProject, deleteProject,
  getActivities, createActivity, updateActivity, deleteActivity,
  getMilestones, createMilestone, updateMilestone, deleteMilestone,
} from '../services/api';
import StatusChip from '../components/StatusChip';
import FormDialog from '../components/FormDialog';

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
  { name: 'total_budget', label: 'Total Budget (£)', type: 'number' },
  { name: 'contract_value', label: 'Contract Value (£)', type: 'number' },
  { name: 'forecast_cost', label: 'Forecast Cost (£)', type: 'number' },
  { name: 'daily_ld_rate', label: 'Daily LD Rate (£)', type: 'number' },
  { name: 'ld_cap_pct', label: 'LD Cap (%)', type: 'number' },
  { name: 'location', label: 'Location' },
  { name: 'project_manager', label: 'Project Manager' },
];

const ACTIVITY_FIELDS = [
  { name: 'activity_code', label: 'Activity Code' },
  { name: 'activity_name', label: 'Activity Name', required: true },
  { name: 'phase', label: 'Phase', type: 'select', options: ['Pre Gate B', 'Gate B-C', 'Gate C-D', 'Closure'], required: true },
  { name: 'planned_start', label: 'Planned Start', type: 'date', required: true },
  { name: 'planned_finish', label: 'Planned Finish', type: 'date', required: true },
  { name: 'actual_start', label: 'Actual Start', type: 'date' },
  { name: 'actual_finish', label: 'Actual Finish', type: 'date' },
  { name: 'completion_pct', label: 'Completion %', type: 'number' },
  { name: 'is_milestone', label: 'Is Milestone', type: 'boolean' },
  { name: 'is_critical', label: 'Critical Path', type: 'boolean' },
];

const MILESTONE_FIELDS = [
  { name: 'name', label: 'Milestone Name', required: true },
  { name: 'phase', label: 'Phase', type: 'select', options: ['Pre Gate B', 'Gate B-C', 'Gate C-D', 'Closure'], required: true },
  { name: 'planned_date', label: 'Planned Date', type: 'date', required: true },
  { name: 'actual_date', label: 'Actual Date', type: 'date' },
  { name: 'is_critical', label: 'Is Critical', type: 'boolean' },
];

// Compute schedule health metrics
function computeScheduleKPIs(activities) {
  if (!activities.length) return { spi: 1, delayDays: 0, onTrack: 0, delayed: 0, completed: 0 };
  let totalPlanned = 0, totalEarned = 0, maxDelay = 0;
  let onTrack = 0, delayed = 0, completed = 0;
  activities.forEach(a => {
    const dur = Math.max(1, (new Date(a.planned_finish) - new Date(a.planned_start)) / 86400000);
    totalPlanned += dur;
    totalEarned += dur * (a.completion_pct / 100);
    if (a.delay_days > maxDelay) maxDelay = a.delay_days;
    if (a.status === 'Completed') completed++;
    else if (a.status === 'Delayed') delayed++;
    else onTrack++;
  });
  return { spi: totalPlanned ? +(totalEarned / totalPlanned).toFixed(2) : 1, delayDays: maxDelay, onTrack, delayed, completed };
}

export default function ProjectView() {
  const [tab, setTab] = useState(0);
  const [projects, setProjects] = useState([]);
  const [activities, setActivities] = useState([]);
  const [milestones, setMilestones] = useState([]);
  const [selectedProject, setSelectedProject] = useState(null);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [dialog, setDialog] = useState({ open: false, title: '', fields: [], values: {}, onSubmit: null });
  const [activityView, setActivityView] = useState('table');
  const [milestoneView, setMilestoneView] = useState('table');
  const [snack, setSnack] = useState({ open: false, message: '', severity: 'success' });

  const showSnack = (message, severity = 'success') => setSnack({ open: true, message, severity });

  const loadProjects = useCallback(async () => {
    try { setProjects((await getProjects()).data); } catch { /* */ }
  }, []);

  const loadActivities = useCallback(async (pid) => {
    try { setActivities((await getActivities(pid)).data); } catch { /* */ }
  }, []);

  const loadMilestones = useCallback(async (pid) => {
    try { setMilestones((await getMilestones(pid)).data); } catch { /* */ }
  }, []);

  useEffect(() => { loadProjects(); }, [loadProjects]);
  useEffect(() => {
    if (selectedProject) { loadActivities(selectedProject); loadMilestones(selectedProject); }
  }, [selectedProject, loadActivities, loadMilestones]);

  const openForm = (title, fields, values, onSubmit) => setDialog({ open: true, title, fields, values: { ...values }, onSubmit });
  const closeForm = () => setDialog({ ...dialog, open: false });
  const handleChange = (name, value) => setDialog(d => ({ ...d, values: { ...d.values, [name]: value } }));

  // Project CRUD
  const handleCreateProject = () => {
    openForm('New Project', PROJECT_FIELDS, { status: 'Active', phase: 'Gate B', total_budget: 0, contract_value: 0, forecast_cost: 0, daily_ld_rate: 0, ld_cap_pct: 10 }, async (vals) => {
      await createProject(vals); closeForm(); loadProjects(); showSnack('Project created');
    });
  };
  const handleEditProject = (p) => openForm('Edit Project', PROJECT_FIELDS, p, async (vals) => {
    await updateProject(p.id, vals); closeForm(); loadProjects(); showSnack('Project updated');
  });
  const handleDeleteProject = async (id) => {
    if (!window.confirm('Delete this project? This will remove all related data.')) return;
    await deleteProject(id); loadProjects();
    if (selectedProject === id) setSelectedProject(null); showSnack('Project deleted');
  };

  // Activity CRUD
  const handleCreateActivity = () => openForm('New Activity', ACTIVITY_FIELDS, { phase: 'Gate C-D', completion_pct: 0, is_milestone: false, is_critical: false }, async (vals) => {
    await createActivity({ ...vals, project_id: selectedProject }); closeForm(); loadActivities(selectedProject); showSnack('Activity created');
  });
  const handleEditActivity = (a) => openForm('Edit Activity', ACTIVITY_FIELDS, a, async (vals) => {
    await updateActivity(a.id, vals); closeForm(); loadActivities(selectedProject); showSnack('Activity updated');
  });
  const handleDeleteActivity = async (id) => {
    if (!window.confirm('Delete this activity?')) return;
    await deleteActivity(id); loadActivities(selectedProject); showSnack('Activity deleted');
  };

  // Milestone CRUD
  const handleCreateMilestone = () => openForm('New Milestone', MILESTONE_FIELDS, { phase: 'Gate C-D', is_critical: false }, async (vals) => {
    try { await createMilestone({ ...vals, project_id: selectedProject }); closeForm(); loadMilestones(selectedProject); showSnack('Milestone created'); }
    catch (err) { showSnack(err.response?.data?.detail || 'Error', 'error'); }
  });
  const handleEditMilestone = (m) => openForm('Edit Milestone', MILESTONE_FIELDS, m, async (vals) => {
    try { await updateMilestone(m.id, vals); closeForm(); loadMilestones(selectedProject); loadProjects(); showSnack('Milestone updated'); }
    catch (err) { showSnack(err.response?.data?.detail || 'Error', 'error'); }
  });
  const handleDeleteMilestone = async (id) => {
    if (!window.confirm('Delete this milestone?')) return;
    await deleteMilestone(id); loadMilestones(selectedProject); showSnack('Milestone deleted');
  };

  const scheduleKPIs = computeScheduleKPIs(activities);
  const currentProject = projects.find(p => p.id === selectedProject);

  // Gantt-style chart data
  const ganttData = activities.map(a => {
    const today = new Date();
    const startRef = new Date(Math.min(...activities.map(x => new Date(x.planned_start).getTime())));
    const pStart = Math.round((new Date(a.planned_start) - startRef) / 86400000);
    const pDur = Math.max(1, Math.round((new Date(a.planned_finish) - new Date(a.planned_start)) / 86400000));
    const aStart = a.actual_start ? Math.round((new Date(a.actual_start) - startRef) / 86400000) : null;
    const aDur = a.actual_finish && a.actual_start ? Math.max(1, Math.round((new Date(a.actual_finish) - new Date(a.actual_start)) / 86400000)) : a.actual_start ? Math.round((today - new Date(a.actual_start)) / 86400000) : 0;
    return { name: a.activity_name.length > 25 ? a.activity_name.substring(0, 25) + '...' : a.activity_name, pStart, pDur, aStart, aDur, critical: a.is_critical, status: a.status };
  });

  return (
    <Box>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
        <TextField select label="Select Project" value={selectedProject || ''} onChange={e => setSelectedProject(e.target.value)} size="small" sx={{ minWidth: 300 }}>
          <MenuItem value="">All Projects</MenuItem>
          {projects.map(p => <MenuItem key={p.id} value={p.id}>{p.name}</MenuItem>)}
        </TextField>
        {currentProject && (
          <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
            <StatusChip status={currentProject.status} />
            {currentProject.project_manager && <Chip label={currentProject.project_manager} size="small" variant="outlined" />}
          </Box>
        )}
      </Box>

      {/* Schedule Health KPIs (shown when a project is selected) */}
      {selectedProject && activities.length > 0 && (
        <Grid container spacing={2} sx={{ mb: 2 }}>
          <Grid item xs={6} sm={3} md={2}>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color={scheduleKPIs.spi >= 0.95 ? '#2e7d32' : scheduleKPIs.spi >= 0.85 ? '#ed6c02' : '#d32f2f'}>{scheduleKPIs.spi}</Typography>
              <Typography variant="caption" color="text.secondary">SPI</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md={2}>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color="#d32f2f">{scheduleKPIs.delayDays}</Typography>
              <Typography variant="caption" color="text.secondary">Max Delay (days)</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md={2}>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color="#2e7d32">{scheduleKPIs.completed}</Typography>
              <Typography variant="caption" color="text.secondary">Completed</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md={2}>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color="#1976d2">{scheduleKPIs.onTrack}</Typography>
              <Typography variant="caption" color="text.secondary">On Track</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md={2}>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color="#ed6c02">{scheduleKPIs.delayed}</Typography>
              <Typography variant="caption" color="text.secondary">Delayed</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md={2}>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color="#9c27b0">{milestones.filter(m => m.is_critical).length}</Typography>
              <Typography variant="caption" color="text.secondary">Critical Milestones</Typography>
            </CardContent></Card>
          </Grid>
        </Grid>
      )}

      <Tabs value={tab} onChange={(_, v) => { setTab(v); setPage(0); }} sx={{ mb: 2 }}>
        <Tab label="Projects" />
        <Tab label="Activities" disabled={!selectedProject} />
        <Tab label="Milestones" disabled={!selectedProject} />
        <Tab label="Gantt View" disabled={!selectedProject} />
      </Tabs>

      {/* Projects Tab */}
      {tab === 0 && (
        <Paper>
          <Box sx={{ display: 'flex', justifyContent: 'flex-end', p: 2 }}>
            <Button variant="contained" startIcon={<Add />} onClick={handleCreateProject}>New Project</Button>
          </Box>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  {['Code', 'Project Name', 'Client', 'Manager', 'Start', 'End', 'Budget', 'Contract', 'Status', 'Actions'].map(h =>
                    <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                  )}
                </TableRow>
              </TableHead>
              <TableBody>
                {projects.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map(p => (
                  <TableRow key={p.id} hover sx={{ cursor: 'pointer' }} onClick={() => { setSelectedProject(p.id); setTab(1); }}>
                    <TableCell><Typography variant="body2" color="text.secondary">{p.code || '-'}</Typography></TableCell>
                    <TableCell><Typography fontWeight={600}>{p.name}</Typography></TableCell>
                    <TableCell>{p.client}</TableCell>
                    <TableCell>{p.project_manager || '-'}</TableCell>
                    <TableCell>{p.start_date}</TableCell>
                    <TableCell>{p.end_date}</TableCell>
                    <TableCell>£{p.total_budget?.toLocaleString()}</TableCell>
                    <TableCell>£{(p.contract_value || 0).toLocaleString()}</TableCell>
                    <TableCell><StatusChip status={p.status} /></TableCell>
                    <TableCell onClick={e => e.stopPropagation()}>
                      <IconButton size="small" onClick={() => handleEditProject(p)}><Edit fontSize="small" /></IconButton>
                      <IconButton size="small" color="error" onClick={() => handleDeleteProject(p.id)}><Delete fontSize="small" /></IconButton>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          <TablePagination component="div" count={projects.length} page={page} onPageChange={(_, p) => setPage(p)}
            rowsPerPage={rowsPerPage} onRowsPerPageChange={e => { setRowsPerPage(+e.target.value); setPage(0); }} />
        </Paper>
      )}

      {/* Activities Tab */}
      {tab === 1 && selectedProject && (
        <Paper>
          <Box sx={{ display: 'flex', justifyContent: 'flex-end', p: 2 }}>
            <Button variant="contained" startIcon={<Add />} onClick={handleCreateActivity}>New Activity</Button>
          </Box>
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  {['Code', 'Activity', 'Phase', 'P.Start', 'P.Finish', 'A.Start', 'A.Finish', '%', 'Status', 'Delay', 'Critical', 'Actions'].map(h =>
                    <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                  )}
                </TableRow>
              </TableHead>
              <TableBody>
                {activities.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map(a => (
                  <TableRow key={a.id} sx={a.is_critical ? { bgcolor: '#fff3e0' } : {}}>
                    <TableCell><Typography variant="body2" color="text.secondary">{a.activity_code || '-'}</Typography></TableCell>
                    <TableCell>{a.activity_name}</TableCell>
                    <TableCell>{a.phase}</TableCell>
                    <TableCell>{a.planned_start}</TableCell>
                    <TableCell>{a.planned_finish}</TableCell>
                    <TableCell>{a.actual_start || '-'}</TableCell>
                    <TableCell>{a.actual_finish || '-'}</TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, minWidth: 80 }}>
                        <LinearProgress variant="determinate" value={a.completion_pct} sx={{ flex: 1, height: 8, borderRadius: 4 }} />
                        <Typography variant="caption">{a.completion_pct}%</Typography>
                      </Box>
                    </TableCell>
                    <TableCell><StatusChip status={a.status} /></TableCell>
                    <TableCell>{a.delay_days > 0 ? <Typography color="error" fontWeight={600}>{a.delay_days}d</Typography> : '-'}</TableCell>
                    <TableCell>{a.is_critical ? <FlagCircle fontSize="small" color="error" /> : '-'}</TableCell>
                    <TableCell>
                      <IconButton size="small" onClick={() => handleEditActivity(a)}><Edit fontSize="small" /></IconButton>
                      <IconButton size="small" color="error" onClick={() => handleDeleteActivity(a.id)}><Delete fontSize="small" /></IconButton>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          <TablePagination component="div" count={activities.length} page={page} onPageChange={(_, p) => setPage(p)}
            rowsPerPage={rowsPerPage} onRowsPerPageChange={e => { setRowsPerPage(+e.target.value); setPage(0); }} />
        </Paper>
      )}

      {/* Milestones Tab */}
      {tab === 2 && selectedProject && (
        <Box>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
            <Box>
              <Button variant={milestoneView === 'table' ? 'contained' : 'outlined'} size="small" onClick={() => setMilestoneView('table')} sx={{ mr: 1 }}>Table</Button>
              <Button variant={milestoneView === 'timeline' ? 'contained' : 'outlined'} size="small" onClick={() => setMilestoneView('timeline')} startIcon={<TimelineIcon />}>Timeline</Button>
            </Box>
            <Button variant="contained" startIcon={<Add />} onClick={handleCreateMilestone}>New Milestone</Button>
          </Box>
          {milestoneView === 'table' ? (
            <Paper>
              <TableContainer>
                <Table size="small">
                  <TableHead><TableRow>
                    {['Milestone', 'Phase', 'Planned', 'Actual', 'Status', 'Delay', 'Critical', 'Actions'].map(h =>
                      <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                    )}
                  </TableRow></TableHead>
                  <TableBody>
                    {milestones.map(m => (
                      <TableRow key={m.id} sx={m.is_critical ? { bgcolor: '#fff3e0' } : {}}>
                        <TableCell><Typography fontWeight={m.is_critical ? 700 : 400}>{m.name}</Typography></TableCell>
                        <TableCell>{m.phase}</TableCell>
                        <TableCell>{m.planned_date}</TableCell>
                        <TableCell>{m.actual_date || '-'}</TableCell>
                        <TableCell><StatusChip status={m.status} /></TableCell>
                        <TableCell>{m.delay_days > 0 ? <Typography color="error" fontWeight={600}>{m.delay_days}d</Typography> : '-'}</TableCell>
                        <TableCell>{m.is_critical ? <Flag color="error" /> : '-'}</TableCell>
                        <TableCell>
                          <IconButton size="small" onClick={() => handleEditMilestone(m)}><Edit fontSize="small" /></IconButton>
                          <IconButton size="small" color="error" onClick={() => handleDeleteMilestone(m.id)}><Delete fontSize="small" /></IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </Paper>
          ) : (
            <Paper sx={{ p: 3, height: 400 }}>
              <Typography variant="subtitle1" fontWeight={600} mb={2}>Milestone Timeline</Typography>
              <ResponsiveContainer width="100%" height="85%">
                <BarChart data={milestones.map(m => ({
                  name: m.name.length > 20 ? m.name.substring(0, 20) + '...' : m.name,
                  'Planned (days)': Math.round((new Date(m.planned_date) - new Date()) / 86400000),
                  'Actual (days)': m.actual_date ? Math.round((new Date(m.actual_date) - new Date()) / 86400000) : null,
                }))} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" label={{ value: 'Days from Today', position: 'insideBottom', offset: -5 }} />
                  <YAxis dataKey="name" type="category" width={160} tick={{ fontSize: 11 }} />
                  <RTooltip />
                  <ReferenceLine x={0} stroke="#666" strokeDasharray="3 3" label="Today" />
                  <Bar dataKey="Planned (days)" fill="#90caf9" radius={[0, 4, 4, 0]} />
                  <Bar dataKey="Actual (days)" fill="#ffcc80" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </Paper>
          )}
        </Box>
      )}

      {/* Gantt Tab */}
      {tab === 3 && selectedProject && (
        <Paper sx={{ p: 3 }}>
          <Typography variant="subtitle1" fontWeight={600} mb={2}>Gantt Chart - Activity Schedule</Typography>
          {ganttData.length > 0 ? (
            <ResponsiveContainer width="100%" height={Math.max(300, ganttData.length * 35 + 60)}>
              <BarChart data={ganttData} layout="vertical" barSize={14}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" label={{ value: 'Days from Start', position: 'insideBottom', offset: -5 }} />
                <YAxis dataKey="name" type="category" width={200} tick={{ fontSize: 11 }} />
                <RTooltip />
                <Bar dataKey="pStart" stackId="planned" fill="transparent" />
                <Bar dataKey="pDur" stackId="planned" fill="#90caf9" radius={[0, 4, 4, 0]} name="Planned Duration" />
              </BarChart>
            </ResponsiveContainer>
          ) : <Typography color="text.secondary">No activities to display</Typography>}
        </Paper>
      )}

      <FormDialog open={dialog.open} onClose={closeForm} onSubmit={dialog.onSubmit}
        title={dialog.title} fields={dialog.fields} values={dialog.values} onChange={handleChange} />
      <Snackbar open={snack.open} autoHideDuration={3000} onClose={() => setSnack({ ...snack, open: false })}>
        <Alert severity={snack.severity} onClose={() => setSnack({ ...snack, open: false })}>{snack.message}</Alert>
      </Snackbar>
    </Box>
  );
}
