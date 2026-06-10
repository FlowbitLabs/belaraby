// User profiles — one row per auth user, inserted by the signup trigger
// (migration 20260610120100). is_admin gates dashboard access via the
// public.is_admin() RLS policies, so flipping it here grants/revokes admin.
// Profiles cannot be created or deleted from the dashboard: rows follow the
// auth.users lifecycle (signup trigger / ON DELETE CASCADE).

import {
  BooleanField,
  BooleanInput,
  Datagrid,
  DateField,
  Edit,
  FunctionField,
  List,
  SelectInput,
  SimpleForm,
  TextField,
  TextInput,
} from "react-admin";
import type { Profile, UserRole } from "../types";
import { ListPagination, profileDisplayName } from "./shared";

const roleChoices: { id: UserRole; name: string }[] = [
  { id: "student", name: "Student" },
  { id: "teacher", name: "Teacher" },
  { id: "admin", name: "Admin" },
];

const profileFilters = [
  <TextInput
    key="username"
    source="username@ilike"
    label="Search username"
    alwaysOn
    resettable
  />,
  <TextInput
    key="full_name"
    source="full_name@ilike"
    label="Search full name"
    resettable
  />,
  <BooleanInput key="is_admin" source="is_admin" label="Admin" />,
];

export const ProfileList = () => (
  <List
    sort={{ field: "created_at", order: "DESC" }}
    filters={profileFilters}
    perPage={25}
    pagination={<ListPagination />}
  >
    <Datagrid rowClick="edit">
      <FunctionField<Profile>
        source="username"
        label="Username"
        render={profileDisplayName}
      />
      <TextField source="full_name" label="Full Name" />
      <TextField source="role" />
      <BooleanField source="is_admin" label="Admin" />
      <DateField source="created_at" showTime label="Joined" />
    </Datagrid>
  </List>
);

export const ProfileEdit = () => (
  <Edit>
    <SimpleForm>
      <TextInput source="username" />
      <TextInput source="full_name" label="Full Name" />
      <TextInput source="avatar_url" label="Avatar URL" fullWidth />
      <SelectInput source="role" choices={roleChoices} />
      {/* is_admin gates dashboard access via public.is_admin() RLS policies. */}
      <BooleanInput source="is_admin" label="Admin" />
    </SimpleForm>
  </Edit>
);
