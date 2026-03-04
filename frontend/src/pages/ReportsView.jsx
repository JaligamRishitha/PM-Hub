import React, { useEffect, useState, useMemo } from 'react';
import {
  Box, Paper, Typography, Grid, Card, CardContent, Button, MenuItem, TextField,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Stack, Chip,
  LinearProgress, Tab, Tabs, Alert, TableSortLabel,
} from '@mui/material';
import {
  Summarize, Download, TrendingUp, Assessment, Warning, Flag,
  FilterList,
} from '@mui/icons-material';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip as RTooltip, Legend,
  ResponsiveContainer, PieChart, Pie, Cell, Line, ComposedChart, Area,
  ReferenceLine,
} from 'recharts';
import {
  getProjects,
  getOverallReport,
  getMilestoneReport,
  getEarnedValueReport,
  getIssuesRiskReport,
} from '../services/api';
import StatusChip from '../components/StatusChip';

const PIE_COLORS = ['#66bb6a', '#ffa726', '#ef5350', '#42a5f5', '#ab47bc', '#26c6da'];

/* =========================================================================
   HELPER: download an array of objects as a CSV file
   ========================================================================= */
function downloadCSV(rows, filename) {
  if (!rows.length) return;
  const headers = Object.keys(rows[0]);
  const csvContent = [
    headers.join(','),
    ...rows.map(row =>
      headers.map(h => {
        const v = row[h] ?? '';
        const str = String(v).replace(/"/g, '""');
        return str.includes(',') || str.includes('"') || str.includes('\n') ? `"${str}"` : str;
      }).join(',')
    ),
  ].join('\n');
  const blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

/* =========================================================================
   MAIN REPORTS VIEW
   ========================================================================= */
export default function ReportsView() {
  const [tab, setTab] = useState(0);
  const [projects, setProjects] = useState([]);
  const [selectedProject, setSelectedProject] = useState('');
  const [loading, setLoading] = useState(false);
  const [initialLoad, setInitialLoad] = useState(true);

  // Backend report data
  const [overallData, setOverallData] = useState(null);
  const [milestoneData, setMilestoneData] = useState(null);
  const [evData, setEvData] = useState(null);
  const [issuesRiskData, setIssuesRiskData] = useState(null);

  useEffect(() => {
    getProjects().then(r => setProjects(r.data)).catch(() => {}).finally(() => setInitialLoad(false));
  }, []);

  useEffect(() => {
    if (!selectedProject) {
      setOverallData(null); setMilestoneData(null); setEvData(null); setIssuesRiskData(null);
      return;
    }
    setLoading(true);
    Promise.all([
      getOverallReport(selectedProject),
      getMilestoneReport(selectedProject),
      getEarnedValueReport(selectedProject),
      getIssuesRiskReport(selectedProject),
    ]).then(([overallRes, msRes, evRes, irRes]) => {
      setOverallData(overallRes.data);
      setMilestoneData(msRes.data);
      setEvData(evRes.data);
      setIssuesRiskData(irRes.data);
    }).catch(() => {}).finally(() => setLoading(false));
  }, [selectedProject]);

  if (initialLoad) return <LinearProgress />;

  const projectLabel = overallData?.project_name || 'project';

  return (
    <Box className="reports-view">
      {/* Header */}
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3, flexWrap: 'wrap', gap: 2 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Summarize sx={{ fontSize: 32, color: '#1565c0' }} />
          <Box>
            <Typography variant="h5" fontWeight={700}>Project Reports</Typography>
            <Typography variant="body2" color="text.secondary">
              Executive-level project health & performance reports
            </Typography>
          </Box>
        </Box>
        <TextField select label="Select Project" value={selectedProject} size="small"
          onChange={e => setSelectedProject(e.target.value)} sx={{ minWidth: 280 }}>
          <MenuItem value="">-- Choose a project --</MenuItem>
          {projects.map(p => <MenuItem key={p.id} value={p.id}>{p.name}</MenuItem>)}
        </TextField>
      </Box>

      {!selectedProject ? (
        <Paper sx={{ p: 6, textAlign: 'center' }}>
          <Summarize sx={{ fontSize: 64, color: '#ccc', mb: 2 }} />
          <Typography variant="h6" color="text.secondary">Select a project to generate reports</Typography>
        </Paper>
      ) : loading ? (
        <LinearProgress />
      ) : (
        <>
          <Tabs value={tab} onChange={(_, v) => setTab(v)} sx={{ mb: 3 }} variant="scrollable" scrollButtons="auto">
            <Tab icon={<Assessment />} iconPosition="start" label="Overall Project Report" />
            <Tab icon={<Flag />} iconPosition="start" label="Key Milestone Report" />
            <Tab icon={<TrendingUp />} iconPosition="start" label="Earned Value Report" />
            <Tab icon={<Warning />} iconPosition="start" label="Issues / Risk Report" />
          </Tabs>

          {tab === 0 && overallData && (
            <OverallProjectReport data={overallData} projectLabel={projectLabel} />
          )}
          {tab === 1 && milestoneData && (
            <KeyMilestoneReport data={milestoneData} projectLabel={projectLabel} />
          )}
          {tab === 2 && evData && (
            <EarnedValueReport data={evData} projectLabel={projectLabel} />
          )}
          {tab === 3 && issuesRiskData && (
            <IssuesRiskReport data={issuesRiskData} projectLabel={projectLabel} />
          )}
        </>
      )}
    </Box>
  );
}

/* =========================================================================
   1. OVERALL PROJECT REPORT
   ========================================================================= */
function OverallProjectReport({ data, projectLabel }) {
  if (!data) return null;
  const ev = data.ev_metrics;
  const sched = data.schedule_summary;
  const fin = data.financial_summary;
  const ms = data.milestone_summary;

  const handleExport = () => {
    const rows = [
      { Section: 'Project Info', Metric: 'Project Name', Value: data.project_name },
      { Section: 'Project Info', Metric: 'Client', Value: data.client || '-' },
      { Section: 'Project Info', Metric: 'Contract Value', Value: data.contract_value || 0 },
      { Section: 'Project Info', Metric: 'Start Date', Value: data.start_date },
      { Section: 'Project Info', Metric: 'Planned Finish', Value: data.planned_finish || '-' },
      { Section: 'Project Info', Metric: 'Data Date', Value: data.data_date },
      { Section: 'Schedule', Metric: 'Total Activities', Value: sched.total_activities },
      { Section: 'Schedule', Metric: 'Completed Activities', Value: sched.completed_activities },
      { Section: 'Schedule', Metric: 'Remaining Activities', Value: sched.remaining_activities },
      { Section: 'Schedule', Metric: 'Critical Activities', Value: sched.critical_activities },
      { Section: 'Schedule', Metric: 'Schedule Variance (days)', Value: sched.schedule_variance_days },
      { Section: 'Schedule', Metric: 'SPI', Value: ev.spi },
      { Section: 'Earned Value', Metric: 'BAC', Value: ev.bac },
      { Section: 'Earned Value', Metric: 'PV', Value: ev.pv },
      { Section: 'Earned Value', Metric: 'EV', Value: ev.ev },
      { Section: 'Earned Value', Metric: 'AC', Value: ev.ac },
      { Section: 'Earned Value', Metric: 'CV', Value: ev.cv },
      { Section: 'Earned Value', Metric: 'SV', Value: ev.sv },
      { Section: 'Earned Value', Metric: 'CPI', Value: ev.cpi },
      { Section: 'Earned Value', Metric: 'SPI', Value: ev.spi },
      { Section: 'Earned Value', Metric: 'EAC', Value: ev.eac },
      { Section: 'Earned Value', Metric: 'VAC', Value: ev.vac },
      { Section: 'Financial', Metric: 'Approved Variations', Value: fin.approved_variations },
      { Section: 'Financial', Metric: 'Pending Variations', Value: fin.pending_variations },
      { Section: 'Financial', Metric: 'LD Exposure', Value: fin.ld_exposure },
      { Section: 'Financial', Metric: 'Forecast Margin %', Value: fin.forecast_margin_pct },
      { Section: 'Milestones', Metric: 'Total Milestones', Value: ms.total },
      { Section: 'Milestones', Metric: 'Completed', Value: ms.completed },
      { Section: 'Milestones', Metric: 'Delayed', Value: ms.delayed },
      { Section: 'Milestones', Metric: 'Upcoming (30 days)', Value: ms.upcoming_30_days },
    ];
    downloadCSV(rows, `Overall_Project_Report_${projectLabel}.csv`);
  };

  return (
    <Box>
      {/* Export Button */}
      <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 2 }}>
        <Button variant="contained" startIcon={<Download />} onClick={handleExport}
          sx={{ bgcolor: '#1a2332', '&:hover': { bgcolor: '#2d3e50' } }} size="small">
          Export Overall Report
        </Button>
      </Box>

      {/* Project Info Banner */}
      <Paper sx={{ p: 2.5, mb: 3, bgcolor: '#f5f5f5' }}>
        <Grid container spacing={2}>
          {[
            ['Project', data.project_name],
            ['Client', data.client || '-'],
            ['Contract Value', `£${(data.contract_value || 0).toLocaleString()}`],
            ['Start Date', data.start_date],
            ['Planned Finish', data.planned_finish || '-'],
            ['Forecast Finish', data.forecast_finish || '-'],
            ['Data Date', data.data_date],
          ].map(([l, v], i) => (
            <Grid item xs={6} sm={3} md={12 / 7} key={i}>
              <Typography variant="caption" color="text.secondary">{l}</Typography>
              <Typography variant="body2" fontWeight={600}>{v}</Typography>
            </Grid>
          ))}
        </Grid>
      </Paper>

      {/* KPI Cards Row */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        {[
          { label: 'Schedule Health', value: `${data.schedule_health_pct}%`, color: data.schedule_health_pct >= 95 ? '#2e7d32' : data.schedule_health_pct >= 85 ? '#ed6c02' : '#d32f2f' },
          { label: 'Cost Health', value: `${data.cost_health_pct}%`, color: data.cost_health_pct >= 95 ? '#2e7d32' : data.cost_health_pct >= 85 ? '#ed6c02' : '#d32f2f' },
          { label: 'Risk Score', value: data.risk_score, color: data.risk_score > 50 ? '#d32f2f' : data.risk_score > 20 ? '#ed6c02' : '#2e7d32' },
          { label: 'LD Exposure', value: `£${data.ld_exposure.toLocaleString()}`, color: data.ld_exposure > 0 ? '#d32f2f' : '#2e7d32' },
        ].map((kpi, i) => (
          <Grid item xs={6} sm={3} key={i}>
            <Card><CardContent sx={{ textAlign: 'center', py: 2 }}>
              <Typography variant="h4" fontWeight={700} sx={{ color: kpi.color }}>{kpi.value}</Typography>
              <Typography variant="body2" color="text.secondary">{kpi.label}</Typography>
            </CardContent></Card>
          </Grid>
        ))}
      </Grid>

      {/* S-Curve */}
      <Paper sx={{ p: 3, mb: 3, height: 420 }}>
        <Typography variant="h6" fontWeight={600} mb={2}>EV S-Curve — PV vs EV vs AC</Typography>
        <ResponsiveContainer width="100%" height="85%">
          <ComposedChart data={data.s_curve_data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="month" tick={{ fontSize: 10 }} />
            <YAxis tickFormatter={v => `£${(v / 1e6).toFixed(1)}M`} />
            <RTooltip formatter={v => v != null ? `£${v.toLocaleString()}` : '-'} />
            <Legend />
            <Area type="monotone" dataKey="PV" name="Planned Value (PV)" fill="#bbdefb" stroke="none" fillOpacity={0.35} />
            <Line type="monotone" dataKey="PV" name="Planned Value (PV)" stroke="#1565c0" strokeWidth={2.5} dot={{ r: 3 }} />
            <Line type="monotone" dataKey="EV" name="Earned Value (EV)" stroke="#2e7d32" strokeWidth={2.5} dot={{ r: 3 }} />
            <Line type="monotone" dataKey="AC" name="Actual Cost (AC)" stroke="#c62828" strokeWidth={2.5} strokeDasharray="6 3" dot={{ r: 3 }} connectNulls={false} />
          </ComposedChart>
        </ResponsiveContainer>
      </Paper>

      <Grid container spacing={3} sx={{ mb: 3 }}>
        {/* Schedule Summary */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight={600} mb={2}>Schedule Summary</Typography>
            <Stack spacing={1.5}>
              {[
                ['Total Activities', sched.total_activities],
                ['Completed', sched.completed_activities],
                ['Remaining', sched.remaining_activities],
                ['Critical Activities', sched.critical_activities],
                ['Schedule Variance', `${sched.schedule_variance_days > 0 ? '+' : ''}${sched.schedule_variance_days} days`],
                ['SPI', ev.spi.toFixed(2)],
              ].map(([l, v], i) => (
                <Box key={i} sx={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Typography variant="body2" color="text.secondary">{l}</Typography>
                  <Typography variant="body2" fontWeight={600}>{v}</Typography>
                </Box>
              ))}
            </Stack>
          </Paper>
        </Grid>

        {/* Financial Summary */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight={600} mb={2}>Financial Summary</Typography>
            <Stack spacing={1.5}>
              {[
                ['Contract Value', `£${(fin.contract_value || 0).toLocaleString()}`],
                ['Budget (BAC)', `£${(fin.budget_bac || 0).toLocaleString()}`],
                ['Actual Cost', `£${ev.ac.toLocaleString()}`],
                ['Approved Variations', `£${fin.approved_variations.toLocaleString()}`],
                ['Pending Variations', `£${fin.pending_variations.toLocaleString()}`],
                ['LD Exposure', `£${fin.ld_exposure.toLocaleString()}`],
                ['Forecast Margin', `${fin.forecast_margin_pct}%`],
              ].map(([l, v], i) => (
                <Box key={i} sx={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Typography variant="body2" color="text.secondary">{l}</Typography>
                  <Typography variant="body2" fontWeight={600}>{v}</Typography>
                </Box>
              ))}
            </Stack>
          </Paper>
        </Grid>

        {/* Milestone Summary */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight={600} mb={2}>Milestone Summary</Typography>
            <Stack spacing={1.5}>
              {[
                ['Total Milestones', ms.total],
                ['Completed', ms.completed],
                ['Delayed', ms.delayed],
                ['Upcoming (30 days)', ms.upcoming_30_days],
              ].map(([l, v], i) => (
                <Box key={i} sx={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Typography variant="body2" color="text.secondary">{l}</Typography>
                  <Typography variant="body2" fontWeight={600}>{v}</Typography>
                </Box>
              ))}
            </Stack>
            {/* Mini milestone table */}
            <Box sx={{ mt: 2 }}>
              <TableContainer>
                <Table size="small">
                  <TableHead><TableRow>
                    <TableCell sx={{ py: 0.5 }}>Milestone</TableCell>
                    <TableCell sx={{ py: 0.5 }}>Date</TableCell>
                    <TableCell sx={{ py: 0.5 }}>Variance</TableCell>
                  </TableRow></TableHead>
                  <TableBody>
                    {(ms.top_milestones || []).map((m, i) => (
                      <TableRow key={i}>
                        <TableCell sx={{ py: 0.5 }}><Typography variant="caption" fontWeight={600}>{m.name}</Typography></TableCell>
                        <TableCell sx={{ py: 0.5 }}><Typography variant="caption">{m.planned_date}</Typography></TableCell>
                        <TableCell sx={{ py: 0.5 }}>
                          {m.delay_days > 0
                            ? <Chip label={`+${m.delay_days}d`} size="small" color="error" sx={{ height: 20, fontSize: 11 }} />
                            : <Typography variant="caption" color="success.main">On Track</Typography>
                          }
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </Box>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}

/* =========================================================================
   2. KEY MILESTONE REPORT
   ========================================================================= */
function KeyMilestoneReport({ data, projectLabel }) {
  const milestones = data.milestones || [];
  const summary = data.summary || {};

  const [phaseFilter, setPhaseFilter] = useState('');
  const [criticalFilter, setCriticalFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [sortField, setSortField] = useState('planned_date');
  const [sortDir, setSortDir] = useState('asc');

  const handleExport = () => {
    const rows = milestones.map(m => ({
      'Milestone ID': `M-${String(m.id).padStart(3, '0')}`,
      'Milestone Name': m.name,
      Phase: m.phase || '',
      'Baseline Date': m.planned_date,
      'Actual Date': m.actual_date || '',
      'Delay Days': m.delay_days || 0,
      'Is Critical': m.is_critical ? 'Yes' : 'No',
      Status: m.status,
    }));
    downloadCSV(rows, `Key_Milestone_Report_${projectLabel}.csv`);
  };

  const phases = [...new Set(milestones.map(m => m.phase).filter(Boolean))];

  const filtered = useMemo(() => {
    let ms = [...milestones];
    if (phaseFilter) ms = ms.filter(m => m.phase === phaseFilter);
    if (criticalFilter === 'yes') ms = ms.filter(m => m.is_critical);
    if (criticalFilter === 'no') ms = ms.filter(m => !m.is_critical);
    if (statusFilter) ms = ms.filter(m => m.status === statusFilter);
    ms.sort((a, b) => {
      let av = a[sortField], bv = b[sortField];
      if (sortField === 'delay_days') { av = av || 0; bv = bv || 0; }
      if (av < bv) return sortDir === 'asc' ? -1 : 1;
      if (av > bv) return sortDir === 'asc' ? 1 : -1;
      return 0;
    });
    return ms;
  }, [milestones, phaseFilter, criticalFilter, statusFilter, sortField, sortDir]);

  const handleSort = (field) => {
    setSortDir(sortField === field && sortDir === 'asc' ? 'desc' : 'asc');
    setSortField(field);
  };

  // Status pie data
  const statusPieData = (data.status_distribution || []).map(d => ({ name: d.status, value: d.count }));
  const statusColors = { Completed: '#66bb6a', Delayed: '#ef5350', Pending: '#ffa726', 'On Track': '#42a5f5' };

  // Timeline chart data
  const timelineData = [...milestones]
    .sort((a, b) => new Date(a.planned_date) - new Date(b.planned_date))
    .map(m => {
      const baseDate = new Date(data.project_start_date || Date.now());
      return {
        name: m.name.length > 16 ? m.name.substring(0, 16) + '…' : m.name,
        Planned: Math.round((new Date(m.planned_date) - baseDate) / 86400000),
        Actual: m.actual_date ? Math.round((new Date(m.actual_date) - baseDate) / 86400000) : null,
        Delay: m.delay_days || 0,
        critical: m.is_critical,
      };
    });

  return (
    <Box>
      {/* Export Button */}
      <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 2 }}>
        <Button variant="contained" startIcon={<Download />} onClick={handleExport}
          sx={{ bgcolor: '#1a2332', '&:hover': { bgcolor: '#2d3e50' } }} size="small">
          Export Milestone Report
        </Button>
      </Box>

      {/* Summary Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        {[
          { label: 'Total Milestones', value: summary.total || 0, color: '#1565c0' },
          { label: 'Completed', value: summary.completed || 0, color: '#2e7d32' },
          { label: 'Delayed', value: summary.delayed || 0, color: '#d32f2f' },
          { label: 'Critical', value: summary.critical || 0, color: '#e65100' },
          { label: 'Avg Delay', value: `${summary.avg_delay_days || 0}d`, color: (summary.avg_delay_days || 0) > 7 ? '#d32f2f' : '#ed6c02' },
        ].map((kpi, i) => (
          <Grid item xs={6} sm={2.4} key={i}>
            <Card><CardContent sx={{ textAlign: 'center', py: 2 }}>
              <Typography variant="h4" fontWeight={700} sx={{ color: kpi.color }}>{kpi.value}</Typography>
              <Typography variant="body2" color="text.secondary">{kpi.label}</Typography>
            </CardContent></Card>
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3} sx={{ mb: 3 }}>
        {/* Status Distribution */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: 370 }}>
            <Typography variant="h6" fontWeight={600} mb={2}>Status Distribution</Typography>
            {statusPieData.length > 0 ? (
              <ResponsiveContainer width="100%" height="85%">
                <PieChart>
                  <Pie data={statusPieData} dataKey="value" nameKey="name" cx="50%" cy="50%"
                    innerRadius={50} outerRadius={105} label={({ name, value }) => `${name}: ${value}`}>
                    {statusPieData.map((e, i) => <Cell key={i} fill={statusColors[e.name] || PIE_COLORS[i]} />)}
                  </Pie>
                  <RTooltip />
                </PieChart>
              </ResponsiveContainer>
            ) : <EmptyState text="No milestones" />}
          </Paper>
        </Grid>

        {/* Timeline Visualization */}
        <Grid item xs={12} md={8}>
          <Paper sx={{ p: 3, height: 370 }}>
            <Typography variant="h6" fontWeight={600} mb={2}>Milestone Timeline (days from start)</Typography>
            <ResponsiveContainer width="100%" height="85%">
              <ComposedChart data={timelineData} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" label={{ value: 'Days', position: 'insideBottom', offset: -5 }} />
                <YAxis dataKey="name" type="category" width={130} tick={{ fontSize: 10 }} />
                <RTooltip formatter={(v, name) => [v != null ? `${v} days` : '-', name]} />
                <Legend />
                <Bar dataKey="Planned" name="Planned Date" fill="#64b5f6" radius={[0, 4, 4, 0]} barSize={12} />
                <Bar dataKey="Actual" name="Actual Date" fill="#66bb6a" radius={[0, 4, 4, 0]} barSize={12} />
              </ComposedChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>
      </Grid>

      {/* Delay Variance Chart */}
      <Paper sx={{ p: 3, mb: 3, height: 340 }}>
        <Typography variant="h6" fontWeight={600} mb={2}>Milestone Delay Variance</Typography>
        <ResponsiveContainer width="100%" height="85%">
          <BarChart data={timelineData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" tick={{ fontSize: 10 }} angle={-20} textAnchor="end" height={55} />
            <YAxis label={{ value: 'Delay (days)', angle: -90, position: 'insideLeft' }} />
            <RTooltip formatter={v => [`${v} days`, 'Delay']} />
            <ReferenceLine y={0} stroke="#666" strokeDasharray="3 3" />
            <Bar dataKey="Delay" radius={[4, 4, 0, 0]}>
              {timelineData.map((d, i) => (
                <Cell key={i} fill={d.critical && d.Delay > 0 ? '#d32f2f' : d.Delay > 0 ? '#ff9800' : '#66bb6a'} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </Paper>

      {/* Filters */}
      <Paper sx={{ p: 2, mb: 2 }}>
        <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap">
          <FilterList color="action" />
          <TextField select label="Phase" value={phaseFilter} size="small" sx={{ minWidth: 150 }}
            onChange={e => setPhaseFilter(e.target.value)}>
            <MenuItem value="">All Phases</MenuItem>
            {phases.map(p => <MenuItem key={p} value={p}>{p}</MenuItem>)}
          </TextField>
          <TextField select label="Critical" value={criticalFilter} size="small" sx={{ minWidth: 130 }}
            onChange={e => setCriticalFilter(e.target.value)}>
            <MenuItem value="">All</MenuItem>
            <MenuItem value="yes">Critical Only</MenuItem>
            <MenuItem value="no">Non-Critical</MenuItem>
          </TextField>
          <TextField select label="Status" value={statusFilter} size="small" sx={{ minWidth: 150 }}
            onChange={e => setStatusFilter(e.target.value)}>
            <MenuItem value="">All Statuses</MenuItem>
            {['Pending', 'Delayed', 'Completed', 'On Track'].map(s => <MenuItem key={s} value={s}>{s}</MenuItem>)}
          </TextField>
          <Typography variant="body2" color="text.secondary">{filtered.length} milestones</Typography>
        </Stack>
      </Paper>

      {/* Milestone Table */}
      <Paper sx={{ p: 3 }}>
        <Typography variant="h6" fontWeight={600} mb={2}>Milestone Register</Typography>
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>ID</TableCell>
                <TableCell><TableSortLabel active={sortField === 'name'} direction={sortDir} onClick={() => handleSort('name')}>Milestone</TableSortLabel></TableCell>
                <TableCell>Phase</TableCell>
                <TableCell><TableSortLabel active={sortField === 'planned_date'} direction={sortDir} onClick={() => handleSort('planned_date')}>Planned Date</TableSortLabel></TableCell>
                <TableCell>Actual Date</TableCell>
                <TableCell><TableSortLabel active={sortField === 'delay_days'} direction={sortDir} onClick={() => handleSort('delay_days')}>Delay</TableSortLabel></TableCell>
                <TableCell>Critical</TableCell>
                <TableCell>Status</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filtered.map((m, i) => (
                <TableRow key={m.id || i} hover sx={m.delay_days > 0 ? { bgcolor: '#fff8e1' } : {}}>
                  <TableCell><Typography variant="body2" fontWeight={600}>M-{String(m.id).padStart(3, '0')}</Typography></TableCell>
                  <TableCell><Typography fontWeight={600}>{m.name}</Typography></TableCell>
                  <TableCell><Chip label={m.phase || '-'} size="small" variant="outlined" /></TableCell>
                  <TableCell>{m.planned_date}</TableCell>
                  <TableCell>{m.actual_date || '-'}</TableCell>
                  <TableCell>
                    {m.delay_days > 0
                      ? <Chip label={`+${m.delay_days}d`} size="small" sx={{ bgcolor: '#ffebee', color: '#d32f2f', fontWeight: 700 }} />
                      : <Typography variant="body2" color="success.main">0</Typography>}
                  </TableCell>
                  <TableCell>{m.is_critical ? <Chip label="Critical" size="small" color="error" /> : '-'}</TableCell>
                  <TableCell><StatusChip status={m.status} /></TableCell>
                </TableRow>
              ))}
              {filtered.length === 0 && <TableRow><TableCell colSpan={8} align="center">No milestones match filters</TableCell></TableRow>}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>
    </Box>
  );
}

/* =========================================================================
   3. EARNED VALUE REPORT
   ========================================================================= */
function EarnedValueReport({ data, projectLabel }) {
  if (!data) return null;
  const ev = data.ev_metrics;
  const sCurveData = data.s_curve_data || [];
  const varianceData = data.variance_trend || [];

  const handleExport = () => {
    const metricsRows = [
      { Metric: 'BAC (Budget at Completion)', Formula: '—', Value: ev.bac },
      { Metric: 'PV (Planned Value)', Formula: 'Time-phased BAC', Value: ev.pv },
      { Metric: 'EV (Earned Value)', Formula: 'BAC × % Complete', Value: ev.ev },
      { Metric: 'AC (Actual Cost)', Formula: '—', Value: ev.ac },
      { Metric: 'CV (Cost Variance)', Formula: 'EV - AC', Value: ev.cv },
      { Metric: 'SV (Schedule Variance)', Formula: 'EV - PV', Value: ev.sv },
      { Metric: 'CPI', Formula: 'EV / AC', Value: ev.cpi },
      { Metric: 'SPI', Formula: 'EV / PV', Value: ev.spi },
      { Metric: 'EAC (Estimate at Completion)', Formula: 'BAC / CPI', Value: ev.eac },
      { Metric: 'VAC (Variance at Completion)', Formula: 'BAC - EAC', Value: ev.vac },
    ];
    const timeRows = sCurveData.map(d => ({
      Month: d.month,
      'PV (Planned Value)': d.PV,
      'EV (Earned Value)': d.EV,
      'AC (Actual Cost)': d.AC ?? '',
    }));
    downloadCSV([...metricsRows, {}, ...timeRows], `Earned_Value_Report_${projectLabel}.csv`);
  };

  const cpiStatus = ev.cpi >= 1 ? 'Under Budget' : 'Over Budget';
  const spiStatus = ev.spi >= 1 ? 'Ahead of Schedule' : 'Behind Schedule';

  return (
    <Box>
      {/* Export Button */}
      <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 2 }}>
        <Button variant="contained" startIcon={<Download />} onClick={handleExport}
          sx={{ bgcolor: '#1a2332', '&:hover': { bgcolor: '#2d3e50' } }} size="small">
          Export EV Report
        </Button>
      </Box>

      {/* KPI Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        {[
          { label: 'CPI', value: ev.cpi.toFixed(2), sub: cpiStatus, color: ev.cpi >= 1 ? '#2e7d32' : '#d32f2f' },
          { label: 'SPI', value: ev.spi.toFixed(2), sub: spiStatus, color: ev.spi >= 1 ? '#2e7d32' : '#d32f2f' },
          { label: 'Cost Variance (CV)', value: `£${ev.cv.toLocaleString()}`, sub: ev.cv >= 0 ? 'Favourable' : 'Unfavourable', color: ev.cv >= 0 ? '#2e7d32' : '#d32f2f' },
          { label: 'Schedule Variance (SV)', value: `£${ev.sv.toLocaleString()}`, sub: ev.sv >= 0 ? 'Favourable' : 'Unfavourable', color: ev.sv >= 0 ? '#2e7d32' : '#d32f2f' },
          { label: 'EAC', value: `£${ev.eac.toLocaleString()}`, sub: 'Estimate at Completion', color: '#1565c0' },
          { label: 'VAC', value: `£${ev.vac.toLocaleString()}`, sub: 'Variance at Completion', color: ev.vac >= 0 ? '#2e7d32' : '#d32f2f' },
        ].map((kpi, i) => (
          <Grid item xs={6} sm={4} md={2} key={i}>
            <Card><CardContent sx={{ textAlign: 'center', py: 2 }}>
              <Typography variant="h5" fontWeight={700} sx={{ color: kpi.color }}>{kpi.value}</Typography>
              <Typography variant="body2" fontWeight={600}>{kpi.label}</Typography>
              <Typography variant="caption" color="text.secondary">{kpi.sub}</Typography>
            </CardContent></Card>
          </Grid>
        ))}
      </Grid>

      {/* Interpretation Indicators */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6}>
          <Alert severity={ev.cpi >= 1 ? 'success' : 'error'} variant="outlined">
            <strong>Cost Performance:</strong> CPI = {ev.cpi.toFixed(2)} — {ev.cpi >= 1 ? 'Project is under budget. Cost efficiency is good.' : 'Project is over budget. Cost corrective action needed.'}
          </Alert>
        </Grid>
        <Grid item xs={12} sm={6}>
          <Alert severity={ev.spi >= 1 ? 'success' : 'error'} variant="outlined">
            <strong>Schedule Performance:</strong> SPI = {ev.spi.toFixed(2)} — {ev.spi >= 1 ? 'Project is ahead of schedule.' : 'Project is behind schedule. Recovery plan needed.'}
          </Alert>
        </Grid>
      </Grid>

      {/* S-Curve Chart */}
      <Paper sx={{ p: 3, mb: 3, height: 440 }}>
        <Typography variant="h6" fontWeight={600} mb={2}>Earned Value S-Curve</Typography>
        <ResponsiveContainer width="100%" height="85%">
          <ComposedChart data={sCurveData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="month" tick={{ fontSize: 10 }} />
            <YAxis tickFormatter={v => `£${(v / 1e6).toFixed(1)}M`} />
            <RTooltip formatter={v => v != null ? `£${v.toLocaleString()}` : '-'} />
            <Legend />
            <Area type="monotone" dataKey="PV" name="PV (Planned Value)" fill="#bbdefb" stroke="none" fillOpacity={0.3} />
            <Line type="monotone" dataKey="PV" name="PV (Planned Value)" stroke="#1565c0" strokeWidth={3} dot={{ r: 3 }} />
            <Line type="monotone" dataKey="EV" name="EV (Earned Value)" stroke="#2e7d32" strokeWidth={3} dot={{ r: 3, fill: '#2e7d32' }} />
            <Line type="monotone" dataKey="AC" name="AC (Actual Cost)" stroke="#c62828" strokeWidth={3} strokeDasharray="6 3" dot={{ r: 3 }} connectNulls={false} />
          </ComposedChart>
        </ResponsiveContainer>
      </Paper>

      {/* Variance Trend Chart */}
      {varianceData.length > 0 && (
        <Paper sx={{ p: 3, mb: 3, height: 360 }}>
          <Typography variant="h6" fontWeight={600} mb={2}>Variance Trend (CV & SV)</Typography>
          <ResponsiveContainer width="100%" height="85%">
            <ComposedChart data={varianceData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" tick={{ fontSize: 10 }} />
              <YAxis tickFormatter={v => `£${(v / 1e6).toFixed(1)}M`} />
              <RTooltip formatter={v => v != null ? `£${v.toLocaleString()}` : '-'} />
              <Legend />
              <ReferenceLine y={0} stroke="#666" strokeDasharray="3 3" label="Baseline" />
              <Area type="monotone" dataKey="CV" name="Cost Variance" fill="#c8e6c9" stroke="#2e7d32" fillOpacity={0.4} strokeWidth={2} />
              <Area type="monotone" dataKey="SV" name="Schedule Variance" fill="#bbdefb" stroke="#1565c0" fillOpacity={0.3} strokeWidth={2} />
            </ComposedChart>
          </ResponsiveContainer>
        </Paper>
      )}

      {/* EV Summary Table */}
      <Paper sx={{ p: 3 }}>
        <Typography variant="h6" fontWeight={600} mb={2}>Earned Value Metrics Summary</Typography>
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>Metric</TableCell>
                <TableCell>Abbreviation</TableCell>
                <TableCell>Formula</TableCell>
                <TableCell align="right">Value</TableCell>
                <TableCell>Interpretation</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {[
                ['Budget at Completion', 'BAC', '—', `£${ev.bac.toLocaleString()}`, 'Total approved budget'],
                ['Planned Value', 'PV (BCWS)', 'Time-phased BAC', `£${ev.pv.toLocaleString()}`, 'Value of work planned to date'],
                ['Earned Value', 'EV (BCWP)', 'BAC × % Complete', `£${ev.ev.toLocaleString()}`, 'Value of work performed'],
                ['Actual Cost', 'AC (ACWP)', '—', `£${ev.ac.toLocaleString()}`, 'Actual expenditure to date'],
                ['Cost Variance', 'CV', 'EV - AC', `£${ev.cv.toLocaleString()}`, ev.cv >= 0 ? 'Under budget' : 'Over budget'],
                ['Schedule Variance', 'SV', 'EV - PV', `£${ev.sv.toLocaleString()}`, ev.sv >= 0 ? 'Ahead of schedule' : 'Behind schedule'],
                ['Cost Performance Index', 'CPI', 'EV / AC', ev.cpi.toFixed(3), ev.cpi >= 1 ? 'Efficient' : 'Inefficient'],
                ['Schedule Performance Index', 'SPI', 'EV / PV', ev.spi.toFixed(3), ev.spi >= 1 ? 'Efficient' : 'Inefficient'],
                ['Estimate at Completion', 'EAC', 'BAC / CPI', `£${ev.eac.toLocaleString()}`, 'Forecast total cost'],
                ['Variance at Completion', 'VAC', 'BAC - EAC', `£${ev.vac.toLocaleString()}`, ev.vac >= 0 ? 'Under budget at end' : 'Over budget at end'],
              ].map(([metric, abbr, formula, value, interp], i) => (
                <TableRow key={i} hover>
                  <TableCell><Typography fontWeight={600}>{metric}</Typography></TableCell>
                  <TableCell><Chip label={abbr} size="small" variant="outlined" /></TableCell>
                  <TableCell><Typography variant="caption" color="text.secondary">{formula}</Typography></TableCell>
                  <TableCell align="right"><Typography fontWeight={600}>{value}</Typography></TableCell>
                  <TableCell>
                    <Typography variant="body2" color={
                      interp.includes('Over') || interp.includes('Behind') || interp.includes('Inefficient') ? 'error.main' : 'success.main'
                    }>{interp}</Typography>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>
    </Box>
  );
}

/* =========================================================================
   4. ISSUES / RISK REPORT
   ========================================================================= */
function IssuesRiskReport({ data, projectLabel }) {
  const risks = data.risks || [];
  const issues = data.issues || [];
  const riskSummary = data.risk_summary || {};
  const issueSummary = data.issue_summary || {};

  const [riskOwnerFilter, setRiskOwnerFilter] = useState('');
  const [riskStatusFilter, setRiskStatusFilter] = useState('');
  const [issueOwnerFilter, setIssueOwnerFilter] = useState('');
  const [issuePriorityFilter, setIssuePriorityFilter] = useState('');
  const [issueStatusFilter, setIssueStatusFilter] = useState('');

  const handleExport = () => {
    const riskRows = risks.map(r => ({
      'Risk ID': `R-${String(r.id).padStart(3, '0')}`,
      Title: r.title,
      Category: r.category || '',
      Probability: r.probability,
      Impact: r.impact,
      Score: r.risk_score,
      'Cost Exposure': r.cost_exposure || 0,
      Owner: r.owner || '',
      'Mitigation Plan': r.mitigation_plan || '',
      Status: r.status,
    }));
    const issueRows = issues.map(i => ({
      'Issue ID': `I-${String(i.id).padStart(3, '0')}`,
      Title: i.title,
      Priority: i.priority,
      'Assigned To': i.assigned_to || '',
      'Raised Date': i.raised_date || '',
      'Due Date': i.due_date || '',
      Overdue: i.is_overdue ? 'Yes' : 'No',
      Status: i.status,
    }));
    if (riskRows.length) downloadCSV(riskRows, `Risk_Register_${projectLabel}.csv`);
    if (issueRows.length) downloadCSV(issueRows, `Issue_Log_${projectLabel}.csv`);
  };

  // Risk computed
  const openRisks = risks.filter(r => r.status === 'Open' || r.status === 'Mitigating');
  const highRisks = risks.filter(r => r.risk_score >= 15);
  const totalExposure = risks.filter(r => r.status !== 'Closed').reduce((s, r) => s + ((r.probability / 5) * (r.cost_exposure || 0)), 0);
  const top5 = riskSummary.top_risks || [];

  // Unique filter values
  const riskOwners = [...new Set(risks.map(r => r.owner).filter(Boolean))];
  const issueOwners = [...new Set(issues.map(i => i.assigned_to).filter(Boolean))];

  // Heatmap data (5x5 grid)
  const heatmapData = [];
  for (let p = 5; p >= 1; p--) {
    const row = { probability: p };
    for (let imp = 1; imp <= 5; imp++) {
      row[`i${imp}`] = risks.filter(r => r.probability === p && r.impact === imp).length;
    }
    heatmapData.push(row);
  }

  // Risk by category pie
  const riskCatData = (riskSummary.categories || []).map(c => ({ name: c.category, value: c.count }));

  // Issue status pie
  const issueStatusData = (issueSummary.status_breakdown || []).map(s => ({ name: s.status, value: s.count }));
  const issueStatusColors = { Open: '#ef5350', 'In Progress': '#ffa726', Resolved: '#66bb6a', Closed: '#bdbdbd' };

  // Issue priority bar
  const priorityData = (issueSummary.priority_breakdown || []).map(p => ({ name: p.priority, value: p.count }));
  const priorityColors = { Critical: '#d32f2f', High: '#ff9800', Medium: '#fdd835', Low: '#66bb6a' };

  // Overdue issues
  const overdueIssues = issues.filter(i => i.is_overdue);

  // Filtered risks
  const filteredRisks = useMemo(() => {
    let r = [...risks];
    if (riskOwnerFilter) r = r.filter(x => x.owner === riskOwnerFilter);
    if (riskStatusFilter) r = r.filter(x => x.status === riskStatusFilter);
    return r.sort((a, b) => b.risk_score - a.risk_score);
  }, [risks, riskOwnerFilter, riskStatusFilter]);

  // Filtered issues
  const filteredIssues = useMemo(() => {
    let r = [...issues];
    if (issueOwnerFilter) r = r.filter(x => x.assigned_to === issueOwnerFilter);
    if (issuePriorityFilter) r = r.filter(x => x.priority === issuePriorityFilter);
    if (issueStatusFilter) r = r.filter(x => x.status === issueStatusFilter);
    const pOrder = { Critical: 0, High: 1, Medium: 2, Low: 3 };
    return r.sort((a, b) => (pOrder[a.priority] ?? 4) - (pOrder[b.priority] ?? 4));
  }, [issues, issueOwnerFilter, issuePriorityFilter, issueStatusFilter]);

  return (
    <Box>
      {/* Export Button */}
      <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 2 }}>
        <Button variant="contained" startIcon={<Download />} onClick={handleExport}
          sx={{ bgcolor: '#1a2332', '&:hover': { bgcolor: '#2d3e50' } }} size="small">
          Export Issues & Risk Report
        </Button>
      </Box>

      {/* ============ RISK SECTION ============ */}
      <Typography variant="h6" fontWeight={700} sx={{ mb: 2, borderBottom: '2px solid #d32f2f', pb: 1 }}>
        Risk Dashboard
      </Typography>

      {/* Risk KPI Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        {[
          { label: 'Open Risks', value: openRisks.length, color: '#d32f2f' },
          { label: 'High Risks (Score >= 15)', value: highRisks.length, color: '#e65100' },
          { label: 'Total Risk Exposure', value: `£${Math.round(totalExposure).toLocaleString()}`, color: '#7b1fa2' },
          { label: 'Total Risks', value: risks.length, color: '#1565c0' },
        ].map((kpi, i) => (
          <Grid item xs={6} sm={3} key={i}>
            <Card><CardContent sx={{ textAlign: 'center', py: 2 }}>
              <Typography variant="h4" fontWeight={700} sx={{ color: kpi.color }}>{kpi.value}</Typography>
              <Typography variant="body2" color="text.secondary">{kpi.label}</Typography>
            </CardContent></Card>
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3} sx={{ mb: 3 }}>
        {/* Risk Heatmap Table */}
        <Grid item xs={12} md={5}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="subtitle1" fontWeight={600} mb={2}>Risk Heat Map (P x I)</Typography>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell sx={{ fontWeight: 700 }}>P \ I</TableCell>
                  {[1, 2, 3, 4, 5].map(i => <TableCell key={i} align="center" sx={{ fontWeight: 700 }}>{i}</TableCell>)}
                </TableRow>
              </TableHead>
              <TableBody>
                {heatmapData.map((row) => (
                  <TableRow key={row.probability}>
                    <TableCell sx={{ fontWeight: 700 }}>{row.probability}</TableCell>
                    {[1, 2, 3, 4, 5].map(imp => {
                      const score = row.probability * imp;
                      const count = row[`i${imp}`];
                      const bg = score >= 15 ? '#ef5350' : score >= 8 ? '#ffa726' : score >= 4 ? '#fff59d' : '#c8e6c9';
                      return (
                        <TableCell key={imp} align="center"
                          sx={{ bgcolor: bg, fontWeight: count ? 700 : 400, color: score >= 15 ? '#fff' : '#000', minWidth: 40 }}>
                          {count || '-'}
                        </TableCell>
                      );
                    })}
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Paper>
        </Grid>

        {/* Top 5 Risk Cards */}
        <Grid item xs={12} md={3}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="subtitle1" fontWeight={600} mb={2}>Top 5 Risks</Typography>
            <Stack spacing={1.5}>
              {top5.map((r, i) => (
                <Box key={r.id} sx={{ p: 1.5, borderRadius: 1, bgcolor: '#fafafa', borderLeft: `4px solid ${r.risk_score >= 15 ? '#d32f2f' : '#ff9800'}` }}>
                  <Typography variant="body2" fontWeight={600}>{i + 1}. {r.title}</Typography>
                  <Stack direction="row" spacing={1} mt={0.5}>
                    <Chip label={`Score: ${r.risk_score}`} size="small"
                      sx={{ bgcolor: r.risk_score >= 15 ? '#d32f2f' : '#ff9800', color: '#fff', fontWeight: 700, height: 22, fontSize: 11 }} />
                    <Chip label={`£${(r.cost_exposure || 0).toLocaleString()}`} size="small" variant="outlined" sx={{ height: 22, fontSize: 11 }} />
                  </Stack>
                </Box>
              ))}
              {top5.length === 0 && <Typography color="text.secondary" variant="body2">No risks</Typography>}
            </Stack>
          </Paper>
        </Grid>

        {/* Risk Category Pie */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: 340 }}>
            <Typography variant="subtitle1" fontWeight={600} mb={2}>Risk by Category</Typography>
            {riskCatData.length > 0 ? (
              <ResponsiveContainer width="100%" height="85%">
                <PieChart>
                  <Pie data={riskCatData} dataKey="value" nameKey="name" cx="50%" cy="50%"
                    innerRadius={45} outerRadius={95} label>
                    {riskCatData.map((_, i) => <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />)}
                  </Pie>
                  <RTooltip /><Legend />
                </PieChart>
              </ResponsiveContainer>
            ) : <EmptyState text="No risk data" />}
          </Paper>
        </Grid>
      </Grid>

      {/* Risk Filters + Table */}
      <Paper sx={{ p: 2, mb: 1 }}>
        <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap">
          <FilterList color="action" />
          <TextField select label="Owner" value={riskOwnerFilter} size="small" sx={{ minWidth: 150 }}
            onChange={e => setRiskOwnerFilter(e.target.value)}>
            <MenuItem value="">All Owners</MenuItem>
            {riskOwners.map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
          </TextField>
          <TextField select label="Status" value={riskStatusFilter} size="small" sx={{ minWidth: 140 }}
            onChange={e => setRiskStatusFilter(e.target.value)}>
            <MenuItem value="">All</MenuItem>
            {['Open', 'Mitigating', 'Closed'].map(s => <MenuItem key={s} value={s}>{s}</MenuItem>)}
          </TextField>
          <Typography variant="body2" color="text.secondary">{filteredRisks.length} risks</Typography>
        </Stack>
      </Paper>
      <Paper sx={{ p: 3, mb: 4 }}>
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>Risk ID</TableCell>
                <TableCell>Title</TableCell>
                <TableCell>Category</TableCell>
                <TableCell align="center">P</TableCell>
                <TableCell align="center">I</TableCell>
                <TableCell align="center">Score</TableCell>
                <TableCell align="right">Cost Exposure</TableCell>
                <TableCell>Owner</TableCell>
                <TableCell>Mitigation</TableCell>
                <TableCell>Status</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredRisks.map((r) => (
                <TableRow key={r.id} hover>
                  <TableCell><Typography fontWeight={600}>R-{String(r.id).padStart(3, '0')}</Typography></TableCell>
                  <TableCell>{r.title}</TableCell>
                  <TableCell><Chip label={r.category} size="small" variant="outlined" /></TableCell>
                  <TableCell align="center">{r.probability}</TableCell>
                  <TableCell align="center">{r.impact}</TableCell>
                  <TableCell align="center">
                    <Chip label={r.risk_score} size="small" sx={{ bgcolor: r.risk_score >= 15 ? '#d32f2f' : r.risk_score >= 8 ? '#ed6c02' : '#2e7d32', color: '#fff', fontWeight: 700 }} />
                  </TableCell>
                  <TableCell align="right">£{(r.cost_exposure || 0).toLocaleString()}</TableCell>
                  <TableCell>{r.owner || '-'}</TableCell>
                  <TableCell><Typography variant="caption" sx={{ maxWidth: 180, display: 'block', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{r.mitigation_plan || '-'}</Typography></TableCell>
                  <TableCell>
                    <Chip label={r.status} size="small" variant="outlined"
                      color={r.status === 'Closed' ? 'success' : r.status === 'Mitigating' ? 'warning' : 'error'} />
                  </TableCell>
                </TableRow>
              ))}
              {filteredRisks.length === 0 && <TableRow><TableCell colSpan={10} align="center">No risks</TableCell></TableRow>}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      {/* ============ ISSUE SECTION ============ */}
      <Typography variant="h6" fontWeight={700} sx={{ mb: 2, borderBottom: '2px solid #ed6c02', pb: 1 }}>
        Issue Dashboard
      </Typography>

      {/* Issue KPI Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        {[
          { label: 'Total Open Issues', value: issueSummary.open_count + issueSummary.in_progress, color: '#ed6c02' },
          { label: 'High Priority', value: issues.filter(i => i.priority === 'Critical' || i.priority === 'High').length, color: '#d32f2f' },
          { label: 'Overdue Issues', value: issueSummary.overdue, color: '#c62828' },
          { label: 'Total Issues', value: issueSummary.total, color: '#1565c0' },
        ].map((kpi, i) => (
          <Grid item xs={6} sm={3} key={i}>
            <Card><CardContent sx={{ textAlign: 'center', py: 2 }}>
              <Typography variant="h4" fontWeight={700} sx={{ color: kpi.color }}>{kpi.value}</Typography>
              <Typography variant="body2" color="text.secondary">{kpi.label}</Typography>
            </CardContent></Card>
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3} sx={{ mb: 3 }}>
        {/* Open vs Closed Pie */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: 340 }}>
            <Typography variant="subtitle1" fontWeight={600} mb={2}>Issue Status</Typography>
            {issueStatusData.length > 0 ? (
              <ResponsiveContainer width="100%" height="85%">
                <PieChart>
                  <Pie data={issueStatusData} dataKey="value" nameKey="name" cx="50%" cy="50%"
                    innerRadius={45} outerRadius={95} label>
                    {issueStatusData.map((e, i) => <Cell key={i} fill={issueStatusColors[e.name] || PIE_COLORS[i]} />)}
                  </Pie>
                  <RTooltip /><Legend />
                </PieChart>
              </ResponsiveContainer>
            ) : <EmptyState text="No issue data" />}
          </Paper>
        </Grid>

        {/* Priority Distribution */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: 340 }}>
            <Typography variant="subtitle1" fontWeight={600} mb={2}>Priority Distribution</Typography>
            {priorityData.length > 0 ? (
              <ResponsiveContainer width="100%" height="85%">
                <BarChart data={priorityData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis allowDecimals={false} />
                  <RTooltip />
                  <Bar dataKey="value" name="Issues" radius={[4, 4, 0, 0]}>
                    {priorityData.map((e, i) => <Cell key={i} fill={priorityColors[e.name] || PIE_COLORS[i]} />)}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            ) : <EmptyState text="No issue data" />}
          </Paper>
        </Grid>

        {/* Overdue List */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: 340, overflow: 'auto' }}>
            <Typography variant="subtitle1" fontWeight={600} mb={2}>
              Overdue Issues <Chip label={overdueIssues.length} size="small" color="error" sx={{ ml: 1 }} />
            </Typography>
            {overdueIssues.length > 0 ? (
              <Stack spacing={1}>
                {overdueIssues.slice(0, 8).map(iss => (
                  <Box key={iss.id} sx={{ p: 1.5, borderRadius: 1, bgcolor: '#fff8e1', borderLeft: '4px solid #ed6c02' }}>
                    <Typography variant="body2" fontWeight={600}>{iss.title}</Typography>
                    <Stack direction="row" spacing={1} mt={0.5}>
                      <Chip label={iss.priority} size="small"
                        sx={{ bgcolor: priorityColors[iss.priority], color: iss.priority === 'Low' || iss.priority === 'Medium' ? '#000' : '#fff', height: 20, fontSize: 11 }} />
                      <Typography variant="caption" color="text.secondary">Due: {iss.due_date}</Typography>
                    </Stack>
                  </Box>
                ))}
              </Stack>
            ) : <Typography color="text.secondary" variant="body2" sx={{ mt: 2 }}>No overdue issues</Typography>}
          </Paper>
        </Grid>
      </Grid>

      {/* Issue Filters + Table */}
      <Paper sx={{ p: 2, mb: 1 }}>
        <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap">
          <FilterList color="action" />
          <TextField select label="Owner" value={issueOwnerFilter} size="small" sx={{ minWidth: 150 }}
            onChange={e => setIssueOwnerFilter(e.target.value)}>
            <MenuItem value="">All Owners</MenuItem>
            {issueOwners.map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
          </TextField>
          <TextField select label="Priority" value={issuePriorityFilter} size="small" sx={{ minWidth: 130 }}
            onChange={e => setIssuePriorityFilter(e.target.value)}>
            <MenuItem value="">All</MenuItem>
            {['Critical', 'High', 'Medium', 'Low'].map(p => <MenuItem key={p} value={p}>{p}</MenuItem>)}
          </TextField>
          <TextField select label="Status" value={issueStatusFilter} size="small" sx={{ minWidth: 140 }}
            onChange={e => setIssueStatusFilter(e.target.value)}>
            <MenuItem value="">All</MenuItem>
            {['Open', 'In Progress', 'Resolved', 'Closed'].map(s => <MenuItem key={s} value={s}>{s}</MenuItem>)}
          </TextField>
          <Typography variant="body2" color="text.secondary">{filteredIssues.length} issues</Typography>
        </Stack>
      </Paper>
      <Paper sx={{ p: 3 }}>
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>Issue ID</TableCell>
                <TableCell>Title</TableCell>
                <TableCell>Priority</TableCell>
                <TableCell>Assigned To</TableCell>
                <TableCell>Raised</TableCell>
                <TableCell>Due Date</TableCell>
                <TableCell>Overdue</TableCell>
                <TableCell>Status</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredIssues.map((iss) => (
                <TableRow key={iss.id} hover sx={iss.is_overdue ? { bgcolor: '#fff8e1' } : {}}>
                  <TableCell><Typography fontWeight={600}>I-{String(iss.id).padStart(3, '0')}</Typography></TableCell>
                  <TableCell>{iss.title}</TableCell>
                  <TableCell>
                    <Chip label={iss.priority} size="small"
                      sx={{ bgcolor: priorityColors[iss.priority] || '#90caf9', color: iss.priority === 'Low' || iss.priority === 'Medium' ? '#000' : '#fff', fontWeight: 600 }} />
                  </TableCell>
                  <TableCell>{iss.assigned_to || '-'}</TableCell>
                  <TableCell>{iss.raised_date}</TableCell>
                  <TableCell>{iss.due_date || '-'}</TableCell>
                  <TableCell>{iss.is_overdue ? <Chip label="Overdue" size="small" color="error" /> : '-'}</TableCell>
                  <TableCell>
                    <Chip label={iss.status} size="small" variant="outlined"
                      color={iss.status === 'Closed' || iss.status === 'Resolved' ? 'success' : iss.status === 'In Progress' ? 'warning' : 'error'} />
                  </TableCell>
                </TableRow>
              ))}
              {filteredIssues.length === 0 && <TableRow><TableCell colSpan={8} align="center">No issues</TableCell></TableRow>}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>
    </Box>
  );
}

/* =========================================================================
   SHARED: Empty state placeholder
   ========================================================================= */
function EmptyState({ text }) {
  return (
    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '80%' }}>
      <Typography color="text.secondary">{text}</Typography>
    </Box>
  );
}
