import { Admin, CustomRoutes, Resource, defaultLightTheme } from "react-admin";
import { Route } from "react-router-dom";
import {
  ForgotPasswordPage,
  LoginPage,
  SetPasswordPage,
  defaultI18nProvider,
  supabaseAuthProvider,
  supabaseDataProvider,
} from "ra-supabase";
import { createClient } from "@supabase/supabase-js";
import MenuBookIcon from "@mui/icons-material/MenuBook";
import FavoriteIcon from "@mui/icons-material/Favorite";
import SchoolIcon from "@mui/icons-material/School";
import PeopleIcon from "@mui/icons-material/People";
import WorkspacePremiumIcon from "@mui/icons-material/WorkspacePremium";
import { Layout } from "./Layout";
import { AccessDenied } from "./AccessDenied";
import { compoundPrimaryKeys } from "./primaryKeys";

// Resources
import { LessonList, LessonEdit, LessonCreate } from "./resources/lessons";
import {
  LessonExerciseEdit,
  LessonExerciseCreate,
} from "./resources/lessonExercises";
import {
  LessonExerciseOptionEdit,
  LessonExerciseOptionCreate,
} from "./resources/lessonExerciseOptions";
import {
  LessonGrammarEdit,
  LessonGrammarCreate,
} from "./resources/lessonGrammar";
import {
  LessonKeywordEdit,
  LessonKeywordCreate,
} from "./resources/lessonKeywords";
import { UserFavoriteList } from "./resources/userFavorites";
import { UserLearnedLessonList } from "./resources/userLearnedLessons";
import { ProfileList, ProfileEdit } from "./resources/profiles";
import { SubscriptionList, SubscriptionShow } from "./resources/subscriptions";
import type { Lesson, Profile } from "./types";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
// Must be the anon JWT key (eyJ...) — ra-supabase does not work with the
// sb_publishable_ key format. See DEPLOYMENT.md § Dashboard.
const supabaseKey = import.meta.env.VITE_SUPABASE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

const dataProvider = supabaseDataProvider({
  instanceUrl: supabaseUrl,
  apiKey: supabaseKey,
  supabaseClient: supabase,
  primaryKeys: compoundPrimaryKeys,
});

const authProvider = supabaseAuthProvider(supabase, {
  getIdentity: async (user) => ({
    id: user.id,
    fullName: user.email ?? user.id,
  }),
  // Defense-in-UX only: the UI hides resources from non-admins, but RLS
  // (public.is_admin()) remains the actual security boundary.
  getPermissions: async (user) => {
    const { data, error } = await supabase
      .from("profiles")
      .select("is_admin")
      .eq("id", user.id)
      .single();
    if (error || data == null) {
      return "user";
    }
    return data.is_admin ? "admin" : "user";
  },
});

// Light brand theme. Real logo/favicon are deferred — needs a design asset.
const brandTheme = {
  ...defaultLightTheme,
  palette: {
    ...defaultLightTheme.palette,
    primary: { main: "#00695c" },
    secondary: { main: "#ef6c00" },
  },
};

export const App = () => (
  <Admin
    title="Belaraby Admin"
    dataProvider={dataProvider}
    authProvider={authProvider}
    i18nProvider={defaultI18nProvider}
    layout={Layout}
    // The default react-admin login form submits {username, password},
    // which supabaseAuthProvider rejects ("Invalid login parameters") —
    // ra-supabase's LoginPage submits {email, password}.
    loginPage={LoginPage}
    theme={brandTheme}
  >
    {/* authProvider.handleCallback redirects recovery/invite flows here. */}
    <CustomRoutes noLayout>
      <Route path={ForgotPasswordPage.path} element={<ForgotPasswordPage />} />
      <Route path={SetPasswordPage.path} element={<SetPasswordPage />} />
    </CustomRoutes>
    {(permissions) =>
      permissions === "admin" ? (
        <>
          <Resource
            name="lessons"
            list={LessonList}
            edit={LessonEdit}
            create={LessonCreate}
            icon={MenuBookIcon}
            recordRepresentation={(record: Lesson) => record.title}
          />
          {/* Lesson content is authored from the lesson edit tabs — no list
              keeps these resources out of the menu. */}
          <Resource
            name="lesson_exercises"
            edit={LessonExerciseEdit}
            create={LessonExerciseCreate}
            options={{ label: "Exercises" }}
          />
          <Resource
            name="lesson_exercise_options"
            edit={LessonExerciseOptionEdit}
            create={LessonExerciseOptionCreate}
            options={{ label: "Exercise Options" }}
          />
          <Resource
            name="lesson_grammar"
            edit={LessonGrammarEdit}
            create={LessonGrammarCreate}
            options={{ label: "Grammar" }}
          />
          <Resource
            name="lesson_keywords"
            edit={LessonKeywordEdit}
            create={LessonKeywordCreate}
            options={{ label: "Keywords" }}
          />
          <Resource
            name="user_favorites"
            list={UserFavoriteList}
            icon={FavoriteIcon}
            options={{ label: "Favorites" }}
          />
          <Resource
            name="user_learned_lessons"
            list={UserLearnedLessonList}
            icon={SchoolIcon}
            options={{ label: "Learned Lessons" }}
          />
          <Resource
            name="profiles"
            list={ProfileList}
            edit={ProfileEdit}
            icon={PeopleIcon}
            recordRepresentation={(record: Profile) =>
              record.username ?? record.id
            }
          />
          <Resource
            name="subscriptions"
            list={SubscriptionList}
            show={SubscriptionShow}
            icon={WorkspacePremiumIcon}
          />
        </>
      ) : (
        <CustomRoutes>
          <Route path="*" element={<AccessDenied />} />
        </CustomRoutes>
      )
    }
  </Admin>
);
