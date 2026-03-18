import {
  List,
  Datagrid,
  TextField,
  BooleanField,
  DateField,
  Edit,
  SimpleForm,
  TextInput,
  BooleanInput,
  SelectInput,
  Create,
  DateInput,
} from "react-admin";

const levelChoices = [
  { id: "A1", name: "A1" },
  { id: "A2", name: "A2" },
  { id: "B1", name: "B1" },
  { id: "B2", name: "B2" },
  { id: "C1", name: "C1" },
  { id: "C2", name: "C2" },
];

export const LessonList = () => (
  <List>
    <Datagrid rowClick="edit">
      <TextField source="title" />
      <TextField source="level" />
      <TextField source="grade" />
      <BooleanField source="paid" />
      <DateField source="date" />
      <DateField source="created_at" showTime />
    </Datagrid>
  </List>
);

const LessonForm = () => (
  <SimpleForm>
    <TextInput source="title" fullWidth required />
    <TextInput source="body" multiline rows={8} fullWidth required />
    <TextInput source="hero_image" fullWidth />
    <SelectInput source="level" choices={levelChoices} required />
    <TextInput source="grade" />
    <BooleanInput source="paid" />
    <DateInput source="date" />
  </SimpleForm>
);

export const LessonEdit = () => (
  <Edit>
    <LessonForm />
  </Edit>
);

export const LessonCreate = () => (
  <Create>
    <LessonForm />
  </Create>
);
