import React from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions, Button,
  TextField, MenuItem, FormControlLabel, Switch, Box,
} from '@mui/material';

export default function FormDialog({ open, onClose, onSubmit, title, fields, values, onChange }) {
  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(values);
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <form onSubmit={handleSubmit}>
        <DialogTitle>{title}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 1 }}>
            {fields.map((field) => {
              if (field.type === 'boolean') {
                return (
                  <FormControlLabel
                    key={field.name}
                    control={
                      <Switch
                        checked={!!values[field.name]}
                        onChange={(e) => onChange(field.name, e.target.checked)}
                      />
                    }
                    label={field.label}
                  />
                );
              }
              if (field.type === 'select') {
                return (
                  <TextField
                    key={field.name}
                    select
                    label={field.label}
                    value={values[field.name] || ''}
                    onChange={(e) => onChange(field.name, e.target.value)}
                    required={field.required}
                    fullWidth
                    size="small"
                  >
                    {field.options.map((opt) => (
                      <MenuItem key={opt} value={opt}>{opt}</MenuItem>
                    ))}
                  </TextField>
                );
              }
              return (
                <TextField
                  key={field.name}
                  label={field.label}
                  type={field.type || 'text'}
                  value={values[field.name] || ''}
                  onChange={(e) => onChange(field.name, e.target.value)}
                  required={field.required}
                  fullWidth
                  size="small"
                  InputLabelProps={field.type === 'date' ? { shrink: true } : undefined}
                  inputProps={field.type === 'number' ? { step: 'any' } : undefined}
                />
              );
            })}
          </Box>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={onClose}>Cancel</Button>
          <Button type="submit" variant="contained">Save</Button>
        </DialogActions>
      </form>
    </Dialog>
  );
}
