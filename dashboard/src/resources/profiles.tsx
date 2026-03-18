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

const roleChoices = [
  { id: "student", name: "Student" },
  { id: "teacher", name: "Teacher" },
  { id: "admin", name: "Admin" },
];

export const ProfileList = () => (
  <List>
    <Datagrid rowClick="edit">
      <TextField source="id" />
      <TextField source="username" />
      <TextField source="full_name" />
      <TextField source="role" />
      <DateField source="created_at" showTime />
    </Datagrid>
  </List>
);

export const ProfileEdit = () => (
  <Edit>
    <SimpleForm>
      <TextInput source="username" />
      <TextInput source="full_name" />
      <TextInput source="avatar_url" fullWidth />
      <SelectInput source="role" choices={roleChoices} />
    </SimpleForm>
  </Edit>
);
