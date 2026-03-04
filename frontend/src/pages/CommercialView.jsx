import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Button, Tab, Tabs, Paper, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, TablePagination, IconButton, Typography,
  Alert, Snackbar, Grid, Card, CardContent, Chip,
} from '@mui/material';
import { Add, Edit, Delete } from '@mui/icons-material';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip as RTooltip,
  ResponsiveContainer, Legend,
} from 'recharts';
import {
  getCBS, createCBS, updateCBS, deleteCBS,
  getVariations, createVariation, updateVariation, deleteVariation,
  getCompensationEvents, createCompensationEvent, updateCompensationEvent, deleteCompensationEvent,
  getMilestones, getPayments, createPayment, updatePayment, deletePayment,
} from '../services/api';
import StatusChip from '../components/StatusChip';
import FormDialog from '../components/FormDialog';
import { useProject } from '../context/ProjectContext';

const CBS_FIELDS = [
  { name: 'wbs_code', label: 'WBS Code', required: true },
  { name: 'description', label: 'Description', required: true },
  { name: 'budget_cost', label: 'Budget Cost (£)', type: 'number', required: true },
  { name: 'actual_cost', label: 'Actual Cost (£)', type: 'number' },
  { name: 'forecast_cost', label: 'Forecast Cost (£)', type: 'number' },
  { name: 'approved_variation', label: 'Approved Variation (£)', type: 'number' },
];

const VARIATION_FIELDS = [
  { name: 'variation_code', label: 'Variation Code', required: true },
  { name: 'description', label: 'Description', required: true },
  { name: 'value', label: 'Value (£)', type: 'number', required: true },
  { name: 'cost_impact', label: 'Cost Impact (£)', type: 'number' },
  { name: 'schedule_impact_days', label: 'Schedule Impact (Days)', type: 'number' },
  { name: 'approval_status', label: 'Status', type: 'select', options: ['Pending', 'Under Review', 'Approved', 'Rejected'] },
  { name: 'submitted_date', label: 'Submitted Date', type: 'date' },
  { name: 'approval_date', label: 'Approval Date', type: 'date' },
  { name: 'approved_by', label: 'Approved By' },
];

const CE_FIELDS = [
  { name: 'event_name', label: 'Event Name', required: true },
  { name: 'linked_wbs', label: 'Linked WBS' },
  { name: 'time_impact_days', label: 'Time Impact (Days)', type: 'number', required: true },
  { name: 'daily_overhead_cost', label: 'Daily Overhead Cost (£)', type: 'number', required: true },
  { name: 'status', label: 'Status', type: 'select', options: ['Pending', 'Approved', 'Rejected'] },
];

const PAYMENT_FIELDS = [
  { name: 'payment_percentage', label: 'Payment %', type: 'number', required: true },
  { name: 'payment_value', label: 'Payment Value (£)', type: 'number', required: true },
  { name: 'invoice_number', label: 'Invoice Number' },
  { name: 'invoice_date', label: 'Invoice Date', type: 'date' },
  { name: 'payment_status', label: 'Status', type: 'select', options: ['Pending', 'Received'] },
];

export default function CommercialView() {
  const { selectedProjectId: selectedProject, selectedProject: proj } = useProject();
  const [tab, setTab] = useState(0);
  const [cbsItems, setCbsItems] = useState([]);
  const [variations, setVariations] = useState([]);
  const [ceItems, setCeItems] = useState([]);
  const [milestones, setMilestones] = useState([]);
  const [payments, setPayments] = useState([]);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [dialog, setDialog] = useState({ open: false, title: '', fields: [], values: {}, onSubmit: null });
  const [snack, setSnack] = useState({ open: false, message: '', severity: 'success' });

  const showSnack = (message, severity = 'success') => setSnack({ open: true, message, severity });

  const loadData = useCallback(async (pid) => {
    try {
      const [cbsRes, varRes, ceRes, msRes] = await Promise.all([
        getCBS(pid), getVariations(pid), getCompensationEvents(pid), getMilestones(pid),
      ]);
      setCbsItems(cbsRes.data);
      setVariations(varRes.data);
      setCeItems(ceRes.data);
      setMilestones(msRes.data);
      const allPayments = [];
      for (const ms of msRes.data) {
        const pRes = await getPayments(ms.id);
        allPayments.push(...pRes.data.map(p => ({ ...p, milestone_name: ms.name, milestone_status: ms.status, milestone_delay: ms.delay_days })));
      }
      setPayments(allPayments);
    } catch { /* */ }
  }, []);

  useEffect(() => { if (selectedProject) loadData(selectedProject); }, [selectedProject, loadData]);

  const openForm = (title, fields, values, onSubmit) => setDialog({ open: true, title, fields, values: { ...values }, onSubmit });
  const closeForm = () => setDialog({ ...dialog, open: false });
  const handleChange = (name, value) => setDialog(d => ({ ...d, values: { ...d.values, [name]: value } }));

  const totalBudget = cbsItems.reduce((s, c) => s + (c.budget_cost || 0), 0);
  const totalActual = cbsItems.reduce((s, c) => s + (c.actual_cost || 0), 0);
  const totalForecast = cbsItems.reduce((s, c) => s + (c.forecast_cost || 0), 0);
  const totalVariance = cbsItems.reduce((s, c) => s + (c.variance || 0), 0);
  const contractValue = proj?.contract_value || 0;
  const approvedVarTotal = variations.filter(v => v.approval_status === 'Approved').reduce((s, v) => s + v.value, 0);
  const marginPct = contractValue > 0 ? ((contractValue + approvedVarTotal - totalActual) / (contractValue + approvedVarTotal) * 100).toFixed(1) : 0;
  const cpi = totalActual > 0 ? (totalBudget / totalActual).toFixed(2) : '1.00';

  return (
    <Box>
      {!selectedProject ? (
        <Paper sx={{ p: 4, textAlign: 'center' }}><Typography color="text.secondary">Select a project from the bar above to view commercial data</Typography></Paper>
      ) : (
        <>
          {/* Summary Cards */}
          <Grid container spacing={2} sx={{ mb: 2 }}>
            {[
              { label: 'Contract Value', val: `£${contractValue.toLocaleString()}`, color: '#1976d2' },
              { label: 'Original Budget', val: `£${totalBudget.toLocaleString()}`, color: '#1976d2' },
              { label: 'Actual Cost', val: `£${totalActual.toLocaleString()}`, color: '#ed6c02' },
              { label: 'Forecast', val: `£${totalForecast.toLocaleString()}`, color: '#9c27b0' },
              { label: 'Variance', val: `£${totalVariance.toLocaleString()}`, color: totalVariance >= 0 ? '#2e7d32' : '#d32f2f' },
              { label: 'Margin', val: `${marginPct}%`, color: marginPct >= 10 ? '#2e7d32' : '#ed6c02' },
              { label: 'CPI', val: cpi, color: cpi >= 0.95 ? '#2e7d32' : '#d32f2f' },
            ].map((s, i) => (
              <Grid item xs={6} sm={3} md={1.5} key={i}>
                <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
                  <Typography variant="h6" fontWeight={700} sx={{ color: s.color }}>{s.val}</Typography>
                  <Typography variant="caption" color="text.secondary">{s.label}</Typography>
                </CardContent></Card>
              </Grid>
            ))}
          </Grid>

          <Tabs value={tab} onChange={(_, v) => { setTab(v); setPage(0); }} sx={{ mb: 2 }}>
            <Tab label="CBS" />
            <Tab label={`Variations (${variations.length})`} />
            <Tab label="Compensation Events" />
            <Tab label="Payments" />
          </Tabs>

          {/* CBS Tab */}
          {tab === 0 && (
            <>
              <Paper sx={{ mb: 3 }}>
                <Box sx={{ display: 'flex', justifyContent: 'flex-end', p: 2 }}>
                  <Button variant="contained" startIcon={<Add />} onClick={() =>
                    openForm('New CBS Item', CBS_FIELDS, { budget_cost: 0, actual_cost: 0, forecast_cost: 0, approved_variation: 0 }, async (vals) => {
                      await createCBS({ ...vals, project_id: selectedProject }); closeForm(); loadData(selectedProject); showSnack('CBS item created');
                    })}>New CBS Item</Button>
                </Box>
                <TableContainer>
                  <Table size="small">
                    <TableHead><TableRow>
                      {['WBS', 'Description', 'Budget', 'Actual', 'Forecast', 'Variation', 'Variance', 'Actions'].map(h =>
                        <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                      )}
                    </TableRow></TableHead>
                    <TableBody>
                      {cbsItems.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map(c => (
                        <TableRow key={c.id}>
                          <TableCell><Typography fontWeight={600}>{c.wbs_code}</Typography></TableCell>
                          <TableCell>{c.description}</TableCell>
                          <TableCell align="right">£{c.budget_cost?.toLocaleString()}</TableCell>
                          <TableCell align="right">£{c.actual_cost?.toLocaleString()}</TableCell>
                          <TableCell align="right">£{(c.forecast_cost || 0).toLocaleString()}</TableCell>
                          <TableCell align="right">£{c.approved_variation?.toLocaleString()}</TableCell>
                          <TableCell align="right">
                            <Typography color={c.variance >= 0 ? 'success.main' : 'error.main'} fontWeight={600}>£{c.variance?.toLocaleString()}</Typography>
                          </TableCell>
                          <TableCell align="right">
                            <IconButton size="small" onClick={() => openForm('Edit CBS', CBS_FIELDS, c, async (vals) => {
                              await updateCBS(c.id, vals); closeForm(); loadData(selectedProject); showSnack('Updated');
                            })}><Edit fontSize="small" /></IconButton>
                            <IconButton size="small" color="error" onClick={async () => {
                              if (!window.confirm('Delete?')) return; await deleteCBS(c.id); loadData(selectedProject);
                            }}><Delete fontSize="small" /></IconButton>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </TableContainer>
                <TablePagination component="div" count={cbsItems.length} page={page} onPageChange={(_, p) => setPage(p)}
                  rowsPerPage={rowsPerPage} onRowsPerPageChange={e => { setRowsPerPage(+e.target.value); setPage(0); }} />
              </Paper>
              <Paper sx={{ p: 3, height: 350 }}>
                <Typography variant="subtitle1" fontWeight={600} mb={2}>Cost Breakdown</Typography>
                <ResponsiveContainer width="100%" height="85%">
                  <BarChart data={cbsItems.map(c => ({ name: c.wbs_code, Budget: c.budget_cost, Actual: c.actual_cost, Forecast: c.forecast_cost || 0 }))}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="name" />
                    <YAxis tickFormatter={v => `£${(v / 1000).toFixed(0)}K`} />
                    <RTooltip formatter={v => `£${v.toLocaleString()}`} />
                    <Legend />
                    <Bar dataKey="Budget" fill="#90caf9" radius={[4,4,0,0]} />
                    <Bar dataKey="Actual" fill="#ffcc80" radius={[4,4,0,0]} />
                    <Bar dataKey="Forecast" fill="#ce93d8" radius={[4,4,0,0]} />
                  </BarChart>
                </ResponsiveContainer>
              </Paper>
            </>
          )}

          {/* Variations Tab */}
          {tab === 1 && (
            <Paper>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2 }}>
                <Box>
                  <Chip label={`Approved: £${approvedVarTotal.toLocaleString()}`} color="success" variant="outlined" sx={{ mr: 1 }} />
                  <Chip label={`Pending: ${variations.filter(v => v.approval_status === 'Pending').length}`} color="warning" variant="outlined" />
                </Box>
                <Button variant="contained" startIcon={<Add />} onClick={() =>
                  openForm('New Variation', VARIATION_FIELDS, { value: 0, cost_impact: 0, schedule_impact_days: 0, approval_status: 'Pending' }, async (vals) => {
                    await createVariation({ ...vals, project_id: selectedProject }); closeForm(); loadData(selectedProject); showSnack('Variation created');
                  })}>New Variation</Button>
              </Box>
              <TableContainer>
                <Table size="small">
                  <TableHead><TableRow>
                    {['Code', 'Description', 'Value (£)', 'Cost Impact', 'Schedule (days)', 'Status', 'Approval Date', 'Approved By', 'Actions'].map(h =>
                      <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                    )}
                  </TableRow></TableHead>
                  <TableBody>
                    {variations.map(v => (
                      <TableRow key={v.id}>
                        <TableCell><Typography fontWeight={600}>{v.variation_code}</Typography></TableCell>
                        <TableCell>{v.description}</TableCell>
                        <TableCell align="right">£{v.value?.toLocaleString()}</TableCell>
                        <TableCell align="right">£{(v.cost_impact || 0).toLocaleString()}</TableCell>
                        <TableCell align="right">{v.schedule_impact_days || 0}</TableCell>
                        <TableCell>
                          <Chip label={v.approval_status} size="small"
                            color={v.approval_status === 'Approved' ? 'success' : v.approval_status === 'Rejected' ? 'error' : 'warning'} variant="outlined" />
                        </TableCell>
                        <TableCell>{v.approval_date || '-'}</TableCell>
                        <TableCell>{v.approved_by || '-'}</TableCell>
                        <TableCell>
                          <IconButton size="small" onClick={() => openForm('Edit Variation', VARIATION_FIELDS, v, async (vals) => {
                            await updateVariation(v.id, vals); closeForm(); loadData(selectedProject); showSnack('Updated');
                          })}><Edit fontSize="small" /></IconButton>
                          <IconButton size="small" color="error" onClick={async () => {
                            if (!window.confirm('Delete?')) return; await deleteVariation(v.id); loadData(selectedProject);
                          }}><Delete fontSize="small" /></IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </Paper>
          )}

          {/* Compensation Events Tab */}
          {tab === 2 && (
            <Paper>
              <Box sx={{ display: 'flex', justifyContent: 'flex-end', p: 2 }}>
                <Button variant="contained" startIcon={<Add />} onClick={() =>
                  openForm('New Event', CE_FIELDS, { time_impact_days: 0, daily_overhead_cost: 0, status: 'Pending' }, async (vals) => {
                    await createCompensationEvent({ ...vals, project_id: selectedProject }); closeForm(); loadData(selectedProject); showSnack('Created');
                  })}>New Event</Button>
              </Box>
              <TableContainer>
                <Table size="small">
                  <TableHead><TableRow>
                    {['Event', 'Linked WBS', 'Time Impact', 'Daily Overhead', 'Cost Impact', 'Status', 'Actions'].map(h =>
                      <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                    )}
                  </TableRow></TableHead>
                  <TableBody>
                    {ceItems.map(ce => (
                      <TableRow key={ce.id}>
                        <TableCell>{ce.event_name}</TableCell>
                        <TableCell>{ce.linked_wbs || '-'}</TableCell>
                        <TableCell align="right">{ce.time_impact_days} days</TableCell>
                        <TableCell align="right">£{ce.daily_overhead_cost?.toLocaleString()}</TableCell>
                        <TableCell align="right"><Typography fontWeight={600} color="error.main">£{ce.cost_impact?.toLocaleString()}</Typography></TableCell>
                        <TableCell><StatusChip status={ce.status} /></TableCell>
                        <TableCell>
                          <IconButton size="small" onClick={() => openForm('Edit Event', CE_FIELDS, ce, async (vals) => {
                            await updateCompensationEvent(ce.id, vals); closeForm(); loadData(selectedProject); showSnack('Updated');
                          })}><Edit fontSize="small" /></IconButton>
                          <IconButton size="small" color="error" onClick={async () => {
                            if (!window.confirm('Delete?')) return; await deleteCompensationEvent(ce.id); loadData(selectedProject);
                          }}><Delete fontSize="small" /></IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </Paper>
          )}

          {/* Payments Tab */}
          {tab === 3 && (
            <Paper>
              <Box sx={{ display: 'flex', justifyContent: 'flex-end', p: 2 }}>
                <Button variant="contained" startIcon={<Add />} onClick={() => {
                  const payFields = [
                    { name: 'milestone_id', label: 'Milestone ID', type: 'select', options: milestones.map(m => `${m.id}`), required: true },
                    ...PAYMENT_FIELDS,
                  ];
                  openForm('New Payment', payFields, { payment_percentage: 0, payment_value: 0, payment_status: 'Pending' }, async (vals) => {
                    await createPayment({ ...vals, milestone_id: parseInt(vals.milestone_id) }); closeForm(); loadData(selectedProject); showSnack('Created');
                  });
                }}>New Payment</Button>
              </Box>
              <TableContainer>
                <Table size="small">
                  <TableHead><TableRow>
                    {['Milestone', 'Status', '%', 'Value', 'Invoice', 'Date', 'Payment Status', 'Delay', 'Actions'].map(h =>
                      <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                    )}
                  </TableRow></TableHead>
                  <TableBody>
                    {payments.map(p => (
                      <TableRow key={p.id}>
                        <TableCell>{p.milestone_name}</TableCell>
                        <TableCell><StatusChip status={p.milestone_status} /></TableCell>
                        <TableCell>{p.payment_percentage}%</TableCell>
                        <TableCell align="right">£{p.payment_value?.toLocaleString()}</TableCell>
                        <TableCell>{p.invoice_number || '-'}</TableCell>
                        <TableCell>{p.invoice_date || '-'}</TableCell>
                        <TableCell><StatusChip status={p.payment_status} /></TableCell>
                        <TableCell>{p.milestone_delay > 0 ? <Typography color="error" variant="body2">{p.milestone_delay}d</Typography> : 'On track'}</TableCell>
                        <TableCell>
                          <IconButton size="small" onClick={() => openForm('Edit Payment', PAYMENT_FIELDS, p, async (vals) => {
                            await updatePayment(p.id, vals); closeForm(); loadData(selectedProject); showSnack('Updated');
                          })}><Edit fontSize="small" /></IconButton>
                          <IconButton size="small" color="error" onClick={async () => {
                            if (!window.confirm('Delete?')) return; await deletePayment(p.id); loadData(selectedProject);
                          }}><Delete fontSize="small" /></IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </Paper>
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
