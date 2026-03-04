import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box, Typography, Card, CardContent, Grid, Button, TextField, Dialog,
  DialogTitle, DialogContent, DialogActions, IconButton, Chip, Collapse,
  List, ListItemButton, ListItemIcon, ListItemText, CircularProgress,
} from '@mui/material';
import {
  Add, Business, FolderOpen, AccountTree, ExpandMore, ExpandLess, Edit, Delete,
} from '@mui/icons-material';
import KPICard from '../components/KPICard';
import {
  getPortfolioHierarchy, getPortfolioKPIs, getOrganizations,
  createOrganization, getProgrammes, createProgramme, deleteOrganization, deleteProgramme,
} from '../services/api';
import { useProject } from '../context/ProjectContext';

export default function PortfolioView() {
  const navigate = useNavigate();
  const { setSelectedProjectId } = useProject();
  const [hierarchy, setHierarchy] = useState([]);
  const [kpis, setKPIs] = useState(null);
  const [loading, setLoading] = useState(true);
  const [expanded, setExpanded] = useState({});
  const [orgDialog, setOrgDialog] = useState(false);
  const [progDialog, setProgDialog] = useState(false);
  const [newOrg, setNewOrg] = useState({ name: '', code: '', description: '' });
  const [newProg, setNewProg] = useState({ organization_id: 0, name: '', code: '', description: '' });
  const [selectedOrgId, setSelectedOrgId] = useState(null);

  const load = () => {
    setLoading(true);
    Promise.all([getPortfolioHierarchy(), getPortfolioKPIs()])
      .then(([h, k]) => { setHierarchy(h.data); setKPIs(k.data); })
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const toggleExpand = (key) => setExpanded(prev => ({ ...prev, [key]: !prev[key] }));

  const handleCreateOrg = async () => {
    await createOrganization(newOrg);
    setOrgDialog(false);
    setNewOrg({ name: '', code: '', description: '' });
    load();
  };

  const handleCreateProg = async () => {
    await createProgramme({ ...newProg, organization_id: selectedOrgId });
    setProgDialog(false);
    setNewProg({ organization_id: 0, name: '', code: '', description: '' });
    load();
  };

  if (loading) return <Box sx={{ display: 'flex', justifyContent: 'center', mt: 10 }}><CircularProgress /></Box>;

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h5" fontWeight={700}>Portfolio</Typography>
        <Button variant="contained" startIcon={<Add />} onClick={() => setOrgDialog(true)}>
          New Organization
        </Button>
      </Box>

      {/* KPI Cards */}
      {kpis && (
        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid item xs={6} sm={4} md={2}>
            <KPICard title="Total Projects" value={kpis.total_projects} color="#1976d2" />
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <KPICard title="Active" value={kpis.active_projects} color="#2e7d32" />
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <KPICard title="At Risk" value={kpis.at_risk_projects} color="#d32f2f" />
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <KPICard title="Budget" value={`£${(kpis.total_budget / 1e6).toFixed(1)}M`} color="#1976d2" />
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <KPICard title="Actual Cost" value={`£${(kpis.total_actual_cost / 1e6).toFixed(1)}M`} color="#ed6c02" />
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <KPICard title="Open Risks" value={kpis.open_risks} color={kpis.open_risks > 5 ? '#d32f2f' : '#ed6c02'} />
          </Grid>
        </Grid>
      )}

      {/* Hierarchy Tree */}
      <Card>
        <CardContent>
          <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 2 }}>Organization → Programme → Project</Typography>
          {hierarchy.length === 0 ? (
            <Typography color="text.secondary">No organizations yet. Create one to get started.</Typography>
          ) : (
            <List sx={{ p: 0 }}>
              {hierarchy.map(org => (
                <Box key={org.id}>
                  <ListItemButton onClick={() => toggleExpand(`org-${org.id}`)} sx={{ borderRadius: 2 }}>
                    <ListItemIcon><Business color="primary" /></ListItemIcon>
                    <ListItemText
                      primary={<Typography fontWeight={600}>{org.name}</Typography>}
                      secondary={`Code: ${org.code} | ${org.programmes.length} programme(s)`}
                    />
                    <Button size="small" variant="outlined" sx={{ mr: 1 }}
                      onClick={(e) => { e.stopPropagation(); setSelectedOrgId(org.id); setProgDialog(true); }}>
                      + Programme
                    </Button>
                    {expanded[`org-${org.id}`] ? <ExpandLess /> : <ExpandMore />}
                  </ListItemButton>
                  <Collapse in={expanded[`org-${org.id}`]} timeout="auto">
                    <List sx={{ pl: 4 }}>
                      {org.programmes.map(prog => (
                        <Box key={prog.id}>
                          <ListItemButton onClick={() => toggleExpand(`prog-${prog.id}`)} sx={{ borderRadius: 2 }}>
                            <ListItemIcon><FolderOpen color="secondary" /></ListItemIcon>
                            <ListItemText
                              primary={prog.name}
                              secondary={`Code: ${prog.code} | ${prog.projects.length} project(s) | Status: ${prog.status}`}
                            />
                            {expanded[`prog-${prog.id}`] ? <ExpandLess /> : <ExpandMore />}
                          </ListItemButton>
                          <Collapse in={expanded[`prog-${prog.id}`]} timeout="auto">
                            <List sx={{ pl: 4 }}>
                              {prog.projects.map(proj => (
                                <ListItemButton key={proj.id} sx={{ borderRadius: 2 }}
                                  onClick={() => { setSelectedProjectId(proj.id); navigate('/projects/activities'); }}>
                                  <ListItemIcon><AccountTree sx={{ color: '#ed6c02' }} /></ListItemIcon>
                                  <ListItemText
                                    primary={proj.name}
                                    secondary={`${proj.client} | Budget: £${Number(proj.total_budget).toLocaleString()}`}
                                  />
                                  <Chip
                                    label={proj.status}
                                    size="small"
                                    color={proj.status === 'Active' ? 'success' : proj.status === 'At Risk' ? 'error' : 'default'}
                                    variant="outlined"
                                  />
                                </ListItemButton>
                              ))}
                              {prog.projects.length === 0 && (
                                <Typography variant="body2" color="text.secondary" sx={{ pl: 7, py: 1 }}>No projects</Typography>
                              )}
                            </List>
                          </Collapse>
                        </Box>
                      ))}
                      {org.programmes.length === 0 && (
                        <Typography variant="body2" color="text.secondary" sx={{ pl: 7, py: 1 }}>No programmes</Typography>
                      )}
                    </List>
                  </Collapse>
                </Box>
              ))}
            </List>
          )}
        </CardContent>
      </Card>

      {/* Create Organization Dialog */}
      <Dialog open={orgDialog} onClose={() => setOrgDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>New Organization</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
          <TextField label="Name" value={newOrg.name} onChange={e => setNewOrg({ ...newOrg, name: e.target.value })} fullWidth />
          <TextField label="Code" value={newOrg.code} onChange={e => setNewOrg({ ...newOrg, code: e.target.value })} fullWidth />
          <TextField label="Description" value={newOrg.description} onChange={e => setNewOrg({ ...newOrg, description: e.target.value })} fullWidth multiline rows={2} />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOrgDialog(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleCreateOrg} disabled={!newOrg.name || !newOrg.code}>Create</Button>
        </DialogActions>
      </Dialog>

      {/* Create Programme Dialog */}
      <Dialog open={progDialog} onClose={() => setProgDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>New Programme</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
          <TextField label="Name" value={newProg.name} onChange={e => setNewProg({ ...newProg, name: e.target.value })} fullWidth />
          <TextField label="Code" value={newProg.code} onChange={e => setNewProg({ ...newProg, code: e.target.value })} fullWidth />
          <TextField label="Description" value={newProg.description} onChange={e => setNewProg({ ...newProg, description: e.target.value })} fullWidth multiline rows={2} />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setProgDialog(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleCreateProg} disabled={!newProg.name || !newProg.code}>Create</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
