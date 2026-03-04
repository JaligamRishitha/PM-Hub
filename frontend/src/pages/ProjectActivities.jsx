import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Button, Tab, Tabs, Paper, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, TablePagination, IconButton, Typography, Alert, Snackbar,
  LinearProgress, Grid, Card, CardContent, Dialog, DialogTitle, DialogContent,
  DialogActions, TextField, MenuItem, FormControlLabel, Switch, Chip, Divider,
  Tooltip,
} from '@mui/material';
import {
  Add, Edit, Delete, Timeline as TimelineIcon, Flag, FlagCircle,
  AccountTree, Person, Info, Description as FormIcon,
} from '@mui/icons-material';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip as RTooltip,
  ResponsiveContainer, ReferenceLine,
} from 'recharts';
import {
  getActivities, createActivity, updateActivity, deleteActivity,
  getMilestones, createMilestone, updateMilestone, deleteMilestone,
  getCBS,
} from '../services/api';
import StatusChip from '../components/StatusChip';
import FormDialog from '../components/FormDialog';
import { useProject } from '../context/ProjectContext';

const ACTIVITY_FIELDS = [
  { name: 'activity_code', label: 'Activity Code' },
  { name: 'activity_name', label: 'Activity Name', required: true },
  { name: 'phase', label: 'Phase', type: 'select', options: ['Design', 'Procurement', 'Construction', 'Commissioning', 'Closure'], required: true },
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
  { name: 'phase', label: 'Phase', type: 'select', options: ['Design', 'Procurement', 'Construction', 'Commissioning', 'Closure'], required: true },
  { name: 'planned_date', label: 'Planned Date', type: 'date', required: true },
  { name: 'actual_date', label: 'Actual Date', type: 'date' },
  { name: 'is_critical', label: 'Is Critical', type: 'boolean' },
];

/* ── Mock WBS data ── */
const MOCK_WBS = [
  { id: 'WBS-1.0', name: 'Project Initiation', level: 0, parent: '-', status: 'Completed' },
  { id: 'WBS-1.1', name: 'Stakeholder Identification', level: 1, parent: 'WBS-1.0', status: 'Completed' },
  { id: 'WBS-1.2', name: 'Project Charter Approval', level: 1, parent: 'WBS-1.0', status: 'Completed' },
  { id: 'WBS-GB.0', name: 'Gate B – Feasibility Review', level: 0, parent: '-', status: 'Completed', isGate: true },
  { id: 'WBS-GB.1', name: 'Business Case Validation', level: 1, parent: 'WBS-GB.0', status: 'Completed' },
  { id: 'WBS-GB.2', name: 'Feasibility Study Sign-off', level: 1, parent: 'WBS-GB.0', status: 'Completed' },
  { id: 'WBS-GB.3', name: 'Risk & Opportunity Assessment', level: 1, parent: 'WBS-GB.0', status: 'Completed' },
  { id: 'WBS-GB.4', name: 'Gate B Approval Decision', level: 1, parent: 'WBS-GB.0', status: 'Completed' },
  { id: 'WBS-2.0', name: 'Design Phase', level: 0, parent: '-', status: 'Active' },
  { id: 'WBS-2.1', name: 'Preliminary Design', level: 1, parent: 'WBS-2.0', status: 'Completed' },
  { id: 'WBS-2.2', name: 'Detailed Design', level: 1, parent: 'WBS-2.0', status: 'Active' },
  { id: 'WBS-2.3', name: 'Design Review & Signoff', level: 1, parent: 'WBS-2.0', status: 'Pending' },
  { id: 'WBS-GC.0', name: 'Gate C – Design Completion Review', level: 0, parent: '-', status: 'Pending', isGate: true },
  { id: 'WBS-GC.1', name: 'Design Deliverables Verification', level: 1, parent: 'WBS-GC.0', status: 'Pending' },
  { id: 'WBS-GC.2', name: 'Cost Estimate Finalisation', level: 1, parent: 'WBS-GC.0', status: 'Pending' },
  { id: 'WBS-GC.3', name: 'Construction Readiness Check', level: 1, parent: 'WBS-GC.0', status: 'Pending' },
  { id: 'WBS-GC.4', name: 'Gate C Approval Decision', level: 1, parent: 'WBS-GC.0', status: 'Pending' },
  { id: 'WBS-3.0', name: 'Procurement', level: 0, parent: '-', status: 'Pending' },
  { id: 'WBS-3.1', name: 'Vendor Selection', level: 1, parent: 'WBS-3.0', status: 'Pending' },
  { id: 'WBS-3.2', name: 'Material Ordering', level: 1, parent: 'WBS-3.0', status: 'Pending' },
  { id: 'WBS-4.0', name: 'Construction', level: 0, parent: '-', status: 'Pending' },
  { id: 'WBS-4.1', name: 'Site Preparation', level: 1, parent: 'WBS-4.0', status: 'Pending' },
  { id: 'WBS-4.2', name: 'Structural Works', level: 1, parent: 'WBS-4.0', status: 'Pending' },
  { id: 'WBS-4.3', name: 'MEP Installation', level: 1, parent: 'WBS-4.0', status: 'Pending' },
  { id: 'WBS-5.0', name: 'Commissioning & Handover', level: 0, parent: '-', status: 'Pending' },
];

/* ── Mock Resources data ── */
const MOCK_RESOURCES = [
  { id: 'R-001', name: 'John Carter', role: 'Project Manager', type: 'Labour', unit: 'hrs', rate: 95, allocation: 100 },
  { id: 'R-002', name: 'Sarah Mitchell', role: 'Lead Engineer', type: 'Labour', unit: 'hrs', rate: 85, allocation: 80 },
  { id: 'R-003', name: 'David Lee', role: 'Site Supervisor', type: 'Labour', unit: 'hrs', rate: 65, allocation: 100 },
  { id: 'R-004', name: 'Emma Wilson', role: 'Safety Officer', type: 'Labour', unit: 'hrs', rate: 70, allocation: 50 },
  { id: 'R-005', name: 'Tower Crane TC-200', role: '-', type: 'Equipment', unit: 'days', rate: 1200, allocation: 100 },
  { id: 'R-006', name: 'Concrete Pump CP-50', role: '-', type: 'Equipment', unit: 'days', rate: 800, allocation: 60 },
  { id: 'R-007', name: 'Structural Steel', role: '-', type: 'Material', unit: 'tonnes', rate: 950, allocation: '-' },
  { id: 'R-008', name: 'Ready-Mix Concrete', role: '-', type: 'Material', unit: 'm³', rate: 120, allocation: '-' },
  { id: 'R-009', name: 'Rebar Grade 60', role: '-', type: 'Material', unit: 'tonnes', rate: 780, allocation: '-' },
  { id: 'R-010', name: 'Lisa Chen', role: 'QA/QC Inspector', type: 'Labour', unit: 'hrs', rate: 72, allocation: 75 },
];

function computeScheduleKPIs(activities) {
  if (!activities.length) return { spi: 1, delayDays: 0, onTrack: 0, delayed: 0, completed: 0 };
  let totalPlanned = 0, totalEarned = 0, maxDelay = 0;
  let onTrack = 0, delayed = 0, completed = 0;
  activities.forEach((a) => {
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

/* ═══════════════════════════════════════════
   Activity Details Form (mock dependency)
   ═══════════════════════════════════════════ */
function ActivityDetailsDialog({ open, onClose, activity }) {
  const [form, setForm] = useState({});

  useEffect(() => {
    if (activity) {
      setForm({
        activity_code: activity.activity_code || '',
        activity_name: activity.activity_name || '',
        phase: activity.phase || '',
        wbs_id: activity.is_critical ? 'WBS-4.2' : 'WBS-2.2',
        calendar: 'Standard 5-Day',
        duration_type: 'Fixed Duration & Units',
        original_duration: Math.max(1, Math.round((new Date(activity.planned_finish) - new Date(activity.planned_start)) / 86400000)),
        remaining_duration: Math.max(0, Math.round((new Date(activity.planned_finish) - new Date(activity.planned_start)) / 86400000 * (1 - activity.completion_pct / 100))),
        planned_start: activity.planned_start || '',
        planned_finish: activity.planned_finish || '',
        actual_start: activity.actual_start || '',
        actual_finish: activity.actual_finish || '',
        completion_pct: activity.completion_pct || 0,
        primary_resource: activity.is_critical ? 'R-003 David Lee' : 'R-002 Sarah Mitchell',
        predecessor: activity.activity_code ? `${activity.activity_code.replace(/\d+$/, m => String(Number(m) - 1).padStart(m.length, '0'))} FS` : '',
        successor: activity.activity_code ? `${activity.activity_code.replace(/\d+$/, m => String(Number(m) + 1).padStart(m.length, '0'))} FS` : '',
        constraint_type: 'As Soon As Possible',
        constraint_date: '',
        notes: '',
      });
    }
  }, [activity]);

  const set = (field, val) => setForm(f => ({ ...f, [field]: val }));

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <Info color="primary" /> Activity Details
      </DialogTitle>
      <DialogContent>
        <Typography variant="caption" color="text.secondary" sx={{ mb: 2, display: 'block' }}>
          Review and update activity details. All dependency fields must be validated before saving.
        </Typography>
        <Divider sx={{ mb: 2 }} />

        {/* General Section */}
        <Typography variant="subtitle2" fontWeight={700} color="primary" sx={{ mb: 1.5 }}>General</Typography>
        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid item xs={4}>
            <TextField label="Activity ID" value={form.activity_code} onChange={e => set('activity_code', e.target.value)} fullWidth size="small" />
          </Grid>
          <Grid item xs={8}>
            <TextField label="Activity Name" value={form.activity_name} onChange={e => set('activity_name', e.target.value)} fullWidth size="small" required />
          </Grid>
          <Grid item xs={4}>
            <TextField label="Phase" value={form.phase} onChange={e => set('phase', e.target.value)} fullWidth size="small" select>
              {['Design', 'Procurement', 'Construction', 'Commissioning', 'Closure'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
            </TextField>
          </Grid>
          <Grid item xs={4}>
            <TextField label="WBS" value={form.wbs_id} onChange={e => set('wbs_id', e.target.value)} fullWidth size="small" />
          </Grid>
          <Grid item xs={4}>
            <TextField label="Calendar" value={form.calendar} onChange={e => set('calendar', e.target.value)} fullWidth size="small" select>
              {['Standard 5-Day', 'Standard 7-Day', '24-Hour Calendar', 'Night Shift'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
            </TextField>
          </Grid>
        </Grid>

        {/* Duration Section */}
        <Typography variant="subtitle2" fontWeight={700} color="primary" sx={{ mb: 1.5 }}>Duration & Dates</Typography>
        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid item xs={4}>
            <TextField label="Duration Type" value={form.duration_type} onChange={e => set('duration_type', e.target.value)} fullWidth size="small" select>
              {['Fixed Duration & Units', 'Fixed Units/Time', 'Fixed Duration & Units/Time'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
            </TextField>
          </Grid>
          <Grid item xs={4}>
            <TextField label="Original Duration (days)" type="number" value={form.original_duration} onChange={e => set('original_duration', e.target.value)} fullWidth size="small" />
          </Grid>
          <Grid item xs={4}>
            <TextField label="Remaining Duration (days)" type="number" value={form.remaining_duration} onChange={e => set('remaining_duration', e.target.value)} fullWidth size="small" />
          </Grid>
          <Grid item xs={3}>
            <TextField label="Planned Start" type="date" value={form.planned_start} onChange={e => set('planned_start', e.target.value)} fullWidth size="small" InputLabelProps={{ shrink: true }} />
          </Grid>
          <Grid item xs={3}>
            <TextField label="Planned Finish" type="date" value={form.planned_finish} onChange={e => set('planned_finish', e.target.value)} fullWidth size="small" InputLabelProps={{ shrink: true }} />
          </Grid>
          <Grid item xs={3}>
            <TextField label="Actual Start" type="date" value={form.actual_start} onChange={e => set('actual_start', e.target.value)} fullWidth size="small" InputLabelProps={{ shrink: true }} />
          </Grid>
          <Grid item xs={3}>
            <TextField label="Actual Finish" type="date" value={form.actual_finish} onChange={e => set('actual_finish', e.target.value)} fullWidth size="small" InputLabelProps={{ shrink: true }} />
          </Grid>
          <Grid item xs={4}>
            <TextField label="% Complete" type="number" value={form.completion_pct} onChange={e => set('completion_pct', e.target.value)} fullWidth size="small" inputProps={{ min: 0, max: 100 }} />
          </Grid>
        </Grid>

        {/* Relationships Section */}
        <Typography variant="subtitle2" fontWeight={700} color="primary" sx={{ mb: 1.5 }}>Relationships & Constraints</Typography>
        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid item xs={6}>
            <TextField label="Predecessor" value={form.predecessor} onChange={e => set('predecessor', e.target.value)} fullWidth size="small" placeholder="e.g. A1020 FS +2d" />
          </Grid>
          <Grid item xs={6}>
            <TextField label="Successor" value={form.successor} onChange={e => set('successor', e.target.value)} fullWidth size="small" placeholder="e.g. A1040 FS" />
          </Grid>
          <Grid item xs={6}>
            <TextField label="Constraint Type" value={form.constraint_type} onChange={e => set('constraint_type', e.target.value)} fullWidth size="small" select>
              {['As Soon As Possible', 'As Late As Possible', 'Start On', 'Finish On', 'Start On or Before', 'Finish On or Before', 'Mandatory Start', 'Mandatory Finish'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
            </TextField>
          </Grid>
          <Grid item xs={6}>
            <TextField label="Constraint Date" type="date" value={form.constraint_date} onChange={e => set('constraint_date', e.target.value)} fullWidth size="small" InputLabelProps={{ shrink: true }} />
          </Grid>
        </Grid>

        {/* Resource Section */}
        <Typography variant="subtitle2" fontWeight={700} color="primary" sx={{ mb: 1.5 }}>Resource</Typography>
        <Grid container spacing={2} sx={{ mb: 2 }}>
          <Grid item xs={6}>
            <TextField label="Primary Resource" value={form.primary_resource} onChange={e => set('primary_resource', e.target.value)} fullWidth size="small" />
          </Grid>
          <Grid item xs={12}>
            <TextField label="Notes / Notebook" value={form.notes} onChange={e => set('notes', e.target.value)} fullWidth size="small" multiline rows={2} placeholder="Add activity notes..." />
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={onClose}>Save Changes</Button>
      </DialogActions>
    </Dialog>
  );
}

/* ═══════════════════════════════════════════
   WBS Form Dialog (mock dependency)
   ═══════════════════════════════════════════ */
function WBSFormDialog({ open, onClose, wbsItem, onSave }) {
  const [form, setForm] = useState({ id: '', name: '', parent: '', status: 'Pending', responsible: '', est_weight: '' });

  useEffect(() => {
    if (wbsItem) {
      setForm({
        id: wbsItem.id,
        name: wbsItem.name,
        parent: wbsItem.parent,
        status: wbsItem.status,
        responsible: wbsItem.level === 0 ? 'John Carter' : 'Sarah Mitchell',
        est_weight: wbsItem.level === 0 ? '25' : '10',
      });
    }
  }, [wbsItem]);

  const set = (field, val) => setForm(f => ({ ...f, [field]: val }));

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <AccountTree color="primary" /> WBS Element Details
      </DialogTitle>
      <DialogContent>
        <Typography variant="caption" color="text.secondary" sx={{ mb: 2, display: 'block' }}>
          Edit WBS element properties. Changes require project schedule recalculation.
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <TextField label="WBS Code" value={form.id} onChange={e => set('id', e.target.value)} fullWidth size="small" />
          <TextField label="WBS Name" value={form.name} onChange={e => set('name', e.target.value)} fullWidth size="small" required />
          <TextField label="Parent WBS" value={form.parent} onChange={e => set('parent', e.target.value)} fullWidth size="small" />
          <TextField label="Status" value={form.status} onChange={e => set('status', e.target.value)} fullWidth size="small" select>
            {['Pending', 'Active', 'Completed', 'On Hold'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
          </TextField>
          <TextField label="Responsible Person" value={form.responsible} onChange={e => set('responsible', e.target.value)} fullWidth size="small" />
          <TextField label="Earned Value Weight (%)" type="number" value={form.est_weight} onChange={e => set('est_weight', e.target.value)} fullWidth size="small" inputProps={{ min: 0, max: 100 }} />
        </Box>
      </DialogContent>
      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={() => { if (onSave) onSave(); onClose(); }}>Save Changes</Button>
      </DialogActions>
    </Dialog>
  );
}

/* ═══════════════════════════════════════════
   Resource Form Dialog (mock dependency)
   ═══════════════════════════════════════════ */
function ResourceFormDialog({ open, onClose, resource, onSave }) {
  const [form, setForm] = useState({ id: '', name: '', role: '', type: 'Labour', unit: 'hrs', rate: '', allocation: '', calendar: 'Standard 5-Day', max_units: '100', email: '' });

  useEffect(() => {
    if (resource) {
      setForm({
        id: resource.id,
        name: resource.name,
        role: resource.role,
        type: resource.type,
        unit: resource.unit,
        rate: String(resource.rate),
        allocation: String(resource.allocation),
        calendar: 'Standard 5-Day',
        max_units: resource.type === 'Labour' ? '100' : '-',
        email: resource.type === 'Labour' ? `${resource.name.toLowerCase().replace(' ', '.')}@pmhub.com` : '',
      });
    }
  }, [resource]);

  const set = (field, val) => setForm(f => ({ ...f, [field]: val }));

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <Person color="primary" /> Resource Details
      </DialogTitle>
      <DialogContent>
        <Typography variant="caption" color="text.secondary" sx={{ mb: 2, display: 'block' }}>
          Update resource assignment details. Rate changes will recalculate project costs.
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <TextField label="Resource ID" value={form.id} onChange={e => set('id', e.target.value)} fullWidth size="small" />
          <TextField label="Resource Name" value={form.name} onChange={e => set('name', e.target.value)} fullWidth size="small" required />
          <TextField label="Role / Description" value={form.role} onChange={e => set('role', e.target.value)} fullWidth size="small" />
          <TextField label="Resource Type" value={form.type} onChange={e => set('type', e.target.value)} fullWidth size="small" select>
            {['Labour', 'Equipment', 'Material'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
          </TextField>
          <Grid container spacing={2}>
            <Grid item xs={6}>
              <TextField label="Unit of Measure" value={form.unit} onChange={e => set('unit', e.target.value)} fullWidth size="small" />
            </Grid>
            <Grid item xs={6}>
              <TextField label="Price / Rate (£)" type="number" value={form.rate} onChange={e => set('rate', e.target.value)} fullWidth size="small" />
            </Grid>
          </Grid>
          <Grid container spacing={2}>
            <Grid item xs={6}>
              <TextField label="Allocation (%)" value={form.allocation} onChange={e => set('allocation', e.target.value)} fullWidth size="small" />
            </Grid>
            <Grid item xs={6}>
              <TextField label="Max Units (%)" value={form.max_units} onChange={e => set('max_units', e.target.value)} fullWidth size="small" />
            </Grid>
          </Grid>
          <TextField label="Calendar" value={form.calendar} onChange={e => set('calendar', e.target.value)} fullWidth size="small" select>
            {['Standard 5-Day', 'Standard 7-Day', '24-Hour Calendar', 'Night Shift'].map(o => <MenuItem key={o} value={o}>{o}</MenuItem>)}
          </TextField>
          {form.type === 'Labour' && (
            <TextField label="Email" value={form.email} onChange={e => set('email', e.target.value)} fullWidth size="small" />
          )}
        </Box>
      </DialogContent>
      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={() => { if (onSave) onSave(); onClose(); }}>Save Changes</Button>
      </DialogActions>
    </Dialog>
  );
}

/* ═══════════════════════════════════════════
   Activity Approval Form Dialog
   ═══════════════════════════════════════════ */
function ApprovalFormDialog({ open, onClose, itemId, itemName, itemType = 'Activity', onApprove }) {
  const [form, setForm] = useState({
    requested_by: '',
    reason: '',
    change_description: '',
    priority: 'Normal',
    target_date: '',
  });

  useEffect(() => {
    if (open) {
      setForm({
        requested_by: '',
        reason: '',
        change_description: '',
        priority: 'Normal',
        target_date: '',
      });
    }
  }, [open]);

  const set = (field, val) => setForm(f => ({ ...f, [field]: val }));

  const handleSubmit = () => {
    if (!form.requested_by || !form.reason || !form.change_description) return;
    onApprove(itemId, form);
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <FormIcon color="primary" /> Request Approval to Edit
      </DialogTitle>
      <DialogContent>
        <Typography variant="caption" color="text.secondary" sx={{ mb: 1, display: 'block' }}>
          {itemType}: <strong>{itemName || '-'}</strong>
        </Typography>
        <Typography variant="caption" color="text.secondary" sx={{ mb: 2, display: 'block' }}>
          Fill out this form to request approval for modifying the {itemType.toLowerCase()}. Once approved, the edit option will be enabled.
        </Typography>
        <Divider sx={{ mb: 2 }} />
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <TextField
            label="Requested By"
            value={form.requested_by}
            onChange={e => set('requested_by', e.target.value)}
            fullWidth size="small" required
          />
          <TextField
            label="Reason for Change"
            value={form.reason}
            onChange={e => set('reason', e.target.value)}
            fullWidth size="small" required select
          >
            {['Schedule Update', 'Scope Change', 'Resource Reallocation', 'Budget Adjustment', 'Client Request', 'Error Correction', 'Other'].map(o => (
              <MenuItem key={o} value={o}>{o}</MenuItem>
            ))}
          </TextField>
          <TextField
            label="Description of Proposed Changes"
            value={form.change_description}
            onChange={e => set('change_description', e.target.value)}
            fullWidth size="small" required
            multiline rows={3}
            placeholder="Describe what changes you want to make and why..."
          />
          <TextField
            label="Priority"
            value={form.priority}
            onChange={e => set('priority', e.target.value)}
            fullWidth size="small" select
          >
            {['Low', 'Normal', 'High', 'Urgent'].map(o => (
              <MenuItem key={o} value={o}>{o}</MenuItem>
            ))}
          </TextField>
          <TextField
            label="Target Completion Date"
            type="date"
            value={form.target_date}
            onChange={e => set('target_date', e.target.value)}
            fullWidth size="small"
            InputLabelProps={{ shrink: true }}
          />
        </Box>
      </DialogContent>
      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={onClose}>Cancel</Button>
        <Button
          variant="contained"
          onClick={handleSubmit}
          disabled={!form.requested_by || !form.reason || !form.change_description}
        >
          Submit for Approval
        </Button>
      </DialogActions>
    </Dialog>
  );
}

/* ═══════════════════════════════════════════
   Main Component
   ═══════════════════════════════════════════ */
export default function ProjectActivities() {
  const { selectedProjectId } = useProject();
  const [tab, setTab] = useState(0);
  const [activities, setActivities] = useState([]);
  const [milestones, setMilestones] = useState([]);
  const [cbsItems, setCbsItems] = useState([]);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [dialog, setDialog] = useState({ open: false, title: '', fields: [], values: {}, onSubmit: null });
  const [milestoneView, setMilestoneView] = useState('table');
  const [snack, setSnack] = useState({ open: false, message: '', severity: 'success' });

  /* Detail form state */
  const [activityDetail, setActivityDetail] = useState({ open: false, activity: null });
  const [wbsForm, setWbsForm] = useState({ open: false, item: null });
  const [resourceForm, setResourceForm] = useState({ open: false, resource: null });

  /* Approval workflow state: tracks which items are approved for editing */
  // { [id]: 'approved' } — only approved entries exist; absent means needs approval
  const [approvalStatus, setApprovalStatus] = useState({});
  const [wbsApprovalStatus, setWbsApprovalStatus] = useState({});
  const [resApprovalStatus, setResApprovalStatus] = useState({});
  const [approvalDialog, setApprovalDialog] = useState({ open: false, activity: null });
  const [wbsApprovalDialog, setWbsApprovalDialog] = useState({ open: false, item: null });
  const [resApprovalDialog, setResApprovalDialog] = useState({ open: false, item: null });

  /* WBS & Resources pagination */
  const [wbsPage, setWbsPage] = useState(0);
  const [wbsRowsPerPage, setWbsRowsPerPage] = useState(15);
  const [resPage, setResPage] = useState(0);

  const showSnack = (message, severity = 'success') => setSnack({ open: true, message, severity });

  const loadActivities = useCallback(async (pid) => {
    try { setActivities((await getActivities(pid)).data); } catch { /* */ }
  }, []);
  const loadMilestones = useCallback(async (pid) => {
    try { setMilestones((await getMilestones(pid)).data); } catch { /* */ }
  }, []);
  const loadCBS = useCallback(async (pid) => {
    try { setCbsItems((await getCBS(pid)).data); } catch { /* */ }
  }, []);

  useEffect(() => {
    if (selectedProjectId) {
      loadActivities(selectedProjectId);
      loadMilestones(selectedProjectId);
      loadCBS(selectedProjectId);
    }
  }, [selectedProjectId, loadActivities, loadMilestones, loadCBS]);

  const openForm = (title, fields, values, onSubmit) => setDialog({ open: true, title, fields, values: { ...values }, onSubmit });
  const closeForm = () => setDialog({ ...dialog, open: false });
  const handleChange = (name, value) => setDialog((d) => ({ ...d, values: { ...d.values, [name]: value } }));

  const handleCreateActivity = () =>
    openForm('New Activity', ACTIVITY_FIELDS, { phase: 'Construction', completion_pct: 0, is_milestone: false, is_critical: false }, async (vals) => {
      await createActivity({ ...vals, project_id: selectedProjectId });
      closeForm();
      loadActivities(selectedProjectId);
      showSnack('Activity created');
    });
  const handleEditActivity = (a) =>
    openForm('Edit Activity', ACTIVITY_FIELDS, a, async (vals) => {
      await updateActivity(a.id, vals);
      closeForm();
      loadActivities(selectedProjectId);
      showSnack('Activity updated');
    });
  const handleDeleteActivity = async (id) => {
    if (!window.confirm('Delete this activity?')) return;
    await deleteActivity(id);
    loadActivities(selectedProjectId);
    showSnack('Activity deleted');
  };

  /* Approval workflow handlers */
  const handleOpenApprovalForm = (activity) => {
    setApprovalDialog({ open: true, activity });
  };
  const handleCloseApprovalForm = () => {
    setApprovalDialog({ open: false, activity: null });
  };
  const handleApproveActivity = (activityId) => {
    setApprovalStatus(prev => ({ ...prev, [activityId]: 'approved' }));
    setApprovalDialog({ open: false, activity: null });
    showSnack('Approval granted — you can now edit this activity');
  };
  const handleEditApprovedActivity = (a) => {
    openForm('Edit Activity', ACTIVITY_FIELDS, a, async (vals) => {
      await updateActivity(a.id, vals);
      closeForm();
      // After saving, revoke approval so user must re-approve for next edit
      setApprovalStatus(prev => {
        const next = { ...prev };
        delete next[a.id];
        return next;
      });
      loadActivities(selectedProjectId);
      showSnack('Activity updated — approval reset');
    });
  };

  /* WBS Approval workflow handlers */
  const handleOpenWbsApproval = (item) => {
    setWbsApprovalDialog({ open: true, item });
  };
  const handleCloseWbsApproval = () => {
    setWbsApprovalDialog({ open: false, item: null });
  };
  const handleApproveWbs = (itemId) => {
    setWbsApprovalStatus(prev => ({ ...prev, [itemId]: 'approved' }));
    setWbsApprovalDialog({ open: false, item: null });
    showSnack('Approval granted — you can now edit this WBS element');
  };
  const handleEditApprovedWbs = (w) => {
    setWbsForm({ open: true, item: w, onSave: () => {
      setWbsApprovalStatus(prev => {
        const next = { ...prev };
        delete next[w.id];
        return next;
      });
      showSnack('WBS updated — approval reset');
    }});
  };

  /* Resource Approval workflow handlers */
  const handleOpenResApproval = (item) => {
    setResApprovalDialog({ open: true, item });
  };
  const handleCloseResApproval = () => {
    setResApprovalDialog({ open: false, item: null });
  };
  const handleApproveRes = (itemId) => {
    setResApprovalStatus(prev => ({ ...prev, [itemId]: 'approved' }));
    setResApprovalDialog({ open: false, item: null });
    showSnack('Approval granted — you can now edit this resource');
  };
  const handleEditApprovedRes = (r) => {
    setResourceForm({ open: true, resource: r, onSave: () => {
      setResApprovalStatus(prev => {
        const next = { ...prev };
        delete next[r.id];
        return next;
      });
      showSnack('Resource updated — approval reset');
    }});
  };

  const handleCreateMilestone = () =>
    openForm('New Milestone', MILESTONE_FIELDS, { phase: 'Construction', is_critical: false }, async (vals) => {
      try {
        await createMilestone({ ...vals, project_id: selectedProjectId });
        closeForm();
        loadMilestones(selectedProjectId);
        showSnack('Milestone created');
      } catch (err) {
        showSnack(err.response?.data?.detail || 'Error', 'error');
      }
    });
  const handleEditMilestone = (m) =>
    openForm('Edit Milestone', MILESTONE_FIELDS, m, async (vals) => {
      try {
        await updateMilestone(m.id, vals);
        closeForm();
        loadMilestones(selectedProjectId);
        showSnack('Milestone updated');
      } catch (err) {
        showSnack(err.response?.data?.detail || 'Error', 'error');
      }
    });
  const handleDeleteMilestone = async (id) => {
    if (!window.confirm('Delete this milestone?')) return;
    await deleteMilestone(id);
    loadMilestones(selectedProjectId);
    showSnack('Milestone deleted');
  };

  if (!selectedProjectId) {
    return (
      <Paper sx={{ p: 4, textAlign: 'center' }}>
        <Typography color="text.secondary">Select a project to view activities</Typography>
      </Paper>
    );
  }

  const scheduleKPIs = computeScheduleKPIs(activities);
  const totalBudget = cbsItems.reduce((s, c) => s + (c.budget_cost || 0), 0);
  const totalActual = cbsItems.reduce((s, c) => s + (c.actual_cost || 0), 0);
  const cpi = totalActual > 0 ? +(totalBudget / totalActual).toFixed(2) : 1.00;

  const ganttData = activities.map((a) => {
    const startRef = new Date(Math.min(...activities.map((x) => new Date(x.planned_start).getTime())));
    const pStart = Math.round((new Date(a.planned_start) - startRef) / 86400000);
    const pDur = Math.max(1, Math.round((new Date(a.planned_finish) - new Date(a.planned_start)) / 86400000));
    return {
      name: a.activity_name.length > 25 ? a.activity_name.substring(0, 25) + '...' : a.activity_name,
      pStart, pDur, critical: a.is_critical, status: a.status,
    };
  });

  return (
    <Box>
      {activities.length > 0 && (
        <Grid container spacing={2} sx={{ mb: 2 }}>
          <Grid item xs={6} sm={3} md>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color={scheduleKPIs.spi >= 0.95 ? '#2e7d32' : scheduleKPIs.spi >= 0.85 ? '#ed6c02' : '#d32f2f'}>{scheduleKPIs.spi}</Typography>
              <Typography variant="caption" color="text.secondary">SPI</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color={cpi >= 0.95 ? '#2e7d32' : cpi >= 0.85 ? '#ed6c02' : '#d32f2f'}>{cpi}</Typography>
              <Typography variant="caption" color="text.secondary">CPI</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color="#d32f2f">{scheduleKPIs.delayDays}</Typography>
              <Typography variant="caption" color="text.secondary">Max Delay (days)</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color="#2e7d32">{scheduleKPIs.completed}</Typography>
              <Typography variant="caption" color="text.secondary">Completed</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color="#1976d2">{scheduleKPIs.onTrack}</Typography>
              <Typography variant="caption" color="text.secondary">On Track</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color="#ed6c02">{scheduleKPIs.delayed}</Typography>
              <Typography variant="caption" color="text.secondary">Delayed</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={6} sm={3} md>
            <Card><CardContent sx={{ textAlign: 'center', p: 1.5, '&:last-child': { pb: 1.5 } }}>
              <Typography variant="h5" fontWeight={700} color="#9c27b0">{milestones.filter((m) => m.is_critical).length}</Typography>
              <Typography variant="caption" color="text.secondary">Critical Milestones</Typography>
            </CardContent></Card>
          </Grid>
        </Grid>
      )}

      <Tabs value={tab} onChange={(_, v) => { setTab(v); setPage(0); }} sx={{ mb: 2 }}>
        <Tab label="Activities" />
        <Tab label="Milestones" />
        <Tab label="Gantt View" />
        <Tab label="WBS" icon={<AccountTree sx={{ fontSize: 18 }} />} iconPosition="start" />
        <Tab label="Resources" icon={<Person sx={{ fontSize: 18 }} />} iconPosition="start" />
      </Tabs>

      {/* Activities Tab */}
      {tab === 0 && (
        <Paper>
          <Box sx={{ display: 'flex', justifyContent: 'flex-end', p: 2 }}>
            <Button variant="contained" startIcon={<Add />} onClick={handleCreateActivity}>New Activity</Button>
          </Box>
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  {['Code', 'Activity', 'Phase', 'P.Start', 'P.Finish', 'A.Start', 'A.Finish', '%', 'Status', 'Delay', 'Critical', 'Actions'].map((h) => (
                    <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                  ))}
                </TableRow>
              </TableHead>
              <TableBody>
                {activities.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((a, idx) => (
                  <TableRow
                    key={a.id}
                    sx={{
                      bgcolor: a.is_critical ? '#fff3e0' : idx % 2 === 0 ? '#fafafa' : '#ffffff',
                      cursor: 'pointer',
                      '&:hover': { bgcolor: '#f0f4ff' },
                    }}
                    onClick={() => setActivityDetail({ open: true, activity: a })}
                  >
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
                      <Box sx={{ display: 'flex', gap: 0.5 }}>
                        <Tooltip title={approvalStatus[a.id] === 'approved' ? 'Approved' : 'Request Approval to Edit'}>
                          <span>
                            <IconButton
                              size="small"
                              color={approvalStatus[a.id] === 'approved' ? 'default' : 'primary'}
                              disabled={approvalStatus[a.id] === 'approved'}
                              onClick={(e) => { e.stopPropagation(); handleOpenApprovalForm(a); }}
                            >
                              <FormIcon fontSize="small" />
                            </IconButton>
                          </span>
                        </Tooltip>
                        <Tooltip title={approvalStatus[a.id] === 'approved' ? 'Edit Activity' : 'Approval required before editing'}>
                          <span>
                            <IconButton
                              size="small"
                              color={approvalStatus[a.id] === 'approved' ? 'primary' : 'default'}
                              disabled={approvalStatus[a.id] !== 'approved'}
                              onClick={(e) => { e.stopPropagation(); handleEditApprovedActivity(a); }}
                            >
                              <Edit fontSize="small" />
                            </IconButton>
                          </span>
                        </Tooltip>
                      </Box>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          <TablePagination component="div" count={activities.length} page={page} onPageChange={(_, p) => setPage(p)}
            rowsPerPage={rowsPerPage} onRowsPerPageChange={(e) => { setRowsPerPage(+e.target.value); setPage(0); }} />
        </Paper>
      )}

      {/* Milestones Tab */}
      {tab === 1 && (
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
                    {['Milestone', 'Phase', 'Planned', 'Actual', 'Status', 'Delay', 'Critical', 'Actions'].map((h) => (
                      <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                    ))}
                  </TableRow></TableHead>
                  <TableBody>
                    {milestones.map((m) => (
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
                <BarChart data={milestones.map((m) => ({
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
      {tab === 2 && (
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
          ) : (
            <Typography color="text.secondary">No activities to display</Typography>
          )}
        </Paper>
      )}

      {/* WBS Tab */}
      {tab === 3 && (
        <Paper>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2 }}>
            <Typography variant="subtitle1" fontWeight={600}>Work Breakdown Structure</Typography>
            <Button variant="contained" startIcon={<Add />} onClick={() => setWbsForm({ open: true, item: { id: '', name: '', level: 1, parent: '', status: 'Pending' } })}>
              Add WBS Element
            </Button>
          </Box>
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  {['WBS Code', 'Name', 'Parent', 'Status', 'Actions'].map((h) => (
                    <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                  ))}
                </TableRow>
              </TableHead>
              <TableBody>
                {MOCK_WBS.slice(wbsPage * wbsRowsPerPage, wbsPage * wbsRowsPerPage + wbsRowsPerPage).map((w) => (
                  <TableRow
                    key={w.id}
                    sx={{
                      cursor: 'pointer',
                      bgcolor: w.isGate && w.level === 0 ? '#fff8e1' : w.isGate ? '#fffde7' : w.level === 0 ? '#f5f7fa' : 'inherit',
                      borderLeft: w.isGate ? '4px solid #f57c00' : 'none',
                      '&:hover': { bgcolor: w.isGate ? '#fff3e0' : '#f0f4ff' },
                    }}
                    onClick={() => setWbsForm({ open: true, item: w })}
                  >
                    <TableCell>
                      <Typography variant="body2" fontWeight={w.level === 0 ? 700 : 400} sx={{ pl: w.level * 3, color: w.isGate && w.level === 0 ? '#e65100' : 'inherit' }}>
                        {w.id}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, pl: w.level * 3 }}>
                        {w.isGate && w.level === 0 && <FlagCircle sx={{ fontSize: 18, color: '#f57c00' }} />}
                        <Typography fontWeight={w.level === 0 ? 600 : 400} sx={{ color: w.isGate && w.level === 0 ? '#e65100' : 'inherit' }}>
                          {w.name}
                        </Typography>
                      </Box>
                    </TableCell>
                    <TableCell>{w.parent}</TableCell>
                    <TableCell>
                      <Chip
                        label={w.status}
                        size="small"
                        color={w.status === 'Completed' ? 'success' : w.status === 'Active' ? 'primary' : 'default'}
                        variant="outlined"
                        sx={w.isGate && w.level === 0 ? { borderColor: '#f57c00', color: w.status === 'Completed' ? undefined : '#f57c00' } : {}}
                      />
                    </TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', gap: 0.5 }}>
                        <Tooltip title={wbsApprovalStatus[w.id] === 'approved' ? 'Approved' : 'Request Approval to Edit'}>
                          <span>
                            <IconButton
                              size="small"
                              color={wbsApprovalStatus[w.id] === 'approved' ? 'default' : 'primary'}
                              disabled={wbsApprovalStatus[w.id] === 'approved'}
                              onClick={(e) => { e.stopPropagation(); handleOpenWbsApproval(w); }}
                            >
                              <FormIcon fontSize="small" />
                            </IconButton>
                          </span>
                        </Tooltip>
                        <Tooltip title={wbsApprovalStatus[w.id] === 'approved' ? 'Edit WBS Element' : 'Approval required before editing'}>
                          <span>
                            <IconButton
                              size="small"
                              color={wbsApprovalStatus[w.id] === 'approved' ? 'primary' : 'default'}
                              disabled={wbsApprovalStatus[w.id] !== 'approved'}
                              onClick={(e) => { e.stopPropagation(); handleEditApprovedWbs(w); }}
                            >
                              <Edit fontSize="small" />
                            </IconButton>
                          </span>
                        </Tooltip>
                      </Box>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          <TablePagination component="div" count={MOCK_WBS.length} page={wbsPage} onPageChange={(_, p) => setWbsPage(p)}
            rowsPerPage={wbsRowsPerPage} onRowsPerPageChange={(e) => { setWbsRowsPerPage(parseInt(e.target.value, 10)); setWbsPage(0); }} rowsPerPageOptions={[15, 25]} />
        </Paper>
      )}

      {/* Resources Tab */}
      {tab === 4 && (
        <Paper>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2 }}>
            <Typography variant="subtitle1" fontWeight={600}>Resource Assignments</Typography>
            <Button variant="contained" startIcon={<Add />}
              onClick={() => setResourceForm({ open: true, resource: { id: '', name: '', role: '', type: 'Labour', unit: 'hrs', rate: 0, allocation: 100 } })}>
              Add Resource
            </Button>
          </Box>
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  {['ID', 'Resource Name', 'Role', 'Type', 'Unit', 'Rate (£)', 'Allocation %', 'Actions'].map((h) => (
                    <TableCell key={h} sx={{ fontWeight: 600 }}>{h}</TableCell>
                  ))}
                </TableRow>
              </TableHead>
              <TableBody>
                {MOCK_RESOURCES.slice(resPage * 10, resPage * 10 + 10).map((r) => (
                  <TableRow
                    key={r.id}
                    sx={{ cursor: 'pointer', '&:hover': { bgcolor: '#f0f4ff' } }}
                    onClick={() => setResourceForm({ open: true, resource: r })}
                  >
                    <TableCell><Typography variant="body2" color="text.secondary">{r.id}</Typography></TableCell>
                    <TableCell><Typography fontWeight={500}>{r.name}</Typography></TableCell>
                    <TableCell>{r.role !== '-' ? r.role : '-'}</TableCell>
                    <TableCell>
                      <Chip
                        label={r.type}
                        size="small"
                        color={r.type === 'Labour' ? 'primary' : r.type === 'Equipment' ? 'warning' : 'default'}
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell>{r.unit}</TableCell>
                    <TableCell>£{r.rate.toLocaleString()}</TableCell>
                    <TableCell>{r.allocation !== '-' ? `${r.allocation}%` : '-'}</TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', gap: 0.5 }}>
                        <Tooltip title={resApprovalStatus[r.id] === 'approved' ? 'Approved' : 'Request Approval to Edit'}>
                          <span>
                            <IconButton
                              size="small"
                              color={resApprovalStatus[r.id] === 'approved' ? 'default' : 'primary'}
                              disabled={resApprovalStatus[r.id] === 'approved'}
                              onClick={(e) => { e.stopPropagation(); handleOpenResApproval(r); }}
                            >
                              <FormIcon fontSize="small" />
                            </IconButton>
                          </span>
                        </Tooltip>
                        <Tooltip title={resApprovalStatus[r.id] === 'approved' ? 'Edit Resource' : 'Approval required before editing'}>
                          <span>
                            <IconButton
                              size="small"
                              color={resApprovalStatus[r.id] === 'approved' ? 'primary' : 'default'}
                              disabled={resApprovalStatus[r.id] !== 'approved'}
                              onClick={(e) => { e.stopPropagation(); handleEditApprovedRes(r); }}
                            >
                              <Edit fontSize="small" />
                            </IconButton>
                          </span>
                        </Tooltip>
                      </Box>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          <TablePagination component="div" count={MOCK_RESOURCES.length} page={resPage} onPageChange={(_, p) => setResPage(p)}
            rowsPerPage={10} rowsPerPageOptions={[10]} />
        </Paper>
      )}

      {/* Dependency Forms */}
      <ActivityDetailsDialog
        open={activityDetail.open}
        onClose={() => setActivityDetail({ open: false, activity: null })}
        activity={activityDetail.activity}
      />
      <WBSFormDialog
        open={wbsForm.open}
        onClose={() => setWbsForm({ open: false, item: null })}
        wbsItem={wbsForm.item}
        onSave={wbsForm.onSave}
      />
      <ResourceFormDialog
        open={resourceForm.open}
        onClose={() => setResourceForm({ open: false, resource: null })}
        resource={resourceForm.resource}
        onSave={resourceForm.onSave}
      />

      <ApprovalFormDialog
        open={approvalDialog.open}
        onClose={handleCloseApprovalForm}
        itemId={approvalDialog.activity?.id}
        itemName={approvalDialog.activity?.activity_name}
        itemType="Activity"
        onApprove={handleApproveActivity}
      />
      <ApprovalFormDialog
        open={wbsApprovalDialog.open}
        onClose={handleCloseWbsApproval}
        itemId={wbsApprovalDialog.item?.id}
        itemName={wbsApprovalDialog.item?.name}
        itemType="WBS Element"
        onApprove={handleApproveWbs}
      />
      <ApprovalFormDialog
        open={resApprovalDialog.open}
        onClose={handleCloseResApproval}
        itemId={resApprovalDialog.item?.id}
        itemName={resApprovalDialog.item?.name}
        itemType="Resource"
        onApprove={handleApproveRes}
      />
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
