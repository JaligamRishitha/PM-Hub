import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { getProjects, getProject } from '../services/api';

const ProjectContext = createContext(null);

export function ProjectProvider({ children }) {
  const [projects, setProjects] = useState([]);
  const [selectedProjectId, setSelectedProjectId] = useState(null);
  const [selectedProject, setSelectedProject] = useState(null);
  const [loading, setLoading] = useState(false);

  const loadProjects = useCallback(async () => {
    try {
      setLoading(true);
      const res = await getProjects();
      setProjects(res.data);
    } catch {
      /* silent */
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadProjects();
  }, [loadProjects]);

  useEffect(() => {
    if (selectedProjectId) {
      const proj = projects.find((p) => p.id === selectedProjectId);
      if (proj) {
        setSelectedProject(proj);
      } else {
        getProject(selectedProjectId)
          .then((res) => setSelectedProject(res.data))
          .catch(() => setSelectedProject(null));
      }
    } else {
      setSelectedProject(null);
    }
  }, [selectedProjectId, projects]);

  return (
    <ProjectContext.Provider
      value={{
        projects,
        selectedProjectId,
        setSelectedProjectId,
        selectedProject,
        loading,
        refreshProjects: loadProjects,
      }}
    >
      {children}
    </ProjectContext.Provider>
  );
}

export function useProject() {
  const ctx = useContext(ProjectContext);
  if (!ctx) throw new Error('useProject must be used within ProjectProvider');
  return ctx;
}
