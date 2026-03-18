import {
  List,
  Datagrid,
  TextField,
  DateField,
  Edit,
  SimpleForm,
  TextInput,
  SelectInput,
} from "react-admin";
import type { UserRole } from "../types";

const roleChoices: { id: UserRole; name: string }[] = [
  { id: "student", name: "Student" },
  { id: "teacher", name: "Teacher" },
  { id: "admin", name: "Admin" },
];

export const ProfileList = () => (
  <List sort={{ field: "created_at", order: "DESC" }}>
    <Datagrid rowClick="edit">
      <TextField source="username" />
      <TextField source="full_name" label="Full Name" />
      <TextField source="role" />
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
    </SimpleForm>
  </Edit>
);
