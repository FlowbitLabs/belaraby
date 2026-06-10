import { Box, Button, Typography } from "@mui/material";
import LockIcon from "@mui/icons-material/Lock";
import { useLogout } from "react-admin";

/**
 * Shown to authenticated users whose profile has is_admin = false.
 * Defense-in-UX only — RLS (public.is_admin()) remains the real boundary.
 */
export const AccessDenied = () => {
  const logout = useLogout();
  return (
    <Box
      display="flex"
      flexDirection="column"
      alignItems="center"
      justifyContent="center"
      minHeight="60vh"
      gap={2}
      padding={2}
    >
      <LockIcon color="disabled" sx={{ fontSize: 48 }} />
      <Typography variant="h5">Access denied</Typography>
      <Typography color="text.secondary" align="center" maxWidth={480}>
        This account does not have administrator access to the Belaraby
        dashboard. Ask an existing administrator to enable the Admin flag on
        your profile, then sign in again.
      </Typography>
      <Button variant="outlined" onClick={() => void logout()}>
        Sign out
      </Button>
    </Box>
  );
};
