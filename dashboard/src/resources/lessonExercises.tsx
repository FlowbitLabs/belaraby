import {
  BooleanField,
  Create,
  Edit,
  SimpleForm,
  TextField,
  TextInput,
  required,
} from "react-admin";
import {
  ChildEditToolbar,
  ChildRecordsPanel,
  arabicInputSx,
  redirectToLessonEdit,
  rtlInputProps,
} from "./shared";

// No list view: exercises are authored from the parent lesson's
// "Exercises" tab (the resource is hidden from the menu). Admin CRUD is
// granted by RLS (migration 20260610120300). Saves redirect back to the
// parent lesson edit view; `lesson_id` arrives prefilled via the
// `?source={"lesson_id":...}` location search on create.

const exerciseInputs = [
  <TextInput
    key="question"
    source="question"
    multiline
    fullWidth
    validate={required()}
    inputProps={rtlInputProps}
    sx={arabicInputSx}
  />,
];

export const LessonExerciseEdit = () => (
  <Edit redirect={redirectToLessonEdit} title="Exercise">
    <SimpleForm
      toolbar={
        <ChildEditToolbar parentField="lesson_id" parentResource="lessons" />
      }
    >
      {exerciseInputs}
      <ChildRecordsPanel
        reference="lesson_exercise_options"
        target="exercise_id"
        label="Options"
        addLabel="Add option"
      >
        <TextField source="option_text" label="Option" />
        <BooleanField source="is_correct" label="Correct" />
      </ChildRecordsPanel>
    </SimpleForm>
  </Edit>
);

export const LessonExerciseCreate = () => (
  <Create redirect={redirectToLessonEdit} title="New Exercise">
    <SimpleForm>{exerciseInputs}</SimpleForm>
  </Create>
);
