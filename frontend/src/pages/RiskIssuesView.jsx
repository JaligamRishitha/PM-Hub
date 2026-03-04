import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Typography, Card, CardContent, Grid, Button, Tabs, Tab, Table, TableBody,
  TableCell, TableContainer, TableHead, TableRow, Chip, IconButton, MenuItem,
  TextField, Dialog, DialogTitle, DialogContent, DialogActions, CircularProgress,
  Tooltip, Select, FormControl, InputLabel,
} from '@mui/material';
import { Add, Edit, Delete, Warning, BugReport } from '@mui/icons-material';
import {
  getRisks, getIssues, getRiskHeatmap, getTopRisks, getOverdueIssues,
  createRisk, updateRisk, deleteRisk, createIssue, updateIssue, deleteIssue,
} from '../services/api';
import { useProject } from '../context/ProjectContext';

const RISK_CATEGORIES = ['Technical', 'Commercial', 'Schedule', 'Safety', 'Environmental', 'Legal', 'Resource'];
const PRIORITIES = ['Critical', 'High', 'Medium', 'Low'];

export default function RiskIssuesView() {
  const { selectedProjectId, projects } = useProject();
  const projectId = selectedProjectId || '';
  const [tab, setTab] = useState(0);
  const [risks, setRisks] = useState([]);
  const [issues, setIssues] = useState([]);
  const [heatmap, setHeatmap] = useState([]);
  const [topRisks, setTopRisks] = useState([]);
  const [overdueIssues, setOverdueIssues] = useState([]);
  const [loading, setLoading] = useState(true);
  const [riskDialog, setRiskDialog] = useState(false);
  const [issueDialog, setIssueDialog] = useState(false);
  const [editItem, setEditItem] = useState(null);
  const [riskForm, setRiskForm] = useState({
    risk_code: '', title: '', description: '', category: '', probability: 3, impact: 3,
    mitigation_plan: '', owner: '', status: 'Open', cost_exposure: 0,
  });
  const [issueForm, setIssueForm] = useState({
    issue_code: '', title: '', description: '', priority: 'Medium', assigned_to: '',
    raised_by: '', due_date: '', status: 'Open',
  });

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const [riskRes, issueRes, hmRes, topRes, odRes] = await Promise.all([
        getRisks(projectId || undefined),
        getIssues(projectId || undefined),
        getRiskHeatmap(projectId || undefined),
        getTopRisks(5, projectId || undefined),
        getOverdueIssues(projectId || undefined),
      ]);
      setRisks(riskRes.data);
      setIssues(issueRes.data);
      setHeatmap(hmRes.data);
      setTopRisks(topRes.data);
      setOverdueIssues(odRes.data);
    } finally { setLoading(false); }
  }, [projectId]);

  useEffect(() => { loadData(); }, [loadData]);

  const scoreColor = (score) => {
    if (score >= 15) return '#d32f2f';
    if (score >= 8) return '#ed6c02';
    return '#2e7d32';
  };

  const handleSaveRisk = async () => {
    const payload = { ...riskForm, project_id: parseInt(projectId) || projects[0]?.id };
    if (editItem) await updateRisk(editItem.id, payload);
    else await createRisk(payload);
    setRiskDialog(false); setEditItem(null);
    setRiskForm({ risk_code: '', title: '', description: '', category: '', probability: 3, impact: 3, mitigation_plan: '', owner: '', status: 'Open', cost_exposure: 0 });
    loadData();
  };

  const handleSaveIssue = async () => {
    const payload = { ...issueForm, project_id: parseInt(projectId) || projects[0]?.id };
    if (!payload.due_date) delete payload.due_date;
    if (editItem) await updateIssue(editItem.id, payload);
    else await createIssue(payload);
    setIssueDialog(false); setEditItem(null);
    setIssueForm({ issue_code: '', title: '', description: '', priority: 'Medium', assigned_to: '', raised_by: '', due_date: '', status: 'Open' });
    loadData();
  };

  const openEditRisk = (r) => {
    setEditItem(r);
    setRiskForm({ risk_code: r.risk_code, title: r.title, description: r.description || '', category: r.category || '', probability: r.probability, impact: r.impact, mitigation_plan: r.mitigation_plan || '', owner: r.owner || '', status: r.status, cost_exposure: r.cost_exposure || 0 });
    setRiskDialog(true);
  };

  const openEditIssue = (i) => {
    setEditItem(i);
    setIssueForm({ issue_code: i.issue_code, title: i.title, description: i.description || '', priority: i.priority, assigned_to: i.assigned_to || '', raised_by: i.raised_by || '', due_date: i.due_date || '', status: i.status });
    setIssueDialog(true);
  };

  if (loading) return <Box sx={{ display: 'flex', justifyContent: 'center', mt: 10 }}><CircularProgress /></Box>;

  const openRisks = risks.filter(r => r.status === 'Open').length;
  const highRisks = risks.filter(r => r.risk_score >= 15).length;
  const openIssueCount = issues.filter(i => i.status === 'Open' || i.status === 'In Progress').length;

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h5" fontWeight={700}>Risk & Issue Management</Typography>
      </Box>

      {/* Summary Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid item xs={6} sm={3}>
          <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
            <Typography variant="h4" fontWeight={700} color="#d32f2f">{openRisks}</Typography>
            <Typography variant="caption" color="text.secondary">Open Risks</Typography>
          </CardContent></Card>
        </Grid>
        <Grid item xs={6} sm={3}>
          <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
            <Typography variant="h4" fontWeight={700} color="#ed6c02">{highRisks}</Typography>
            <Typography variant="caption" color="text.secondary">High Risks (Score 15+)</Typography>
          </CardContent></Card>
        </Grid>
        <Grid item xs={6} sm={3}>
          <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
            <Typography variant="h4" fontWeight={700} color="#1976d2">{openIssueCount}</Typography>
            <Typography variant="caption" color="text.secondary">Open Issues</Typography>
          </CardContent></Card>
        </Grid>
        <Grid item xs={6} sm={3}>
          <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
            <Typography variant="h4" fontWeight={700} color="#d32f2f">{overdueIssues.length}</Typography>
            <Typography variant="caption" color="text.secondary">Overdue Issues</Typography>
          </CardContent></Card>
        </Grid>
      </Grid>

      {/* Heatmap + Top Risks */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} md={5}>
          <Card sx={{ height: '100%' }}>
            <CardContent>
              <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 2 }}>Risk Heat Map</Typography>
              <Box sx={{ display: 'flex', gap: 0.5, mb: 1, ml: 4 }}>
                {[1,2,3,4,5].map(i => (
                  <Typography key={i} variant="caption" sx={{ width: 48, textAlign: 'center', fontWeight: 600 }}>I={i}</Typography>
                ))}
              </Box>
              {[5,4,3,2,1].map(p => (
                <Box key={p} sx={{ display: 'flex', gap: 0.5, mb: 0.5, alignItems: 'center' }}>
                  <Typography variant="caption" sx={{ width: 35, textAlign: 'right', fontWeight: 600 }}>P={p}</Typography>
                  {[1,2,3,4,5].map(i => {
                    const cell = heatmap.find(h => h.probability === p && h.impact === i);
                    const count = cell?.count || 0;
                    const score = p * i;
                    let bg = '#e8f5e9';
                    if (score >= 15) bg = '#ffcdd2';
                    else if (score >= 8) bg = '#fff9c4';
                    else if (score >= 4) bg = '#c8e6c9';
                    return (
                      <Tooltip key={`${p}-${i}`} title={`Score: ${score} | ${count} risk(s)`}>
                        <Box sx={{ width: 48, height: 40, bgcolor: bg, borderRadius: 1, display: 'flex',
                          alignItems: 'center', justifyContent: 'center', border: '1px solid #e0e0e0' }}>
                          <Typography variant="body2" fontWeight={count > 0 ? 700 : 400}>
                            {count > 0 ? count : ''}
                          </Typography>
                        </Box>
                      </Tooltip>
                    );
                  })}
                </Box>
              ))}
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={7}>
          <Card sx={{ height: '100%' }}>
            <CardContent>
              <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 2 }}>Top 5 Risks</Typography>
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      {['Code','Title','P','I','Score','Owner','Status'].map(h => (
                        <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                      ))}
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {topRisks.map(r => (
                      <TableRow key={r.id}>
                        <TableCell><Typography variant="body2" fontWeight={600}>{r.risk_code}</Typography></TableCell>
                        <TableCell>{r.title}</TableCell>
                        <TableCell>{r.probability}</TableCell>
                        <TableCell>{r.impact}</TableCell>
                        <TableCell>
                          <Chip label={r.risk_score} size="small" sx={{ bgcolor: scoreColor(r.risk_score), color: '#fff', fontWeight: 700 }} />
                        </TableCell>
                        <TableCell>{r.owner}</TableCell>
                        <TableCell><Chip label={r.status} size="small" variant="outlined" /></TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Tabs */}
      <Card>
        <Tabs value={tab} onChange={(_, v) => setTab(v)} sx={{ borderBottom: 1, borderColor: 'divider', px: 2 }}>
          <Tab label={`Risk Register (${risks.length})`} icon={<Warning />} iconPosition="start" />
          <Tab label={`Issue Log (${issues.length})`} icon={<BugReport />} iconPosition="start" />
        </Tabs>
        <CardContent>
          {tab === 0 && (
            <>
              <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 2 }}>
                <Button variant="contained" startIcon={<Add />} onClick={() => { setEditItem(null); setRiskDialog(true); }}>
                  Add Risk
                </Button>
              </Box>
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      {['Code','Title','Category','P','I','Score','Owner','Status','Cost Exposure','Actions'].map(h => (
                        <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                      ))}
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {risks.map(r => (
                      <TableRow key={r.id}>
                        <TableCell><Typography variant="body2" fontWeight={600}>{r.risk_code}</Typography></TableCell>
                        <TableCell>{r.title}</TableCell>
                        <TableCell>{r.category}</TableCell>
                        <TableCell>{r.probability}</TableCell>
                        <TableCell>{r.impact}</TableCell>
                        <TableCell>
                          <Chip label={r.risk_score} size="small" sx={{ bgcolor: scoreColor(r.risk_score), color: '#fff', fontWeight: 700 }} />
                        </TableCell>
                        <TableCell>{r.owner}</TableCell>
                        <TableCell><Chip label={r.status} size="small" color={r.status === 'Open' ? 'error' : r.status === 'Mitigated' ? 'success' : 'default'} variant="outlined" /></TableCell>
                        <TableCell>£{Number(r.cost_exposure || 0).toLocaleString()}</TableCell>
                        <TableCell>
                          <IconButton size="small" onClick={() => openEditRisk(r)}><Edit fontSize="small" /></IconButton>
                          <IconButton size="small" color="error" onClick={async () => { await deleteRisk(r.id); loadData(); }}><Delete fontSize="small" /></IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </>
          )}
          {tab === 1 && (
            <>
              <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 2 }}>
                <Button variant="contained" startIcon={<Add />} onClick={() => { setEditItem(null); setIssueDialog(true); }}>
                  Add Issue
                </Button>
              </Box>
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      {['Code','Title','Priority','Assigned To','Due Date','Status','Overdue','Actions'].map(h => (
                        <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                      ))}
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {issues.map(i => (
                      <TableRow key={i.id} sx={{ bgcolor: i.is_overdue ? '#fff3e0' : 'inherit' }}>
                        <TableCell><Typography variant="body2" fontWeight={600}>{i.issue_code}</Typography></TableCell>
                        <TableCell>{i.title}</TableCell>
                        <TableCell>
                          <Chip label={i.priority} size="small" color={i.priority === 'Critical' ? 'error' : i.priority === 'High' ? 'warning' : 'default'} variant="outlined" />
                        </TableCell>
                        <TableCell>{i.assigned_to}</TableCell>
                        <TableCell>{i.due_date}</TableCell>
                        <TableCell><Chip label={i.status} size="small" color={i.status === 'Resolved' ? 'success' : i.status === 'Open' ? 'error' : 'default'} variant="outlined" /></TableCell>
                        <TableCell>{i.is_overdue && <Chip label="Overdue" size="small" color="error" />}</TableCell>
                        <TableCell>
                          <IconButton size="small" onClick={() => openEditIssue(i)}><Edit fontSize="small" /></IconButton>
                          <IconButton size="small" color="error" onClick={async () => { await deleteIssue(i.id); loadData(); }}><Delete fontSize="small" /></IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </>
          )}
        </CardContent>
      </Card>

      {/* Risk Dialog */}
      <Dialog open={riskDialog} onClose={() => setRiskDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editItem ? 'Edit Risk' : 'Add Risk'}</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
          <TextField label="Risk Code" value={riskForm.risk_code} onChange={e => setRiskForm({ ...riskForm, risk_code: e.target.value })} />
          <TextField label="Title" value={riskForm.title} onChange={e => setRiskForm({ ...riskForm, title: e.target.value })} />
          <TextField label="Description" value={riskForm.description} onChange={e => setRiskForm({ ...riskForm, description: e.target.value })} multiline rows={2} />
          <FormControl><InputLabel>Category</InputLabel>
            <Select value={riskForm.category} onChange={e => setRiskForm({ ...riskForm, category: e.target.value })} label="Category">
              {RISK_CATEGORIES.map(c => <MenuItem key={c} value={c}>{c}</MenuItem>)}
            </Select>
          </FormControl>
          <Grid container spacing={2}>
            <Grid item xs={6}>
              <TextField label="Probability (1-5)" type="number" value={riskForm.probability}
                onChange={e => setRiskForm({ ...riskForm, probability: Math.min(5, Math.max(1, parseInt(e.target.value) || 1)) })}
                inputProps={{ min: 1, max: 5 }} fullWidth />
            </Grid>
            <Grid item xs={6}>
              <TextField label="Impact (1-5)" type="number" value={riskForm.impact}
                onChange={e => setRiskForm({ ...riskForm, impact: Math.min(5, Math.max(1, parseInt(e.target.value) || 1)) })}
                inputProps={{ min: 1, max: 5 }} fullWidth />
            </Grid>
          </Grid>
          <TextField label="Mitigation Plan" value={riskForm.mitigation_plan} onChange={e => setRiskForm({ ...riskForm, mitigation_plan: e.target.value })} multiline rows={2} />
          <TextField label="Owner" value={riskForm.owner} onChange={e => setRiskForm({ ...riskForm, owner: e.target.value })} />
          <TextField label="Cost Exposure (£)" type="number" value={riskForm.cost_exposure} onChange={e => setRiskForm({ ...riskForm, cost_exposure: parseFloat(e.target.value) || 0 })} />
          <FormControl><InputLabel>Status</InputLabel>
            <Select value={riskForm.status} onChange={e => setRiskForm({ ...riskForm, status: e.target.value })} label="Status">
              {['Open', 'Mitigated', 'Closed', 'Accepted'].map(s => <MenuItem key={s} value={s}>{s}</MenuItem>)}
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRiskDialog(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleSaveRisk} disabled={!riskForm.risk_code || !riskForm.title}>Save</Button>
        </DialogActions>
      </Dialog>

      {/* Issue Dialog */}
      <Dialog open={issueDialog} onClose={() => setIssueDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editItem ? 'Edit Issue' : 'Add Issue'}</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
          <TextField label="Issue Code" value={issueForm.issue_code} onChange={e => setIssueForm({ ...issueForm, issue_code: e.target.value })} />
          <TextField label="Title" value={issueForm.title} onChange={e => setIssueForm({ ...issueForm, title: e.target.value })} />
          <TextField label="Description" value={issueForm.description} onChange={e => setIssueForm({ ...issueForm, description: e.target.value })} multiline rows={2} />
          <FormControl><InputLabel>Priority</InputLabel>
            <Select value={issueForm.priority} onChange={e => setIssueForm({ ...issueForm, priority: e.target.value })} label="Priority">
              {PRIORITIES.map(p => <MenuItem key={p} value={p}>{p}</MenuItem>)}
            </Select>
          </FormControl>
          <TextField label="Assigned To" value={issueForm.assigned_to} onChange={e => setIssueForm({ ...issueForm, assigned_to: e.target.value })} />
          <TextField label="Raised By" value={issueForm.raised_by} onChange={e => setIssueForm({ ...issueForm, raised_by: e.target.value })} />
          <TextField label="Due Date" type="date" value={issueForm.due_date} onChange={e => setIssueForm({ ...issueForm, due_date: e.target.value })} InputLabelProps={{ shrink: true }} />
          <FormControl><InputLabel>Status</InputLabel>
            <Select value={issueForm.status} onChange={e => setIssueForm({ ...issueForm, status: e.target.value })} label="Status">
              {['Open', 'In Progress', 'Resolved', 'Closed'].map(s => <MenuItem key={s} value={s}>{s}</MenuItem>)}
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setIssueDialog(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleSaveIssue} disabled={!issueForm.issue_code || !issueForm.title}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
