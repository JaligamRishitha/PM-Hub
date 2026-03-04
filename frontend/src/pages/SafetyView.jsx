import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Button, Tab, Tabs, Paper, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, TablePagination, IconButton, Typography,
  Alert, Snackbar, Grid, Card, CardContent, Chip,
} from '@mui/material';
import { Add, Edit, Delete, CheckCircle, RadioButtonUnchecked } from '@mui/icons-material';
import {
  PieChart, Pie, Cell, ResponsiveContainer, Tooltip as RTooltip, Legend,
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
} from 'recharts';
import {
  getSafetyIncidents, createSafetyIncident, updateSafetyIncident,
  deleteSafetyIncident, getHSEChecklist, createHSEItem, updateHSEItem, deleteHSEItem,
} from '../services/api';
import StatusChip from '../components/StatusChip';
import FormDialog from '../components/FormDialog';
import { useProject } from '../context/ProjectContext';

const INCIDENT_FIELDS = [
  { name: 'incident_type', label: 'Type', type: 'select', options: ['Injury', 'Near Miss', 'Observation', 'Environmental'], required: true },
  { name: 'severity', label: 'Severity', type: 'select', options: ['Minor', 'Moderate', 'Major', 'Critical'], required: true },
  { name: 'reported_date', label: 'Reported Date', type: 'date', required: true },
  { name: 'resolved_date', label: 'Resolved Date', type: 'date' },
  { name: 'status', label: 'Status', type: 'select', options: ['Open', 'Under Investigation', 'Resolved', 'Closed'] },
  { name: 'penalty_cost', label: 'Penalty Cost (£)', type: 'number' },
  { name: 'lost_time_hours', label: 'Lost Time (hours)', type: 'number' },
  { name: 'location', label: 'Location' },
  { name: 'reported_by', label: 'Reported By' },
  { name: 'description', label: 'Description' },
];

const HSE_FIELDS = [
  { name: 'checklist_item', label: 'Checklist Item', required: true },
  { name: 'category', label: 'Category' },
  { name: 'status', label: 'Status', type: 'select', options: ['Pending', 'In Progress', 'Completed', 'Failed'] },
  { name: 'last_inspection_date', label: 'Last Inspection Date', type: 'date' },
  { name: 'inspector', label: 'Inspector' },
  { name: 'notes', label: 'Notes' },
];

const SEVERITY_COLORS = { Minor: '#a5d6a7', Moderate: '#ffcc80', Major: '#ef9a9a', Critical: '#e57373' };
const TYPE_COLORS = { Injury: '#ef9a9a', 'Near Miss': '#ffcc80', Observation: '#90caf9', Environmental: '#a5d6a7' };

export default function SafetyView() {
  const { selectedProjectId: selectedProject } = useProject();
  const [tab, setTab] = useState(0);
  const [incidents, setIncidents] = useState([]);
  const [checklist, setChecklist] = useState([]);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [dialog, setDialog] = useState({ open: false, title: '', fields: [], values: {}, onSubmit: null });
  const [snack, setSnack] = useState({ open: false, message: '', severity: 'success' });

  const showSnack = (message, severity = 'success') => setSnack({ open: true, message, severity });
  const loadData = useCallback(async (pid) => {
    try {
      const [iRes, hRes] = await Promise.all([getSafetyIncidents(pid), getHSEChecklist(pid)]);
      setIncidents(iRes.data);
      setChecklist(hRes.data);
    } catch { /* */ }
  }, []);

  useEffect(() => { if (selectedProject) loadData(selectedProject); }, [selectedProject, loadData]);

  const openForm = (title, fields, values, onSubmit) => setDialog({ open: true, title, fields, values: { ...values }, onSubmit });
  const closeForm = () => setDialog({ ...dialog, open: false });
  const handleChange = (name, value) => setDialog(d => ({ ...d, values: { ...d.values, [name]: value } }));

  const openCount = incidents.filter(i => i.status === 'Open' || i.status === 'Under Investigation').length;
  const resolvedCount = incidents.filter(i => i.status === 'Resolved' || i.status === 'Closed').length;
  const totalPenalty = incidents.reduce((s, i) => s + (i.penalty_cost || 0), 0);
  const totalLostTime = incidents.reduce((s, i) => s + (i.lost_time_hours || 0), 0);
  const completedChecks = checklist.filter(c => c.status === 'Completed').length;
  const totalChecks = checklist.length;

  // LTIFR = (Lost Time Injuries x 1,000,000) / Total Hours Worked (assume 200,000 hrs for demo)
  const ltiCount = incidents.filter(i => (i.lost_time_hours || 0) > 0).length;
  const ltifr = (ltiCount * 1000000 / 200000).toFixed(1);

  // Severity breakdown
  const severityData = ['Minor', 'Moderate', 'Major', 'Critical'].map(s => ({
    name: s, value: incidents.filter(i => i.severity === s).length,
  })).filter(d => d.value > 0);

  // Type breakdown
  const typeData = ['Injury', 'Near Miss', 'Observation', 'Environmental'].map(t => ({
    name: t, value: incidents.filter(i => i.incident_type === t).length,
  })).filter(d => d.value > 0);

  // Monthly trend
  const monthlyTrend = {};
  incidents.forEach(i => {
    const month = i.reported_date?.substring(0, 7);
    if (month) {
      if (!monthlyTrend[month]) monthlyTrend[month] = { month, incidents: 0, nearMisses: 0 };
      if (i.incident_type === 'Near Miss') monthlyTrend[month].nearMisses++;
      else monthlyTrend[month].incidents++;
    }
  });
  const trendData = Object.values(monthlyTrend).sort((a, b) => a.month.localeCompare(b.month));

  return (
    <Box>
      {!selectedProject ? (
        <Paper sx={{ p: 4, textAlign: 'center' }}><Typography color="text.secondary">Select a project from the bar above to view Health & Safety data</Typography></Paper>
      ) : (
        <>
          {/* KPI Cards */}
          <Grid container spacing={2} sx={{ mb: 2 }}>
            {[
              { label: 'Open Incidents', val: openCount, color: '#d32f2f' },
              { label: 'Resolved', val: resolvedCount, color: '#2e7d32' },
              { label: 'Total Penalties', val: `£${totalPenalty.toLocaleString()}`, color: '#ed6c02' },
              { label: 'Lost Time (hrs)', val: totalLostTime, color: '#9c27b0' },
              { label: 'LTIFR', val: ltifr, color: parseFloat(ltifr) > 3 ? '#d32f2f' : '#2e7d32' },
              { label: 'HSE Checklist', val: `${completedChecks}/${totalChecks}`, color: '#1976d2' },
            ].map((s, i) => (
              <Grid item xs={6} sm={4} md={2} key={i}>
                <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
                  <Typography variant="h5" fontWeight={700} sx={{ color: s.color }}>{s.val}</Typography>
                  <Typography variant="caption" color="text.secondary">{s.label}</Typography>
                </CardContent></Card>
              </Grid>
            ))}
          </Grid>

          <Tabs value={tab} onChange={(_, v) => { setTab(v); setPage(0); }} sx={{ mb: 2 }}>
            <Tab label="Incidents" />
            <Tab label="HSE Checklist" />
            <Tab label="Analytics" />
          </Tabs>

          {/* Incidents Tab */}
          {tab === 0 && (
            <Paper>
              <Box sx={{ display: 'flex', justifyContent: 'flex-end', p: 2 }}>
                <Button variant="contained" startIcon={<Add />} onClick={() =>
                  openForm('Report Incident', INCIDENT_FIELDS, { incident_type: 'Observation', severity: 'Minor', status: 'Open', penalty_cost: 0, lost_time_hours: 0, reported_date: new Date().toISOString().split('T')[0] }, async (vals) => {
                    await createSafetyIncident({ ...vals, project_id: selectedProject }); closeForm(); loadData(selectedProject); showSnack('Incident reported');
                  })}>Report Incident</Button>
              </Box>
              <TableContainer>
                <Table size="small">
                  <TableHead><TableRow>
                    {['Type', 'Severity', 'Reported', 'Resolved', 'Location', 'Status', 'Lost Time', 'Penalty', 'Actions'].map(h =>
                      <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                    )}
                  </TableRow></TableHead>
                  <TableBody>
                    {incidents.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map(i => (
                      <TableRow key={i.id}>
                        <TableCell><Chip label={i.incident_type} size="small" sx={{ bgcolor: (TYPE_COLORS[i.incident_type] || '#999') + '20', color: TYPE_COLORS[i.incident_type] || '#999', fontWeight: 600 }} /></TableCell>
                        <TableCell><Chip label={i.severity} size="small" sx={{ bgcolor: (SEVERITY_COLORS[i.severity] || '#999') + '20', color: SEVERITY_COLORS[i.severity] || '#999', fontWeight: 600 }} /></TableCell>
                        <TableCell>{i.reported_date}</TableCell>
                        <TableCell>{i.resolved_date || '-'}</TableCell>
                        <TableCell>{i.location || '-'}</TableCell>
                        <TableCell><StatusChip status={i.status} /></TableCell>
                        <TableCell>{i.lost_time_hours || 0}h</TableCell>
                        <TableCell align="right">£{(i.penalty_cost || 0).toLocaleString()}</TableCell>
                        <TableCell>
                          <IconButton size="small" onClick={() => openForm('Edit Incident', INCIDENT_FIELDS, i, async (vals) => {
                            await updateSafetyIncident(i.id, vals); closeForm(); loadData(selectedProject); showSnack('Updated');
                          })}><Edit fontSize="small" /></IconButton>
                          <IconButton size="small" color="error" onClick={async () => {
                            if (!window.confirm('Delete?')) return; await deleteSafetyIncident(i.id); loadData(selectedProject);
                          }}><Delete fontSize="small" /></IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
              <TablePagination component="div" count={incidents.length} page={page} onPageChange={(_, p) => setPage(p)}
                rowsPerPage={rowsPerPage} onRowsPerPageChange={e => { setRowsPerPage(+e.target.value); setPage(0); }} />
            </Paper>
          )}

          {/* HSE Checklist Tab */}
          {tab === 1 && (
            <Paper>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2 }}>
                <Box>
                  <Chip label={`${completedChecks} of ${totalChecks} completed`} color={completedChecks === totalChecks && totalChecks > 0 ? 'success' : 'warning'} />
                  {completedChecks < totalChecks && (
                    <Typography variant="caption" color="error" sx={{ ml: 2 }}>
                      Mechanical Completion milestone cannot be closed until all items are completed
                    </Typography>
                  )}
                </Box>
                <Button variant="contained" startIcon={<Add />} onClick={() =>
                  openForm('New Checklist Item', HSE_FIELDS, { status: 'Pending' }, async (vals) => {
                    await createHSEItem({ ...vals, project_id: selectedProject }); closeForm(); loadData(selectedProject); showSnack('Created');
                  })}>Add Item</Button>
              </Box>
              <TableContainer>
                <Table size="small">
                  <TableHead><TableRow>
                    {['', 'Item', 'Category', 'Status', 'Inspector', 'Last Inspection', 'Actions'].map(h =>
                      <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                    )}
                  </TableRow></TableHead>
                  <TableBody>
                    {checklist.map(c => (
                      <TableRow key={c.id}>
                        <TableCell width={40}>{c.status === 'Completed' ? <CheckCircle color="success" fontSize="small" /> : <RadioButtonUnchecked color="disabled" fontSize="small" />}</TableCell>
                        <TableCell>{c.checklist_item}</TableCell>
                        <TableCell>{c.category || '-'}</TableCell>
                        <TableCell><StatusChip status={c.status} /></TableCell>
                        <TableCell>{c.inspector || '-'}</TableCell>
                        <TableCell>{c.last_inspection_date || '-'}</TableCell>
                        <TableCell>
                          <IconButton size="small" onClick={() => openForm('Edit Item', HSE_FIELDS, c, async (vals) => {
                            await updateHSEItem(c.id, vals); closeForm(); loadData(selectedProject); showSnack('Updated');
                          })}><Edit fontSize="small" /></IconButton>
                          <IconButton size="small" color="error" onClick={async () => {
                            if (!window.confirm('Delete?')) return; await deleteHSEItem(c.id); loadData(selectedProject);
                          }}><Delete fontSize="small" /></IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </Paper>
          )}

          {/* Analytics Tab */}
          {tab === 2 && (
            <Grid container spacing={3}>
              <Grid item xs={12} md={7}>
                <Paper sx={{ p: 3, height: 350 }}>
                  <Typography variant="subtitle1" fontWeight={600} mb={2}>Monthly Incident Trend</Typography>
                  <ResponsiveContainer width="100%" height="85%">
                    <BarChart data={trendData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="month" tick={{ fontSize: 11 }} />
                      <YAxis allowDecimals={false} />
                      <RTooltip />
                      <Legend />
                      <Bar dataKey="incidents" name="Incidents" fill="#ef9a9a" radius={[4,4,0,0]} />
                      <Bar dataKey="nearMisses" name="Near Misses" fill="#ffcc80" radius={[4,4,0,0]} />
                    </BarChart>
                  </ResponsiveContainer>
                </Paper>
              </Grid>
              <Grid item xs={12} md={5}>
                <Grid container spacing={2}>
                  <Grid item xs={12}>
                    <Paper sx={{ p: 3, height: 170 }}>
                      <Typography variant="subtitle1" fontWeight={600} mb={1}>Severity Breakdown</Typography>
                      <ResponsiveContainer width="100%" height="80%">
                        <PieChart>
                          <Pie data={severityData} cx="50%" cy="50%" innerRadius={30} outerRadius={55} dataKey="value" paddingAngle={3}>
                            {severityData.map((d, i) => <Cell key={i} fill={SEVERITY_COLORS[d.name] || '#999'} />)}
                          </Pie>
                          <RTooltip /><Legend />
                        </PieChart>
                      </ResponsiveContainer>
                    </Paper>
                  </Grid>
                  <Grid item xs={12}>
                    <Paper sx={{ p: 3, height: 170 }}>
                      <Typography variant="subtitle1" fontWeight={600} mb={1}>Incident Types</Typography>
                      <ResponsiveContainer width="100%" height="80%">
                        <PieChart>
                          <Pie data={typeData} cx="50%" cy="50%" innerRadius={30} outerRadius={55} dataKey="value" paddingAngle={3}>
                            {typeData.map((d, i) => <Cell key={i} fill={TYPE_COLORS[d.name] || '#999'} />)}
                          </Pie>
                          <RTooltip /><Legend />
                        </PieChart>
                      </ResponsiveContainer>
                    </Paper>
                  </Grid>
                </Grid>
              </Grid>
            </Grid>
          )}
        </>
      )}

      <FormDialog open={dialog.open} onClose={closeForm} onSubmit={dialog.onSubmit}
        title={dialog.title} fields={dialog.fields} values={dialog.values} onChange={handleChange} />
      <Snackbar open={snack.open} autoHideDuration={3000} onClose={() => setSnack({ ...snack, open: false })}>
        <Alert severity={snack.severity} onClose={() => setSnack({ ...snack, open: false })}>{snack.message}</Alert>
      </Snackbar>
    </Box>
  );
}
