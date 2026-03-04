import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Grid, Card, CardContent, Typography, Box, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Chip, CircularProgress, Tooltip,
  Collapse, IconButton, TextField, MenuItem,
} from '@mui/material';
import {
  Schedule, CurrencyPound, Warning, HealthAndSafety, TrendingUp,
  ExpandMore, ExpandLess,
} from '@mui/icons-material';
import {
  XAxis, YAxis, CartesianGrid, Tooltip as RTooltip,
  ResponsiveContainer, LineChart, Line, Legend,
} from 'recharts';
import KPICard from '../components/KPICard';
import RAGChip from '../components/RAGChip';
import {
  getDashboardSummary, getUpcomingMilestones, getPlannedVsActual,
  getCashflow, getPortfolioHealth, getDashboardRiskHeatmap,
  getDelayedMilestones, getOpenRisks, getProjects,
} from '../services/api';


export default function Dashboard() {
  const navigate = useNavigate();
  const [summary, setSummary] = useState(null);
  const [milestones, setMilestones] = useState([]);
  const [plannedVsActual, setPlannedVsActual] = useState([]);
  const [cashflow, setCashflow] = useState([]);
  const [portfolioHealth, setPortfolioHealth] = useState([]);
  const [heatmap, setHeatmap] = useState([]);
  const [delayedMilestonesList, setDelayedMilestonesList] = useState([]);
  const [openRisksList, setOpenRisksList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [projectsList, setProjectsList] = useState([]);
  const [selectedCostProject, setSelectedCostProject] = useState('');
  const [expandedPanel, setExpandedPanel] = useState(null); // 'risks' | 'upcoming' | 'delayed' | 'health' | null

  const togglePanel = (panel) => {
    setExpandedPanel((prev) => (prev === panel ? null : panel));
  };

  useEffect(() => {
    Promise.all([
      getDashboardSummary(),
      getUpcomingMilestones(),
      getPlannedVsActual(),
      getCashflow(),
      getPortfolioHealth(),
      getDashboardRiskHeatmap(),
      getDelayedMilestones(),
      getOpenRisks(),
      getProjects(),
    ]).then(([s, m, pva, c, ph, hm, dm, or_, proj]) => {
      setSummary(s.data);
      setMilestones(m.data);
      setPlannedVsActual(pva.data);
      setCashflow(c.data);
      setPortfolioHealth(ph.data);
      setHeatmap(hm.data);
      setDelayedMilestonesList(dm.data);
      setOpenRisksList(or_.data);
      setProjectsList(proj.data);
    }).finally(() => setLoading(false));
  }, []);

  const handleCostProjectChange = (projectId) => {
    setSelectedCostProject(projectId);
    getPlannedVsActual(projectId || undefined).then((res) => setPlannedVsActual(res.data));
  };

  if (loading) return <Box sx={{ display: 'flex', justifyContent: 'center', mt: 10 }}><CircularProgress /></Box>;

  const ragColor = (pct) => pct >= 90 ? '#2e7d32' : pct >= 75 ? '#ed6c02' : '#d32f2f';

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} sx={{ mb: 3 }}>My Dashboard</Typography>

      {/* KPI Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md>
          <KPICard title="Schedule Health" value={`${summary?.schedule_health_pct || 0}%`}
            icon={<Schedule />} color={ragColor(summary?.schedule_health_pct || 0)} subtitle="SPI-based index" />
        </Grid>
        <Grid item xs={12} sm={6} md>
          <KPICard title="Cost Health" value={`${summary?.cost_health_pct || 0}%`}
            icon={<CurrencyPound />} color={ragColor(summary?.cost_health_pct || 0)} subtitle="CPI-based index" />
        </Grid>
        <Grid item xs={12} sm={6} md>
          <KPICard title="Earned Value Performance" value={summary?.ev_performance ?? '1.00'}
            icon={<TrendingUp />}
            color={summary?.ev_performance >= 1.0 ? '#2e7d32' : summary?.ev_performance >= 0.85 ? '#ed6c02' : '#d32f2f'}
            subtitle="CPI (0 – 2)" />
        </Grid>
        <Grid item xs={12} sm={6} md>
          <KPICard title="Risk Exposure" value={`${summary?.open_risks || 0}`}
            icon={<Warning />} color={summary?.open_risks > 5 ? '#d32f2f' : '#ed6c02'} subtitle="Open risks across portfolio"
            onClick={() => togglePanel('risks')} />
        </Grid>
        <Grid item xs={12} sm={6} md>
          <KPICard title="Safety Score" value={`${summary?.safety_score || 0}%`}
            icon={<HealthAndSafety />} color={ragColor(summary?.safety_score || 0)} subtitle="Incident resolution rate" />
        </Grid>
      </Grid>

      {/* Stats Row */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        {[
          { label: 'Total Projects', val: summary?.total_projects, color: 'primary.main', onClick: () => navigate('/portfolio') },
          { label: 'Portfolio Health', val: portfolioHealth.length, color: '#2e7d32', onClick: () => togglePanel('health') },
          { label: 'Projects At Gate B', val: summary?.projects_gate_b ?? 0, color: '#2e7d32', onClick: () => togglePanel('gate_b') },
          { label: 'Projects At Gate C', val: summary?.projects_gate_c ?? 0, color: '#1565c0', onClick: () => togglePanel('gate_c') },
          { label: 'Design Completion', val: summary?.design_completion ?? 0, color: '#ed6c02', onClick: () => togglePanel('design_completion') },
          { label: 'Construction', val: summary?.construction ?? 0, color: '#9c27b0', onClick: () => togglePanel('construction') },
          { label: 'Commissioned', val: summary?.commissioned ?? 0, color: '#00838f', onClick: () => togglePanel('commissioned') },
          { label: 'Upcoming Milestones', val: milestones.length, color: '#1565c0', onClick: () => togglePanel('upcoming') },
          { label: 'Delayed Milestones', val: summary?.delayed_milestones, color: '#9c27b0', onClick: () => togglePanel('delayed') },
        ].map((s, i) => (
          <Grid item xs={6} sm={4} md key={i}>
            <Card
              sx={{
                textAlign: 'center',
                cursor: s.onClick ? 'pointer' : 'default',
                transition: 'transform 0.15s, box-shadow 0.15s',
                '&:hover': s.onClick ? { transform: 'translateY(-2px)', boxShadow: 4 } : {},
              }}
              onClick={s.onClick}
            >
              <CardContent sx={{ p: 1.5, '&:last-child': { pb: 1.5 } }}>
                <Typography variant="h5" fontWeight={700} sx={{ color: s.color }}>{s.val || 0}</Typography>
                <Typography variant="caption" color="text.secondary">{s.label}</Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* Accordion Panels */}
      <Collapse in={expandedPanel === 'risks'} timeout="auto">
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1 }}>
              <Typography variant="subtitle1" fontWeight={600}>Open Risks Across Portfolio</Typography>
              <IconButton size="small" onClick={() => setExpandedPanel(null)}><ExpandLess /></IconButton>
            </Box>
            <TableContainer sx={{ maxHeight: 320 }}>
              <Table size="small" stickyHeader>
                <TableHead>
                  <TableRow>
                    {['Code', 'Title', 'Project', 'Category', 'P', 'I', 'Score', 'Owner'].map(h => (
                      <TableCell key={h} sx={{ fontWeight: 600, fontSize: '0.78rem' }}>{h}</TableCell>
                    ))}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {openRisksList.map((r) => (
                    <TableRow key={r.id}>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{r.risk_code}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{r.title}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{r.project_name}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{r.category || '—'}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{r.probability}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{r.impact}</TableCell>
                      <TableCell>
                        <Chip label={r.risk_score} size="small"
                          sx={{ fontWeight: 700, bgcolor: r.risk_score >= 15 ? '#ffcdd2' : r.risk_score >= 8 ? '#fff9c4' : '#c8e6c9',
                                color: r.risk_score >= 15 ? '#c62828' : r.risk_score >= 8 ? '#f57f17' : '#2e7d32', fontSize: '0.75rem' }} />
                      </TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{r.owner || '—'}</TableCell>
                    </TableRow>
                  ))}
                  {openRisksList.length === 0 && (
                    <TableRow><TableCell colSpan={8} align="center">
                      <Typography variant="body2" color="text.secondary">No open risks</Typography>
                    </TableCell></TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </Card>
      </Collapse>

      <Collapse in={expandedPanel === 'upcoming'} timeout="auto">
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1 }}>
              <Typography variant="subtitle1" fontWeight={600}>Upcoming Milestones</Typography>
              <IconButton size="small" onClick={() => setExpandedPanel(null)}><ExpandLess /></IconButton>
            </Box>
            <TableContainer sx={{ maxHeight: 320 }}>
              <Table size="small" stickyHeader>
                <TableHead>
                  <TableRow>
                    {['Milestone', 'Project', 'Planned Date', ''].map(h => (
                      <TableCell key={h} sx={{ fontWeight: 600, fontSize: '0.78rem' }}>{h}</TableCell>
                    ))}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {milestones.map((m) => (
                    <TableRow key={m.id}>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{m.milestone_name}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{m.project_name}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{m.planned_date}</TableCell>
                      <TableCell>{m.is_critical && <Chip label="Critical" size="small" color="error" variant="outlined" />}</TableCell>
                    </TableRow>
                  ))}
                  {milestones.length === 0 && (
                    <TableRow><TableCell colSpan={4} align="center">
                      <Typography variant="body2" color="text.secondary">No upcoming milestones</Typography>
                    </TableCell></TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </Card>
      </Collapse>

      <Collapse in={expandedPanel === 'delayed'} timeout="auto">
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1 }}>
              <Typography variant="subtitle1" fontWeight={600}>Delayed Milestones</Typography>
              <IconButton size="small" onClick={() => setExpandedPanel(null)}><ExpandLess /></IconButton>
            </Box>
            <TableContainer sx={{ maxHeight: 320 }}>
              <Table size="small" stickyHeader>
                <TableHead>
                  <TableRow>
                    {['Milestone', 'Project', 'Planned Date', 'Actual Date', 'Delay (days)', ''].map(h => (
                      <TableCell key={h} sx={{ fontWeight: 600, fontSize: '0.78rem' }}>{h}</TableCell>
                    ))}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {delayedMilestonesList.map((m) => (
                    <TableRow key={m.id}>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{m.milestone_name}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{m.project_name}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{m.planned_date}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{m.actual_date}</TableCell>
                      <TableCell>
                        <Chip label={`${m.delay_days}d`} size="small" color="warning" variant="outlined" sx={{ fontSize: '0.75rem' }} />
                      </TableCell>
                      <TableCell>{m.is_critical && <Chip label="Critical" size="small" color="error" variant="outlined" />}</TableCell>
                    </TableRow>
                  ))}
                  {delayedMilestonesList.length === 0 && (
                    <TableRow><TableCell colSpan={6} align="center">
                      <Typography variant="body2" color="text.secondary">No delayed milestones</Typography>
                    </TableCell></TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </Card>
      </Collapse>

      <Collapse in={expandedPanel === 'health'} timeout="auto">
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1 }}>
              <Typography variant="subtitle1" fontWeight={600}>Portfolio Health Summary</Typography>
              <IconButton size="small" onClick={() => setExpandedPanel(null)}><ExpandLess /></IconButton>
            </Box>
            <TableContainer sx={{ maxHeight: 420 }}>
              <Table size="small" stickyHeader>
                <TableHead>
                  <TableRow>
                    {['Project', 'Schedule', 'Cost', 'Risk', 'Overall', 'SPI', 'CPI'].map(h => (
                      <TableCell key={h} sx={{ fontWeight: 600, fontSize: '0.78rem' }}>{h}</TableCell>
                    ))}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {portfolioHealth.map((p) => (
                    <TableRow key={p.project_id} hover>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{p.project_name}</TableCell>
                      <TableCell><RAGChip status={p.schedule_health} /></TableCell>
                      <TableCell><RAGChip status={p.cost_health} /></TableCell>
                      <TableCell><RAGChip status={p.risk_level} /></TableCell>
                      <TableCell><RAGChip status={p.overall_status} /></TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{p.spi}</TableCell>
                      <TableCell sx={{ fontSize: '0.78rem' }}>{p.cpi}</TableCell>
                    </TableRow>
                  ))}
                  {portfolioHealth.length === 0 && (
                    <TableRow><TableCell colSpan={7} align="center">
                      <Typography variant="body2" color="text.secondary">No portfolio health data</Typography>
                    </TableCell></TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </Card>
      </Collapse>


      {/* Phase-based Project Accordion Panels */}
      {[
        { key: 'gate_b', title: 'Projects At Gate B', phase: 'gate b', color: '#2e7d32' },
        { key: 'gate_c', title: 'Projects At Gate C', phase: 'gate c', color: '#1565c0' },
        { key: 'design_completion', title: 'Design Completion', phase: 'design completion', color: '#ed6c02' },
        { key: 'construction', title: 'Construction', phase: 'construction', color: '#9c27b0' },
        { key: 'commissioned', title: 'Commissioned', phase: 'commissioned', color: '#00838f' },
      ].map(({ key, title, phase, color }) => {
        const filtered = projectsList.filter(p => (p.phase || '').toLowerCase() === phase);
        return (
          <Collapse key={key} in={expandedPanel === key} timeout="auto">
            <Card sx={{ mb: 3, borderLeft: `4px solid ${color}` }}>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1 }}>
                  <Typography variant="subtitle1" fontWeight={600}>{title}</Typography>
                  <IconButton size="small" onClick={() => setExpandedPanel(null)}><ExpandLess /></IconButton>
                </Box>
                <TableContainer sx={{ maxHeight: 320 }}>
                  <Table size="small" stickyHeader>
                    <TableHead>
                      <TableRow>
                        {['Code', 'Project Name', 'Client', 'Project Manager', 'Status', 'Start Date', 'End Date', 'Budget (£)'].map(h => (
                          <TableCell key={h} sx={{ fontWeight: 600, fontSize: '0.78rem' }}>{h}</TableCell>
                        ))}
                      </TableRow>
                    </TableHead>
                    <TableBody>
                      {filtered.map((p) => (
                        <TableRow key={p.id} hover sx={{ cursor: 'pointer' }}>
                          <TableCell sx={{ fontSize: '0.78rem' }}>{p.code || '—'}</TableCell>
                          <TableCell sx={{ fontSize: '0.78rem', fontWeight: 500 }}>{p.name}</TableCell>
                          <TableCell sx={{ fontSize: '0.78rem' }}>{p.client || '—'}</TableCell>
                          <TableCell sx={{ fontSize: '0.78rem' }}>{p.project_manager || '—'}</TableCell>
                          <TableCell>
                            <Chip label={p.status || 'Active'} size="small"
                              color={p.status === 'At Risk' ? 'error' : p.status === 'Completed' ? 'success' : 'primary'}
                              variant="outlined" sx={{ fontSize: '0.72rem' }} />
                          </TableCell>
                          <TableCell sx={{ fontSize: '0.78rem' }}>{p.start_date || '—'}</TableCell>
                          <TableCell sx={{ fontSize: '0.78rem' }}>{p.end_date || '—'}</TableCell>
                          <TableCell sx={{ fontSize: '0.78rem' }}>
                            {p.total_budget ? `£${Number(p.total_budget).toLocaleString()}` : '—'}
                          </TableCell>
                        </TableRow>
                      ))}
                      {filtered.length === 0 && (
                        <TableRow><TableCell colSpan={8} align="center">
                          <Typography variant="body2" color="text.secondary">No projects in this phase</Typography>
                        </TableCell></TableRow>
                      )}
                    </TableBody>
                  </Table>
                </TableContainer>
              </CardContent>
            </Card>
          </Collapse>
        );
      })}

      {/* Charts Row 1: Planned Cost vs Actual Cost */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant="subtitle1" fontWeight={600}>Planned Cost Vs Actual Cost</Typography>
                <TextField
                  select
                  size="small"
                  value={selectedCostProject}
                  onChange={(e) => handleCostProjectChange(e.target.value)}
                  sx={{ minWidth: 200 }}
                  label="Project"
                >
                  <MenuItem value="">All Projects</MenuItem>
                  {projectsList.map((p) => (
                    <MenuItem key={p.id} value={p.id}>{p.name}</MenuItem>
                  ))}
                </TextField>
              </Box>
              <ResponsiveContainer width="100%" height={340}>
                <LineChart data={plannedVsActual}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="month" tick={{ fontSize: 11 }} />
                  <YAxis tick={{ fontSize: 11 }} tickFormatter={(v) => `£${(v/1000).toFixed(0)}k`} />
                  <RTooltip formatter={(v) => `£${Number(v).toLocaleString()}`} />
                  <Legend />
                  <Line type="monotone" dataKey="planned" name="Planned Cost" stroke="#1976d2"
                    strokeWidth={2} dot={false} />
                  <Line type="monotone" dataKey="actual" name="Actual Cost" stroke="#d32f2f"
                    strokeWidth={2} dot={false} />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Charts Row 2: Cashflow + Risk Heatmap */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} md={7}>
          <Card>
            <CardContent>
              <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 2 }}>Cashflow Curve</Typography>
              <ResponsiveContainer width="100%" height={280}>
                <LineChart data={cashflow}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="month" tick={{ fontSize: 11 }} />
                  <YAxis tick={{ fontSize: 11 }} tickFormatter={(v) => `£${(v/1000).toFixed(0)}k`} />
                  <RTooltip formatter={(v) => `£${Number(v).toLocaleString()}`} />
                  <Legend />
                  <Line type="monotone" dataKey="expected" name="Expected" stroke="#64b5f6" strokeWidth={2} dot={false} />
                  <Line type="monotone" dataKey="received" name="Received" stroke="#81c784" strokeWidth={2} dot={false} />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={5}>
          <Card sx={{ height: '100%' }}>
            <CardContent>
              <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 2 }}>Risk Heat Map</Typography>
              <Box sx={{ display: 'flex', gap: 0.5, mb: 1, ml: 4 }}>
                {[1,2,3,4,5].map(i => (
                  <Typography key={i} variant="caption" sx={{ width: 44, textAlign: 'center', fontWeight: 600 }}>{i}</Typography>
                ))}
              </Box>
              {[5,4,3,2,1].map(p => (
                <Box key={p} sx={{ display: 'flex', gap: 0.5, mb: 0.5, alignItems: 'center' }}>
                  <Typography variant="caption" sx={{ width: 30, textAlign: 'right', fontWeight: 600 }}>{p}</Typography>
                  {[1,2,3,4,5].map(i => {
                    const cell = heatmap.find(h => h.probability === p && h.impact === i);
                    const count = cell?.count || 0;
                    const score = p * i;
                    let bg = '#e8f5e9';
                    if (score >= 15) bg = '#ffcdd2';
                    else if (score >= 8) bg = '#fff9c4';
                    else if (score >= 4) bg = '#c8e6c9';
                    return (
                      <Tooltip key={`${p}-${i}`} title={`P${p} x I${i} = ${score} | ${count} risk(s)`}>
                        <Box sx={{ width: 44, height: 36, bgcolor: bg, borderRadius: 1,
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                          border: '1px solid #e0e0e0' }}>
                          <Typography variant="caption" fontWeight={count > 0 ? 700 : 400}>
                            {count > 0 ? count : ''}
                          </Typography>
                        </Box>
                      </Tooltip>
                    );
                  })}
                </Box>
              ))}
              <Typography variant="caption" color="text.secondary" sx={{ ml: 4 }}>Impact →</Typography>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>↑ Probability</Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
