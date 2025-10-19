import { AdminGuesser } from "ra-supabase";
import { Layout } from "./Layout";


const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
const SUPABASE_API_KEY = import.meta.env.VITE_SUPABASE_API_KEY;

export const App = () => (
  <AdminGuesser
    instanceUrl={SUPABASE_URL}
    apiKey={SUPABASE_API_KEY}
    layout={Layout}
  />
);
