// Lesson catalog — the core content resource. CAVEAT: public.lessons is a
// VIEW over private.lessons (migration 20260610150100) that masks `body` for
// non-subscribers; admin writes go through INSTEAD OF triggers. Child content
// (exercises / grammar / keywords) is fetched with ReferenceManyField /
// getManyReference — never PostgREST embedded selects across the view
// boundary (no meta.columns with lessons(*)).

import {
  BooleanField,
  BooleanInput,
  Create,
  Datagrid,
  DateField,
  DateInput,
  DeleteButton,
  Edit,
  ImageField,
  List,
  ReferenceManyCount,
  SaveButton,
  SelectInput,
  SimpleForm,
  TabbedForm,
  TextField,
  TextInput,
  Toolbar,
  required,
} from "react-admin";
import type { LessonLevel } from "../types";
import {
  ChildRecordsPanel,
  ListPagination,
  arabicInputSx,
  rtlInputProps,
} from "./shared";

const levelChoices: { id: LessonLevel; name: string }[] = [
  { id: "A1", name: "A1" },
  { id: "A2", name: "A2" },
  { id: "B1", name: "B1" },
  { id: "B2", name: "B2" },
  { id: "C1", name: "C1" },
  { id: "C2", name: "C2" },
];

const lessonFilters = [
  <TextInput
    key="title"
    source="title@ilike"
    label="Search title"
    alwaysOn
    resettable
  />,
  <SelectInput key="level" source="level" choices={levelChoices} />,
  <BooleanInput key="paid" source="paid" />,
];

export const LessonList = () => (
  <List
    sort={{ field: "created_at", order: "DESC" }}
    filters={lessonFilters}
    perPage={25}
    pagination={<ListPagination />}
  >
    <Datagrid rowClick="edit">
      <ImageField
        source="hero_image"
        label="Image"
        sortable={false}
        sx={{
          "& img": {
            maxWidth: 64,
            maxHeight: 40,
            objectFit: "cover",
            borderRadius: 1,
            margin: 0,
          },
        }}
      />
      <TextField source="title" />
      <TextField source="level" />
      <TextField source="grade" />
      <BooleanField source="paid" />
      <ReferenceManyCount
        label="Exercises"
        reference="lesson_exercises"
        target="lesson_id"
      />
      <ReferenceManyCount
        label="Keywords"
        reference="lesson_keywords"
        target="lesson_id"
      />
      <DateField source="date" />
      <DateField source="created_at" showTime label="Created" />
      <DeleteButton mutationMode="pessimistic" />
    </Datagrid>
  </List>
);

// Lesson title/body are Arabic: render the inputs RTL with a larger font.
const lessonInputs = [
  <TextInput
    key="title"
    source="title"
    fullWidth
    validate={required()}
    inputProps={rtlInputProps}
    sx={arabicInputSx}
  />,
  <TextInput
    key="body"
    source="body"
    multiline
    minRows={14}
    fullWidth
    validate={required()}
    inputProps={rtlInputProps}
    sx={arabicInputSx}
  />,
  <TextInput
    key="hero_image"
    source="hero_image"
    label="Hero Image URL"
    fullWidth
  />,
  <SelectInput
    key="level"
    source="level"
    choices={levelChoices}
    validate={required()}
  />,
  <TextInput key="grade" source="grade" />,
  <BooleanInput key="paid" source="paid" />,
  <DateInput key="date" source="date" />,
];

// Delete asks for confirmation (pessimistic) instead of the default undo.
const LessonEditToolbar = () => (
  <Toolbar sx={{ display: "flex", justifyContent: "space-between" }}>
    <SaveButton />
    <DeleteButton mutationMode="pessimistic" />
  </Toolbar>
);

export const LessonEdit = () => (
  <Edit>
    <TabbedForm toolbar={<LessonEditToolbar />}>
      <TabbedForm.Tab label="Lesson">
        <ImageField
          source="hero_image"
          label="Hero image preview"
          sx={{
            "& img": {
              maxWidth: 320,
              maxHeight: 180,
              objectFit: "cover",
              borderRadius: 1,
              margin: 0,
            },
          }}
        />
        {lessonInputs}
      </TabbedForm.Tab>
      <TabbedForm.Tab label="Exercises">
        <ChildRecordsPanel
          reference="lesson_exercises"
          target="lesson_id"
          addLabel="Add exercise"
        >
          <TextField source="question" />
          <ReferenceManyCount
            label="Options"
            reference="lesson_exercise_options"
            target="exercise_id"
          />
        </ChildRecordsPanel>
      </TabbedForm.Tab>
      <TabbedForm.Tab label="Grammar">
        <ChildRecordsPanel
          reference="lesson_grammar"
          target="lesson_id"
          addLabel="Add grammar note"
        >
          <TextField source="title" />
          <TextField source="explanation" />
        </ChildRecordsPanel>
      </TabbedForm.Tab>
      <TabbedForm.Tab label="Keywords">
        <ChildRecordsPanel
          reference="lesson_keywords"
          target="lesson_id"
          addLabel="Add keyword"
        >
          <TextField source="keyword" />
        </ChildRecordsPanel>
      </TabbedForm.Tab>
    </TabbedForm>
  </Edit>
);

export const LessonCreate = () => (
  <Create>
    <SimpleForm>{lessonInputs}</SimpleForm>
  </Create>
);
