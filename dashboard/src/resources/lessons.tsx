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
  required,
} from "react-admin";
import type { LessonLevel } from "../types";

const levelChoices: { id: LessonLevel; name: string }[] = [
  { id: "A1", name: "A1" },
  { id: "A2", name: "A2" },
  { id: "B1", name: "B1" },
  { id: "B2", name: "B2" },
  { id: "C1", name: "C1" },
  { id: "C2", name: "C2" },
];

export const LessonList = () => (
  <List sort={{ field: "created_at", order: "DESC" }}>
    <Datagrid rowClick="edit">
      <TextField source="title" />
      <TextField source="level" />
      <TextField source="grade" />
      <BooleanField source="paid" />
      <DateField source="date" />
      <DateField source="created_at" showTime label="Created" />
    </Datagrid>
  </List>
);

const LessonForm = () => (
  <SimpleForm>
    <TextInput source="title" fullWidth validate={required()} />
    <TextInput source="body" multiline rows={8} fullWidth validate={required()} />
    <TextInput source="hero_image" label="Hero Image URL" fullWidth />
    <SelectInput source="level" choices={levelChoices} validate={required()} />
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
