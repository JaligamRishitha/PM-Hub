import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Button, Tab, Tabs, Paper, Typography, MenuItem, TextField, Grid, Card,
  CardContent, Alert, Snackbar, Chip, Stack, CircularProgress,
} from '@mui/material';
import { Science, PlayArrow, Check, Close, TrendingDown, TrendingUp } from '@mui/icons-material';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip as RTooltip, Legend,
  ResponsiveContainer, LineChart, Line, ReferenceLine, Cell,
  ComposedChart, Area, Label,
} from 'recharts';
import {
  getProjects, getMilestones, getActivities,
  startSimulation, runSimulation, applySimulation, discardSimulation,
} from '../services/api';

function CompareCard({ label, before, after, prefix = '£', inverse = false }) {
  const diff = after - before;
  const isPositive = inverse ? diff < 0 : diff > 0;
  const isBad = inverse ? diff > 0 : diff < 0;
  return (
    <Card sx={{ height: '100%' }}>
      <CardContent>
        <Typography variant="body2" color="text.secondary" gutterBottom>{label}</Typography>
        <Stack direction="row" spacing={2} alignItems="baseline">
          <Typography variant="body2" color="text.secondary" sx={{ textDecoration: 'line-through' }}>
            {prefix}{typeof before === 'number' ? before.toLocaleString() : before}
          </Typography>
          <Typography variant="h5" fontWeight={700} color={isBad ? 'error.main' : isPositive ? 'success.main' : 'text.primary'}>
            {prefix}{typeof after === 'number' ? after.toLocaleString() : after}
          </Typography>
        </Stack>
        {diff !== 0 && (
          <Chip
            size="small"
            icon={diff > 0 ? <TrendingUp /> : <TrendingDown />}
            label={`${diff > 0 ? '+' : ''}${typeof diff === 'number' ? diff.toLocaleString() : diff}`}
            color={isBad ? 'error' : 'success'}
            variant="outlined"
            sx={{ mt: 1 }}
          />
        )}
      </CardContent>
    </Card>
  );
}

export default function SimulationLab() {
  const [tab, setTab] = useState(0);
  const [projects, setProjects] = useState([]);
  const [selectedProject, setSelectedProject] = useState('');
  const [milestones, setMilestones] = useState([]);
  const [activities, setActivities] = useState([]);
  const [sessionId, setSessionId] = useState(null);
  const [results, setResults] = useState(null);
  const [loading, setLoading] = useState(false);
  const [snack, setSnack] = useState({ open: false, message: '', severity: 'success' });

  // Form states
  const [schedForm, setSchedForm] = useState({ milestone_id: '', phase: '', delay_days: 14 });
  const [costForm, setCostForm] = useState({ time_impact_days: 14, daily_overhead_cost: 8500, escalation_pct: 0 });
  const [cashForm, setCashForm] = useState({ milestone_delay_days: 14 });
  const [resForm, setResForm] = useState({ activity_id: '', additional_resources: 2, productivity_gain_pct: 15 });

  const showSnack = (msg, sev = 'success') => setSnack({ open: true, message: msg, severity: sev });

  useEffect(() => {
    getProjects().then(r => setProjects(r.data)).catch(() => {});
  }, []);

  useEffect(() => {
    if (selectedProject) {
      getMilestones(selectedProject).then(r => setMilestones(r.data)).catch(() => {});
      getActivities(selectedProject).then(r => setActivities(r.data)).catch(() => {});
      setSessionId(null);
      setResults(null);
    }
  }, [selectedProject]);

  const ensureSession = useCallback(async () => {
    if (sessionId) return sessionId;
    const proj = projects.find(p => p.id === selectedProject);
    const res = await startSimulation({ project_id: selectedProject, name: `Sim — ${proj?.name || 'Project'}` });
    setSessionId(res.data.id);
    return res.data.id;
  }, [sessionId, selectedProject, projects]);

  const handleRun = async (type, params) => {
    if (!selectedProject) { showSnack('Select a project first', 'warning'); return; }
    setLoading(true);
    try {
      const sid = await ensureSession();
      const res = await runSimulation({ session_id: sid, type, input_parameters: params });
      setResults(res.data.output_results);
      showSnack(`${type} simulation complete`);
    } catch (err) {
      showSnack(err.response?.data?.detail || 'Simulation failed', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleApply = async () => {
    if (!sessionId) return;
    try {
      await applySimulation(sessionId);
      showSnack('Simulation applied to real project data');
      setSessionId(null);
      setResults(null);
    } catch (err) {
      showSnack(err.response?.data?.detail || 'Apply failed', 'error');
    }
  };

  const handleDiscard = async () => {
    if (!sessionId) return;
    try {
      await discardSimulation(sessionId);
      showSnack('Simulation discarded');
      setSessionId(null);
      setResults(null);
    } catch (err) {
      showSnack(err.response?.data?.detail || 'Discard failed', 'error');
    }
  };

  const phases = ['Design', 'Construction', 'Closure'];

  return (
    <Box>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
        <Science sx={{ fontSize: 32, color: '#9c27b0' }} />
        <Box>
          <Typography variant="h5" fontWeight={700}>Simulation Lab</Typography>
          <Typography variant="body2" color="text.secondary">
            Run what-if scenarios without affecting real project data
          </Typography>
        </Box>
      </Box>

      <Box sx={{ display: 'flex', gap: 2, mb: 3, alignItems: 'center', flexWrap: 'wrap' }}>
        <TextField select label="Select Project" value={selectedProject} size="small"
          onChange={e => setSelectedProject(e.target.value)} sx={{ minWidth: 300 }}>
          <MenuItem value="">Choose a project</MenuItem>
          {projects.map(p => <MenuItem key={p.id} value={p.id}>{p.name}</MenuItem>)}
        </TextField>
        {sessionId && (
          <Chip label={`Session #${sessionId} (Draft)`} color="secondary" variant="outlined" icon={<Science />} />
        )}
        {sessionId && results && (
          <>
            <Button variant="contained" color="success" startIcon={<Check />} onClick={handleApply}>
              Apply Simulation
            </Button>
            <Button variant="outlined" color="error" startIcon={<Close />} onClick={handleDiscard}>
              Discard
            </Button>
          </>
        )}
      </Box>

      {!selectedProject ? (
        <Paper sx={{ p: 6, textAlign: 'center' }}>
          <Science sx={{ fontSize: 64, color: '#ccc', mb: 2 }} />
          <Typography variant="h6" color="text.secondary">Select a project to begin simulation</Typography>
        </Paper>
      ) : (
        <>
          <Tabs value={tab} onChange={(_, v) => { setTab(v); setResults(null); }} sx={{ mb: 3 }}
            variant="scrollable" scrollButtons="auto">
            <Tab label="Schedule Simulation" />
            <Tab label="Cost Simulation" />
            <Tab label="Cashflow Simulation" />
            <Tab label="Resource Simulation" />
          </Tabs>

          {/* ===== SCHEDULE ===== */}
          {tab === 0 && (
            <Box>
              <Paper sx={{ p: 3, mb: 3 }}>
                <Typography variant="h6" fontWeight={600} mb={2}>Schedule Delay Parameters</Typography>
                <Grid container spacing={2} alignItems="center">
                  <Grid item xs={12} sm={3}>
                    <TextField select label="Target Milestone" fullWidth size="small"
                      value={schedForm.milestone_id} onChange={e => setSchedForm({ ...schedForm, milestone_id: e.target.value, phase: '' })}>
                      <MenuItem value="">All Milestones</MenuItem>
                      {milestones.map(m => <MenuItem key={m.id} value={m.id}>{m.name}</MenuItem>)}
                    </TextField>
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <TextField select label="Or Target Phase" fullWidth size="small"
                      value={schedForm.phase} onChange={e => setSchedForm({ ...schedForm, phase: e.target.value, milestone_id: '' })}>
                      <MenuItem value="">All Phases</MenuItem>
                      {phases.map(p => <MenuItem key={p} value={p}>{p}</MenuItem>)}
                    </TextField>
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <TextField label="Delay Days" type="number" fullWidth size="small"
                      value={schedForm.delay_days} onChange={e => setSchedForm({ ...schedForm, delay_days: +e.target.value })} />
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <Button variant="contained" fullWidth startIcon={loading ? <CircularProgress size={18} /> : <PlayArrow />}
                      onClick={() => handleRun('Schedule', schedForm)} disabled={loading}>
                      Run Simulation
                    </Button>
                  </Grid>
                </Grid>
              </Paper>

              {results && results.before_milestones && (
                <>
                  <Grid container spacing={2} sx={{ mb: 3 }}>
                    <Grid item xs={6} sm={3}>
                      <CompareCard label="Project End Date" before={results.original_end_date} after={results.simulated_end_date} prefix="" />
                    </Grid>
                    <Grid item xs={6} sm={3}>
                      <CompareCard label="Total Delay" before={0} after={results.total_delay_days} prefix="" inverse />
                    </Grid>
                    <Grid item xs={6} sm={3}>
                      <Card><CardContent>
                        <Typography variant="body2" color="text.secondary">Critical Impact</Typography>
                        <Typography variant="h5" fontWeight={700} color={results.critical_milestone_impacted ? 'error.main' : 'success.main'}>
                          {results.critical_milestone_impacted ? 'YES' : 'NO'}
                        </Typography>
                      </CardContent></Card>
                    </Grid>
                    <Grid item xs={6} sm={3}>
                      <CompareCard label="Project Status" before={results.project_status_before} after={results.project_status_after} prefix="" />
                    </Grid>
                  </Grid>

                  <Paper sx={{ p: 3, mb: 3, height: Math.max(420, results.after_milestones.length * 60 + 100) }}>
                    <Typography variant="h6" fontWeight={600} mb={1}>Milestone Comparison — Before vs After Impact</Typography>
                    <Typography variant="caption" color="text.secondary" display="block" mb={1}>
                      Horizontal bars show each milestone's timeline — compare blue (before) vs red (after) to see the shift
                    </Typography>
                    <ResponsiveContainer width="100%" height="88%">
                      <BarChart
                        layout="vertical"
                        data={results.after_milestones.map((m, i) => {
                          const before = Math.round((new Date(results.before_milestones[i]?.planned_date) - new Date()) / 86400000);
                          const after = Math.round((new Date(m.planned_date) - new Date()) / 86400000);
                          return {
                            name: (m.is_critical ? '\u2B50 ' : '') + (m.name.length > 22 ? m.name.substring(0, 22) + '\u2026' : m.name),
                            fullName: m.name,
                            Before: before,
                            After: after,
                            Shift: after - before,
                            shifted: m.shifted,
                            critical: m.is_critical,
                          };
                        })}
                        margin={{ top: 5, right: 50, bottom: 10, left: 10 }}
                      >
                        <CartesianGrid strokeDasharray="3 3" horizontal={false} />
                        <XAxis type="number" tick={{ fontSize: 11 }}>
                          <Label value="Days from Today" position="insideBottom" offset={-5} style={{ fontSize: 12, fill: '#666' }} />
                        </XAxis>
                        <YAxis dataKey="name" type="category" width={180} tick={{ fontSize: 11 }} />
                        <RTooltip
                          content={({ payload, label }) => {
                            if (!payload?.length) return null;
                            const d = payload[0]?.payload;
                            if (!d) return null;
                            return (
                              <Paper sx={{ p: 1.5, boxShadow: 3, maxWidth: 280 }}>
                                <Typography variant="subtitle2" fontWeight={700}>{d.fullName}</Typography>
                                <Box sx={{ display: 'flex', gap: 2, mt: 0.5 }}>
                                  <Typography variant="body2" color="#1565c0" fontWeight={600}>Before: {d.Before} days</Typography>
                                  <Typography variant="body2" color="#c62828" fontWeight={600}>After: {d.After} days</Typography>
                                </Box>
                                <Typography variant="body2" sx={{ mt: 0.5 }}
                                  color={d.Shift > 0 ? 'error.main' : d.Shift < 0 ? 'success.main' : 'text.secondary'}
                                  fontWeight={700}>
                                  {d.Shift > 0 ? '\u25B2' : d.Shift < 0 ? '\u25BC' : '\u25CF'} {d.Shift > 0 ? '+' : ''}{d.Shift} days
                                  {d.Shift > 0 ? '  Delayed' : d.Shift < 0 ? '  Accelerated' : '  No change'}
                                </Typography>
                                <Stack direction="row" spacing={0.5} mt={0.5}>
                                  {d.critical && <Chip label="Critical" size="small" color="error" />}
                                  {d.shifted && <Chip label="Shifted" size="small" color="warning" />}
                                </Stack>
                              </Paper>
                            );
                          }}
                        />
                        <Legend />
                        <Bar dataKey="Before" name="Before Impact" fill="#1565c0" radius={[0, 6, 6, 0]} barSize={14} fillOpacity={0.85} />
                        <Bar dataKey="After" name="After Impact" fill="#c62828" radius={[0, 6, 6, 0]} barSize={14} fillOpacity={0.85} />
                      </BarChart>
                    </ResponsiveContainer>
                  </Paper>
                </>
              )}
            </Box>
          )}

          {/* ===== COST ===== */}
          {tab === 1 && (
            <Box>
              <Paper sx={{ p: 3, mb: 3 }}>
                <Typography variant="h6" fontWeight={600} mb={2}>Cost Impact Parameters</Typography>
                <Grid container spacing={2} alignItems="center">
                  <Grid item xs={12} sm={3}>
                    <TextField label="Time Impact (Days)" type="number" fullWidth size="small"
                      value={costForm.time_impact_days} onChange={e => setCostForm({ ...costForm, time_impact_days: +e.target.value })} />
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <TextField label="Daily Overhead (£)" type="number" fullWidth size="small"
                      value={costForm.daily_overhead_cost} onChange={e => setCostForm({ ...costForm, daily_overhead_cost: +e.target.value })} />
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <TextField label="Escalation %" type="number" fullWidth size="small"
                      value={costForm.escalation_pct} onChange={e => setCostForm({ ...costForm, escalation_pct: +e.target.value })} />
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <Button variant="contained" fullWidth startIcon={loading ? <CircularProgress size={18} /> : <PlayArrow />}
                      onClick={() => handleRun('Cost', costForm)} disabled={loading}>
                      Run Simulation
                    </Button>
                  </Grid>
                </Grid>
              </Paper>

              {results && results.total_budget !== undefined && (
                <>
                  <Grid container spacing={2} sx={{ mb: 3 }}>
                    <Grid item xs={6} sm={2.4}>
                      <Card><CardContent>
                        <Typography variant="body2" color="text.secondary">Cost Impact</Typography>
                        <Typography variant="h6" fontWeight={700} color="error.main">£{results.total_cost_impact?.toLocaleString()}</Typography>
                      </CardContent></Card>
                    </Grid>
                    <Grid item xs={6} sm={2.4}>
                      <CompareCard label="Actual Cost" before={results.current_actual_cost} after={results.forecast_cost} inverse />
                    </Grid>
                    <Grid item xs={6} sm={2.4}>
                      <Card><CardContent>
                        <Typography variant="body2" color="text.secondary">Budget</Typography>
                        <Typography variant="h6" fontWeight={700}>£{results.total_budget?.toLocaleString()}</Typography>
                      </CardContent></Card>
                    </Grid>
                    <Grid item xs={6} sm={2.4}>
                      <Card><CardContent>
                        <Typography variant="body2" color="text.secondary">Budget Variance</Typography>
                        <Typography variant="h6" fontWeight={700} color={results.budget_variance >= 0 ? 'success.main' : 'error.main'}>
                          £{results.budget_variance?.toLocaleString()}
                        </Typography>
                      </CardContent></Card>
                    </Grid>
                    <Grid item xs={6} sm={2.4}>
                      <Card><CardContent>
                        <Typography variant="body2" color="text.secondary">Cost Increase</Typography>
                        <Typography variant="h6" fontWeight={700} color="error.main">{results.cost_increase_pct}%</Typography>
                      </CardContent></Card>
                    </Grid>
                  </Grid>

                  <Paper sx={{ p: 3, mb: 3, height: 380 }}>
                    <Typography variant="h6" fontWeight={600} mb={2}>Budget vs Forecast</Typography>
                    <ResponsiveContainer width="100%" height="85%">
                      <BarChart data={[
                        { name: 'Budget', value: results.total_budget },
                        { name: 'Current Actual', value: results.current_actual_cost },
                        { name: 'Forecast', value: results.forecast_cost },
                      ]}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="name" />
                        <YAxis tickFormatter={v => `£${(v / 1000000).toFixed(1)}M`} />
                        <RTooltip formatter={v => `£${v.toLocaleString()}`} />
                        <Bar dataKey="value" radius={[8, 8, 0, 0]}>
                          <Cell fill="#90caf9" />
                          <Cell fill="#ffcc80" />
                          <Cell fill="#ef9a9a" />
                        </Bar>
                      </BarChart>
                    </ResponsiveContainer>
                  </Paper>

                  <Paper sx={{ p: 3, mb: 3, height: 420 }}>
                    <Typography variant="h6" fontWeight={600} mb={2}>CBS Impact — Before vs After</Typography>
                    <ResponsiveContainer width="100%" height="85%">
                      <BarChart data={results.after_cbs?.map((c, i) => ({
                        name: c.wbs_code,
                        Budget: c.budget_cost,
                        'Before Actual': results.before_cbs[i]?.actual_cost,
                        'After Actual': c.actual_cost,
                      }))}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="name" tick={{ fontSize: 11 }} />
                        <YAxis tickFormatter={v => `£${(v / 1000).toFixed(0)}K`} />
                        <RTooltip formatter={v => `£${v?.toLocaleString()}`} />
                        <Legend />
                        <Bar dataKey="Budget" fill="#90caf9" radius={[4, 4, 0, 0]} />
                        <Bar dataKey="Before Actual" fill="#ffcc80" radius={[4, 4, 0, 0]} />
                        <Bar dataKey="After Actual" fill="#ef9a9a" radius={[4, 4, 0, 0]} />
                      </BarChart>
                    </ResponsiveContainer>
                  </Paper>

                  <Paper sx={{ p: 3, height: 380 }}>
                    <Typography variant="h6" fontWeight={600} mb={2}>Cost Added & Variance per WBS</Typography>
                    <ResponsiveContainer width="100%" height="85%">
                      <BarChart data={results.after_cbs?.map((c) => ({
                        name: c.wbs_code,
                        'Cost Added': c.cost_added,
                        Variance: c.variance,
                      }))}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="name" tick={{ fontSize: 11 }} />
                        <YAxis tickFormatter={v => `£${(v / 1000).toFixed(0)}K`} />
                        <RTooltip formatter={v => `£${v?.toLocaleString()}`} />
                        <Legend />
                        <ReferenceLine y={0} stroke="#666" strokeDasharray="3 3" />
                        <Bar dataKey="Cost Added" fill="#e57373" radius={[4, 4, 0, 0]} />
                        <Bar dataKey="Variance" radius={[4, 4, 0, 0]}>
                          {results.after_cbs?.map((c, i) => (
                            <Cell key={i} fill={c.variance >= 0 ? '#66bb6a' : '#e57373'} />
                          ))}
                        </Bar>
                      </BarChart>
                    </ResponsiveContainer>
                  </Paper>
                </>
              )}
            </Box>
          )}

          {/* ===== CASHFLOW ===== */}
          {tab === 2 && (
            <Box>
              <Paper sx={{ p: 3, mb: 3 }}>
                <Typography variant="h6" fontWeight={600} mb={2}>Cashflow Impact Parameters</Typography>
                <Grid container spacing={2} alignItems="center">
                  <Grid item xs={12} sm={4}>
                    <TextField label="Milestone Delay Days" type="number" fullWidth size="small"
                      value={cashForm.milestone_delay_days} onChange={e => setCashForm({ milestone_delay_days: +e.target.value })} />
                  </Grid>
                  <Grid item xs={12} sm={4}>
                    <Button variant="contained" fullWidth startIcon={loading ? <CircularProgress size={18} /> : <PlayArrow />}
                      onClick={() => handleRun('Cashflow', cashForm)} disabled={loading}>
                      Run Simulation
                    </Button>
                  </Grid>
                </Grid>
              </Paper>

              {results && (!results.combined_chart || results.combined_chart.length === 0) && (
                <Alert severity="info" sx={{ mb: 3 }}>
                  No milestone payment data found for this project. Add milestone payments in the Commercial tab to see cashflow simulation results.
                </Alert>
              )}

              {results && results.combined_chart && results.combined_chart.length > 0 && (
                <>
                  <Grid container spacing={2} sx={{ mb: 3 }}>
                    <Grid item xs={12} sm={4}>
                      <Card><CardContent>
                        <Typography variant="body2" color="text.secondary">Total Expected</Typography>
                        <Typography variant="h5" fontWeight={700}>£{results.total_expected?.toLocaleString()}</Typography>
                      </CardContent></Card>
                    </Grid>
                    <Grid item xs={12} sm={4}>
                      <Card><CardContent>
                        <Typography variant="body2" color="text.secondary">Already Received</Typography>
                        <Typography variant="h5" fontWeight={700} color="success.main">£{results.total_received?.toLocaleString()}</Typography>
                      </CardContent></Card>
                    </Grid>
                    <Grid item xs={12} sm={4}>
                      <Card sx={{ bgcolor: '#fff3e0' }}><CardContent>
                        <Typography variant="body2" color="text.secondary">Working Capital Gap</Typography>
                        <Typography variant="h5" fontWeight={700} color="error.main">£{results.working_capital_gap?.toLocaleString()}</Typography>
                      </CardContent></Card>
                    </Grid>
                  </Grid>

                  <Paper sx={{ p: 3, height: 420 }}>
                    <Typography variant="h6" fontWeight={600} mb={2}>Cashflow: Before vs After Delay</Typography>
                    <ResponsiveContainer width="100%" height="85%">
                      <BarChart data={results.combined_chart}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="month" />
                        <YAxis tickFormatter={v => `£${(v / 1000000).toFixed(1)}M`} />
                        <RTooltip formatter={v => `£${v.toLocaleString()}`} />
                        <Legend />
                        <Bar dataKey="before_expected" name="Before (Expected)" fill="#90caf9" radius={[4, 4, 0, 0]} />
                        <Bar dataKey="after_expected" name="After (Delayed)" fill="#ef9a9a" radius={[4, 4, 0, 0]} />
                      </BarChart>
                    </ResponsiveContainer>
                  </Paper>

                  <Paper sx={{ p: 3, mt: 3, height: 380 }}>
                    <Typography variant="h6" fontWeight={600} mb={2}>Cumulative Cashflow Curve</Typography>
                    <ResponsiveContainer width="100%" height="85%">
                      <LineChart data={results.before_cashflow?.map((b, i) => ({
                        month: b.month,
                        'Before': b.cumulative,
                        'After': results.after_cashflow?.[i]?.cumulative || 0,
                      }))}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="month" />
                        <YAxis tickFormatter={v => `£${(v / 1000000).toFixed(1)}M`} />
                        <RTooltip formatter={v => `£${v.toLocaleString()}`} />
                        <Legend />
                        <Line type="monotone" dataKey="Before" stroke="#64b5f6" strokeWidth={3} />
                        <Line type="monotone" dataKey="After" stroke="#e57373" strokeWidth={3} strokeDasharray="8 4" />
                      </LineChart>
                    </ResponsiveContainer>
                  </Paper>
                </>
              )}
            </Box>
          )}

          {/* ===== RESOURCE ===== */}
          {tab === 3 && (
            <Box>
              <Paper sx={{ p: 3, mb: 3 }}>
                <Typography variant="h6" fontWeight={600} mb={2}>Resource Acceleration Parameters</Typography>
                <Grid container spacing={2} alignItems="center">
                  <Grid item xs={12} sm={3}>
                    <TextField select label="Target Activity" fullWidth size="small"
                      value={resForm.activity_id} onChange={e => setResForm({ ...resForm, activity_id: e.target.value })}>
                      <MenuItem value="">Select Activity</MenuItem>
                      {activities.filter(a => parseFloat(a.completion_pct) < 100).map(a =>
                        <MenuItem key={a.id} value={a.id}>{a.activity_name} ({a.completion_pct}%)</MenuItem>
                      )}
                    </TextField>
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <TextField label="Additional Resources" type="number" fullWidth size="small"
                      value={resForm.additional_resources} onChange={e => setResForm({ ...resForm, additional_resources: +e.target.value })} />
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <TextField label="Productivity Gain % per Resource" type="number" fullWidth size="small"
                      value={resForm.productivity_gain_pct} onChange={e => setResForm({ ...resForm, productivity_gain_pct: +e.target.value })} />
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <Button variant="contained" fullWidth startIcon={loading ? <CircularProgress size={18} /> : <PlayArrow />}
                      onClick={() => handleRun('Resource', resForm)} disabled={loading || !resForm.activity_id}>
                      Run Simulation
                    </Button>
                  </Grid>
                </Grid>
              </Paper>

              {results && results.days_saved !== undefined && results.days_saved === 0 && (
                <Alert severity="info" sx={{ mb: 3 }}>
                  No days saved. The selected activity may already be complete, or the productivity gain is insufficient. Try increasing resources or selecting a different activity.
                </Alert>
              )}

              {results && results.days_saved !== undefined && (
                <>
                  <Grid container spacing={2} sx={{ mb: 3 }}>
                    <Grid item xs={6} sm={3}>
                      <Card sx={{ bgcolor: '#e8f5e9' }}><CardContent>
                        <Typography variant="body2" color="text.secondary">Days Saved</Typography>
                        <Typography variant="h4" fontWeight={700} color="success.main">{results.days_saved}</Typography>
                      </CardContent></Card>
                    </Grid>
                    <Grid item xs={6} sm={3}>
                      <Card><CardContent>
                        <Typography variant="body2" color="text.secondary">Productivity Gain</Typography>
                        <Typography variant="h4" fontWeight={700}>{results.total_gain_pct}%</Typography>
                      </CardContent></Card>
                    </Grid>
                    <Grid item xs={6} sm={3}>
                      <Card><CardContent>
                        <Typography variant="body2" color="text.secondary">Additional Cost</Typography>
                        <Typography variant="h4" fontWeight={700} color="warning.main">£{results.additional_cost?.toLocaleString()}</Typography>
                      </CardContent></Card>
                    </Grid>
                    <Grid item xs={6} sm={3}>
                      <Card><CardContent>
                        <Typography variant="body2" color="text.secondary">Cost per Day Saved</Typography>
                        <Typography variant="h4" fontWeight={700}>£{results.cost_per_day_saved?.toLocaleString()}</Typography>
                      </CardContent></Card>
                    </Grid>
                  </Grid>

                  <Paper sx={{ p: 3, mb: 3, height: 420 }}>
                    <Typography variant="h6" fontWeight={600} mb={2}>Activity Duration — Before vs After Impact</Typography>
                    <ResponsiveContainer width="100%" height="85%">
                      <BarChart data={results.after_activities?.map((a, i) => ({
                        name: a.activity_name.length > 18 ? a.activity_name.substring(0, 18) + '…' : a.activity_name,
                        'Original Duration': results.before_activities[i]?.duration_days,
                        'New Duration': a.duration_days,
                        accelerated: a.accelerated,
                      }))} layout="vertical">
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis type="number" label={{ value: 'Duration (Days)', position: 'insideBottom', offset: -5 }} />
                        <YAxis dataKey="name" type="category" width={160} tick={{ fontSize: 11 }} />
                        <RTooltip formatter={(v, name) => [`${v} days`, name]} />
                        <Legend />
                        <Bar dataKey="Original Duration" fill="#ef9a9a" radius={[0, 4, 4, 0]} />
                        <Bar dataKey="New Duration" fill="#66bb6a" radius={[0, 4, 4, 0]} />
                      </BarChart>
                    </ResponsiveContainer>
                  </Paper>

                  <Paper sx={{ p: 3, height: 380 }}>
                    <Typography variant="h6" fontWeight={600} mb={2}>Days Saved per Activity</Typography>
                    <ResponsiveContainer width="100%" height="85%">
                      <BarChart data={results.after_activities?.map((a) => ({
                        name: a.activity_name.length > 18 ? a.activity_name.substring(0, 18) + '…' : a.activity_name,
                        'Days Saved': a.days_saved || 0,
                      }))}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="name" tick={{ fontSize: 10 }} angle={-20} textAnchor="end" height={55} />
                        <YAxis label={{ value: 'Days Saved', angle: -90, position: 'insideLeft' }} />
                        <RTooltip formatter={(v) => [`${v} days`, 'Saved']} />
                        <Bar dataKey="Days Saved" radius={[4, 4, 0, 0]}>
                          {results.after_activities?.map((a, i) => (
                            <Cell key={i} fill={a.accelerated ? '#2e7d32' : '#bdbdbd'} />
                          ))}
                        </Bar>
                      </BarChart>
                    </ResponsiveContainer>
                  </Paper>
                </>
              )}
            </Box>
          )}
        </>
      )}

      <Snackbar open={snack.open} autoHideDuration={3000} onClose={() => setSnack({ ...snack, open: false })}>
        <Alert severity={snack.severity} onClose={() => setSnack({ ...snack, open: false })}>{snack.message}</Alert>
      </Snackbar>
    </Box>
  );
}
