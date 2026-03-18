import { Admin, Resource } from "react-admin";
import { supabaseDataProvider, supabaseAuthProvider } from "ra-supabase";
import { createClient } from "@supabase/supabase-js";
import { Layout } from "./Layout";

// Resources
import {
  LessonList,
  LessonEdit,
  LessonCreate,
} from "./resources/lessons";
import { ProfileList, ProfileEdit } from "./resources/profiles";
import { SubscriptionList } from "./resources/subscriptions";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

const dataProvider = supabaseDataProvider({
  instanceUrl: supabaseUrl,
  apiKey: supabaseKey,
  supabaseClient: supabase,
});

const authProvider = supabaseAuthProvider(supabase, {
  getIdentity: async (user) => ({
    id: user.id,
    fullName: user.email ?? user.id,
  }),
});

export const App = () => (
  <Admin
    dataProvider={dataProvider}
    authProvider={authProvider}
    layout={Layout}
  >
    <Resource
      name="lessons"
      list={LessonList}
      edit={LessonEdit}
      create={LessonCreate}
    />
    <Resource name="profiles" list={ProfileList} edit={ProfileEdit} />
    <Resource name="subscriptions" list={SubscriptionList} />
  </Admin>
);
