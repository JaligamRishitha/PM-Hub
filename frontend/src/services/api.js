import axios from 'axios';

const API_BASE = import.meta.env.VITE_API_URL || '';

const api = axios.create({
  baseURL: API_BASE,
  headers: { 'Content-Type': 'application/json' },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auth
export const login = (username, password) => {
  const form = new URLSearchParams();
  form.append('username', username);
  form.append('password', password);
  return api.post('/api/auth/login', form, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  });
};
export const register = (data) => api.post('/api/auth/register', data);
export const getMe = () => api.get('/api/auth/me');

// Dashboard
export const getDashboardSummary = () => api.get('/api/dashboard/summary');
export const getUpcomingMilestones = () => api.get('/api/dashboard/upcoming-milestones');
export const getBudgetVsActual = () => api.get('/api/dashboard/budget-vs-actual');
export const getCashflow = () => api.get('/api/dashboard/cashflow');
export const getPortfolioHealth = () => api.get('/api/dashboard/portfolio-health');
export const getDashboardRiskHeatmap = () => api.get('/api/dashboard/risk-heatmap');
export const getPlannedVsActual = (projectId) => api.get('/api/dashboard/planned-vs-actual', { params: projectId ? { project_id: projectId } : {} });
export const getDelayedMilestones = () => api.get('/api/dashboard/delayed-milestones');
export const getOpenRisks = () => api.get('/api/dashboard/open-risks');

// Portfolio
export const getOrganizations = () => api.get('/api/portfolio/organizations');
export const createOrganization = (data) => api.post('/api/portfolio/organizations', data);
export const updateOrganization = (id, data) => api.put(`/api/portfolio/organizations/${id}`, data);
export const deleteOrganization = (id) => api.delete(`/api/portfolio/organizations/${id}`);
export const getProgrammes = (orgId) =>
  api.get('/api/portfolio/programmes', { params: orgId ? { organization_id: orgId } : {} });
export const createProgramme = (data) => api.post('/api/portfolio/programmes', data);
export const updateProgramme = (id, data) => api.put(`/api/portfolio/programmes/${id}`, data);
export const deleteProgramme = (id) => api.delete(`/api/portfolio/programmes/${id}`);
export const getPortfolioHierarchy = () => api.get('/api/portfolio/hierarchy');
export const getPortfolioKPIs = () => api.get('/api/portfolio/kpis');

// Projects
export const getProjects = () => api.get('/api/projects/');
export const getProject = (id) => api.get(`/api/projects/${id}`);
export const createProject = (data) => api.post('/api/projects/', data);
export const updateProject = (id, data) => api.put(`/api/projects/${id}`, data);
export const deleteProject = (id) => api.delete(`/api/projects/${id}`);

// WBS
export const getWBS = (projectId) => api.get('/api/wbs', { params: { project_id: projectId } });
export const createWBS = (data) => api.post('/api/wbs', data);
export const updateWBS = (id, data) => api.put(`/api/wbs/${id}`, data);
export const deleteWBS = (id) => api.delete(`/api/wbs/${id}`);

// Activities
export const getActivities = (projectId) =>
  api.get('/api/activities/', { params: projectId ? { project_id: projectId } : {} });
export const createActivity = (data) => api.post('/api/activities/', data);
export const updateActivity = (id, data) => api.put(`/api/activities/${id}`, data);
export const deleteActivity = (id) => api.delete(`/api/activities/${id}`);

// Milestones
export const getMilestones = (projectId) =>
  api.get('/api/milestones/', { params: projectId ? { project_id: projectId } : {} });
export const createMilestone = (data) => api.post('/api/milestones/', data);
export const updateMilestone = (id, data) => api.put(`/api/milestones/${id}`, data);
export const deleteMilestone = (id) => api.delete(`/api/milestones/${id}`);

// CBS
export const getCBS = (projectId) =>
  api.get('/api/cbs/', { params: projectId ? { project_id: projectId } : {} });
export const createCBS = (data) => api.post('/api/cbs/', data);
export const updateCBS = (id, data) => api.put(`/api/cbs/${id}`, data);
export const deleteCBS = (id) => api.delete(`/api/cbs/${id}`);

// Variations
export const getVariations = (projectId) =>
  api.get('/api/variations', { params: projectId ? { project_id: projectId } : {} });
export const createVariation = (data) => api.post('/api/variations', data);
export const updateVariation = (id, data) => api.put(`/api/variations/${id}`, data);
export const deleteVariation = (id) => api.delete(`/api/variations/${id}`);

// Compensation Events
export const getCompensationEvents = (projectId) =>
  api.get('/api/compensation-events/', { params: projectId ? { project_id: projectId } : {} });
export const createCompensationEvent = (data) => api.post('/api/compensation-events/', data);
export const updateCompensationEvent = (id, data) => api.put(`/api/compensation-events/${id}`, data);
export const deleteCompensationEvent = (id) => api.delete(`/api/compensation-events/${id}`);

// Payments
export const getPayments = (milestoneId) =>
  api.get('/api/payments/', { params: milestoneId ? { milestone_id: milestoneId } : {} });
export const createPayment = (data) => api.post('/api/payments/', data);
export const updatePayment = (id, data) => api.put(`/api/payments/${id}`, data);
export const deletePayment = (id) => api.delete(`/api/payments/${id}`);

// Risks
export const getRisks = (projectId) =>
  api.get('/api/risks', { params: projectId ? { project_id: projectId } : {} });
export const getRiskHeatmap = (projectId) =>
  api.get('/api/risks/heatmap', { params: projectId ? { project_id: projectId } : {} });
export const getTopRisks = (limit = 5, projectId) =>
  api.get('/api/risks/top', { params: { limit, ...(projectId ? { project_id: projectId } : {}) } });
export const createRisk = (data) => api.post('/api/risks', data);
export const updateRisk = (id, data) => api.put(`/api/risks/${id}`, data);
export const deleteRisk = (id) => api.delete(`/api/risks/${id}`);

// Issues
export const getIssues = (projectId) =>
  api.get('/api/issues', { params: projectId ? { project_id: projectId } : {} });
export const getOverdueIssues = (projectId) =>
  api.get('/api/issues/overdue', { params: projectId ? { project_id: projectId } : {} });
export const createIssue = (data) => api.post('/api/issues', data);
export const updateIssue = (id, data) => api.put(`/api/issues/${id}`, data);
export const deleteIssue = (id) => api.delete(`/api/issues/${id}`);

// Safety
export const getSafetyIncidents = (projectId) =>
  api.get('/api/safety-incidents/', { params: projectId ? { project_id: projectId } : {} });
export const createSafetyIncident = (data) => api.post('/api/safety-incidents/', data);
export const updateSafetyIncident = (id, data) => api.put(`/api/safety-incidents/${id}`, data);
export const deleteSafetyIncident = (id) => api.delete(`/api/safety-incidents/${id}`);

// HSE Checklist
export const getHSEChecklist = (projectId) =>
  api.get('/api/hse-checklist/', { params: projectId ? { project_id: projectId } : {} });
export const createHSEItem = (data) => api.post('/api/hse-checklist/', data);
export const updateHSEItem = (id, data) => api.put(`/api/hse-checklist/${id}`, data);
export const deleteHSEItem = (id) => api.delete(`/api/hse-checklist/${id}`);

// Documents
export const getDocuments = (projectId) =>
  api.get('/api/documents', { params: projectId ? { project_id: projectId } : {} });
export const createDocument = (data) => api.post('/api/documents', data);
export const updateDocument = (id, data) => api.put(`/api/documents/${id}`, data);
export const deleteDocument = (id) => api.delete(`/api/documents/${id}`);

// Admin
export const getUsers = () => api.get('/api/auth/users');
export const updateUser = (id, data) => api.put(`/api/auth/users/${id}`, data);

// Reports
export const getOverallReport = (projectId) => api.get(`/api/reports/${projectId}/overall`);
export const getMilestoneReport = (projectId) => api.get(`/api/reports/${projectId}/milestones`);
export const getEarnedValueReport = (projectId) => api.get(`/api/reports/${projectId}/earned-value`);
export const getIssuesRiskReport = (projectId) => api.get(`/api/reports/${projectId}/issues-risks`);

// Export
export const exportToExcel = () =>
  api.get('/api/export/projects', { responseType: 'blob' });

// Simulation
export const startSimulation = (data) => api.post('/api/simulation/start', data);
export const runSimulation = (data) => api.post('/api/simulation/run', data);
export const getSimulationSession = (id) => api.get(`/api/simulation/${id}`);
export const listSimulationSessions = (projectId) =>
  api.get('/api/simulation/sessions', { params: projectId ? { project_id: projectId } : {} });
export const applySimulation = (id) => api.post(`/api/simulation/${id}/apply`);
export const discardSimulation = (id) => api.post(`/api/simulation/${id}/discard`);

export default api;
