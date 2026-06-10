import {
  BooleanInput,
  Create,
  Edit,
  SimpleForm,
  TextInput,
  required,
} from "react-admin";
import {
  ChildEditToolbar,
  arabicInputSx,
  redirectToExerciseEdit,
  rtlInputProps,
} from "./shared";

// No list view: options are authored from the parent exercise's edit view
// (the resource is hidden from the menu). Admin CRUD is granted by RLS
// (migration 20260610120300). Saves redirect back to the parent exercise;
// `exercise_id` arrives prefilled via the `?source={"exercise_id":...}`
// location search on create.

const optionInputs = [
  <TextInput
    key="option_text"
    source="option_text"
    label="Option"
    fullWidth
    validate={required()}
    inputProps={rtlInputProps}
    sx={arabicInputSx}
  />,
  <BooleanInput key="is_correct" source="is_correct" label="Correct answer" />,
];

export const LessonExerciseOptionEdit = () => (
  <Edit redirect={redirectToExerciseEdit} title="Exercise Option">
    <SimpleForm
      toolbar={
        <ChildEditToolbar
          parentField="exercise_id"
          parentResource="lesson_exercises"
        />
      }
    >
      {optionInputs}
    </SimpleForm>
  </Edit>
);

export const LessonExerciseOptionCreate = () => (
  <Create redirect={redirectToExerciseEdit} title="New Exercise Option">
    <SimpleForm>{optionInputs}</SimpleForm>
  </Create>
);
