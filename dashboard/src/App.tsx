import { AdminGuesser } from "ra-supabase";
import { Layout } from "./Layout";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY;

export const App = () => (
  <AdminGuesser
    instanceUrl={supabaseUrl}
    apiKey={supabaseKey}
    layout={Layout}
  />
);
