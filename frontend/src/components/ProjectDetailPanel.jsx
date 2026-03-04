import React, { useState, useEffect } from 'react';
import {
  Box, Tabs, Tab, Typography, Grid, Divider, Chip, IconButton,
} from '@mui/material';
import { KeyboardArrowDown, KeyboardArrowUp } from '@mui/icons-material';
import { useProject } from '../context/ProjectContext';
import {
  getCBS, getVariations, getMilestones,
  getRisks, getIssues, getSafetyIncidents,
} from '../services/api';
import StatusChip from './StatusChip';

function Field({ label, value }) {
  return (
    <Box sx={{ mb: 1 }}>
      <Typography variant="caption" color="text.secondary" sx={{ fontSize: '0.7rem' }}>{label}</Typography>
      <Typography variant="body2" fontWeight={500} sx={{ fontSize: '0.8rem' }}>{value || '-'}</Typography>
    </Box>
  );
}

function GeneralTab({ project }) {
  if (!project) return null;
  return (
    <Grid container spacing={3}>
      <Grid item xs={12} sm={4}>
        <Typography variant="subtitle2" fontWeight={700} sx={{ mb: 1, color: '#546e7a' }}>Details</Typography>
        <Field label="Project Code" value={project.code} />
        <Field label="Client" value={project.client} />
        <Field label="Location" value={project.location} />
        <Field label="Manager" value={project.project_manager} />
        <Field label="Status" value={project.status} />
      </Grid>
      <Grid item xs={12} sm={4}>
        <Typography variant="subtitle2" fontWeight={700} sx={{ mb: 1, color: '#546e7a' }}>Planned Dates</Typography>
        <Field label="Start Date" value={project.start_date} />
        <Field label="End Date" value={project.end_date} />
        <Field label="Contract Completion" value={project.contract_completion_date} />
      </Grid>
      <Grid item xs={12} sm={4}>
        <Typography variant="subtitle2" fontWeight={700} sx={{ mb: 1, color: '#546e7a' }}>Description</Typography>
        <Typography variant="body2" sx={{ fontSize: '0.8rem', color: '#37474f' }}>
          {project.description || 'No description provided.'}
        </Typography>
      </Grid>
    </Grid>
  );
}

function BudgetTab({ projectId }) {
  const [cbs, setCbs] = useState([]);
  useEffect(() => {
    if (projectId) getCBS(projectId).then((r) => setCbs(r.data)).catch(() => {});
  }, [projectId]);
  const totalBudget = cbs.reduce((s, c) => s + (c.budget_cost || 0), 0);
  const totalActual = cbs.reduce((s, c) => s + (c.actual_cost || 0), 0);
  const totalForecast = cbs.reduce((s, c) => s + (c.forecast_cost || 0), 0);
  return (
    <Grid container spacing={3}>
      <Grid item xs={6} sm={3}><Field label="Total Budget" value={`\u00a3${totalBudget.toLocaleString()}`} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Actual Cost" value={`\u00a3${totalActual.toLocaleString()}`} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Forecast" value={`\u00a3${totalForecast.toLocaleString()}`} /></Grid>
      <Grid item xs={6} sm={3}><Field label="CBS Items" value={cbs.length} /></Grid>
    </Grid>
  );
}

function VariationsTab({ projectId }) {
  const [vars, setVars] = useState([]);
  useEffect(() => {
    if (projectId) getVariations(projectId).then((r) => setVars(r.data)).catch(() => {});
  }, [projectId]);
  const approved = vars.filter((v) => v.approval_status === 'Approved');
  const pending = vars.filter((v) => v.approval_status === 'Pending');
  const approvedVal = approved.reduce((s, v) => s + v.value, 0);
  return (
    <Grid container spacing={3}>
      <Grid item xs={6} sm={3}><Field label="Total Variations" value={vars.length} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Approved" value={approved.length} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Pending" value={pending.length} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Approved Value" value={`\u00a3${approvedVal.toLocaleString()}`} /></Grid>
    </Grid>
  );
}

function LDTab({ project }) {
  const [milestones, setMilestones] = useState([]);
  useEffect(() => {
    if (project?.id) getMilestones(project.id).then((r) => setMilestones(r.data)).catch(() => {});
  }, [project?.id]);
  const ldRate = project?.daily_ld_rate || 0;
  const ldCapPct = project?.ld_cap_pct || 10;
  const contractValue = project?.contract_value || 0;
  const ldCap = contractValue * ldCapPct / 100;
  const totalLdRaw = milestones.reduce((sum, m) => sum + (m.delay_days || 0) * ldRate, 0);
  const totalLd = ldCap > 0 ? Math.min(totalLdRaw, ldCap) : totalLdRaw;
  return (
    <Grid container spacing={3}>
      <Grid item xs={6} sm={3}><Field label="Daily LD Rate" value={`\u00a3${ldRate.toLocaleString()}`} /></Grid>
      <Grid item xs={6} sm={3}><Field label={`LD Cap (${ldCapPct}%)`} value={`\u00a3${ldCap.toLocaleString()}`} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Raw LD" value={`\u00a3${totalLdRaw.toLocaleString()}`} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Applied LD" value={`\u00a3${totalLd.toLocaleString()}`} /></Grid>
    </Grid>
  );
}

function IssuesTab({ projectId }) {
  const [issues, setIssues] = useState([]);
  useEffect(() => {
    if (projectId) getIssues(projectId).then((r) => setIssues(r.data)).catch(() => {});
  }, [projectId]);
  const open = issues.filter((i) => i.status === 'Open' || i.status === 'In Progress').length;
  return (
    <Grid container spacing={3}>
      <Grid item xs={6} sm={3}><Field label="Total Issues" value={issues.length} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Open" value={open} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Resolved" value={issues.filter((i) => i.status === 'Resolved').length} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Overdue" value={issues.filter((i) => i.is_overdue).length} /></Grid>
    </Grid>
  );
}

function RisksTab({ projectId }) {
  const [risks, setRisks] = useState([]);
  useEffect(() => {
    if (projectId) getRisks(projectId).then((r) => setRisks(r.data)).catch(() => {});
  }, [projectId]);
  const openRisks = risks.filter((r) => r.status === 'Open').length;
  const highRisks = risks.filter((r) => r.risk_score >= 15).length;
  return (
    <Grid container spacing={3}>
      <Grid item xs={6} sm={3}><Field label="Total Risks" value={risks.length} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Open" value={openRisks} /></Grid>
      <Grid item xs={6} sm={3}><Field label="High (15+)" value={highRisks} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Mitigated" value={risks.filter((r) => r.status === 'Mitigated').length} /></Grid>
    </Grid>
  );
}

function SafetyTab({ projectId }) {
  const [incidents, setIncidents] = useState([]);
  useEffect(() => {
    if (projectId) getSafetyIncidents(projectId).then((r) => setIncidents(r.data)).catch(() => {});
  }, [projectId]);
  const openCount = incidents.filter((i) => i.status === 'Open' || i.status === 'Under Investigation').length;
  const totalPenalty = incidents.reduce((s, i) => s + (i.penalty_cost || 0), 0);
  return (
    <Grid container spacing={3}>
      <Grid item xs={6} sm={3}><Field label="Total Incidents" value={incidents.length} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Open" value={openCount} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Resolved" value={incidents.filter((i) => i.status === 'Resolved' || i.status === 'Closed').length} /></Grid>
      <Grid item xs={6} sm={3}><Field label="Total Penalties" value={`\u00a3${totalPenalty.toLocaleString()}`} /></Grid>
    </Grid>
  );
}

const DETAIL_TABS = ['General', 'Budget', 'Variations', 'LD', 'Issues', 'Risks', 'Safety'];

export default function ProjectDetailPanel() {
  const { selectedProjectId, selectedProject } = useProject();
  const [tab, setTab] = useState(0);
  const [collapsed, setCollapsed] = useState(false);

  if (!selectedProjectId) return null;

  return (
    <Box sx={{ borderTop: '2px solid #e0e0e0', bgcolor: '#fff' }}>
      <Box
        sx={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          px: 2, py: 0.5, bgcolor: '#f5f5f5', cursor: 'pointer',
        }}
        onClick={() => setCollapsed(!collapsed)}
      >
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Typography variant="subtitle2" fontWeight={700} sx={{ color: '#1a2332' }}>
            Project Details
          </Typography>
          {selectedProject && (
            <Chip label={selectedProject.name} size="small" sx={{ fontSize: '0.7rem' }} />
          )}
        </Box>
        <IconButton size="small">
          {collapsed ? <KeyboardArrowUp /> : <KeyboardArrowDown />}
        </IconButton>
      </Box>

      {!collapsed && (
        <>
          <Tabs
            value={tab}
            onChange={(_, v) => setTab(v)}
            variant="scrollable"
            scrollButtons="auto"
            sx={{
              minHeight: 32,
              bgcolor: '#fafafa',
              '& .MuiTab-root': { minHeight: 32, py: 0, fontSize: '0.75rem', textTransform: 'none' },
              '& .MuiTabs-indicator': { bgcolor: '#1a2332' },
            }}
          >
            {DETAIL_TABS.map((t) => <Tab key={t} label={t} />)}
          </Tabs>
          <Box sx={{ p: 2, maxHeight: 200, overflow: 'auto' }}>
            {tab === 0 && <GeneralTab project={selectedProject} />}
            {tab === 1 && <BudgetTab projectId={selectedProjectId} />}
            {tab === 2 && <VariationsTab projectId={selectedProjectId} />}
            {tab === 3 && <LDTab project={selectedProject} />}
            {tab === 4 && <IssuesTab projectId={selectedProjectId} />}
            {tab === 5 && <RisksTab projectId={selectedProjectId} />}
            {tab === 6 && <SafetyTab projectId={selectedProjectId} />}
          </Box>
        </>
      )}
    </Box>
  );
}
