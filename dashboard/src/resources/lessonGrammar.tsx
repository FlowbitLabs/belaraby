import { Create, Edit, SimpleForm, TextInput, required } from "react-admin";
import {
  ChildEditToolbar,
  arabicInputSx,
  redirectToLessonEdit,
  rtlInputProps,
} from "./shared";

// No list view: grammar notes are authored from the parent lesson's
// "Grammar" tab (the resource is hidden from the menu). Admin CRUD is
// granted by RLS (migration 20260610120300). Saves redirect back to the
// parent lesson edit view; `lesson_id` arrives prefilled via the
// `?source={"lesson_id":...}` location search on create.

const grammarInputs = [
  <TextInput
    key="title"
    source="title"
    fullWidth
    validate={required()}
    inputProps={rtlInputProps}
    sx={arabicInputSx}
  />,
  <TextInput
    key="explanation"
    source="explanation"
    multiline
    minRows={6}
    fullWidth
    validate={required()}
    inputProps={rtlInputProps}
    sx={arabicInputSx}
  />,
  <TextInput
    key="example"
    source="example"
    multiline
    minRows={2}
    fullWidth
    inputProps={rtlInputProps}
    sx={arabicInputSx}
  />,
];

export const LessonGrammarEdit = () => (
  <Edit redirect={redirectToLessonEdit} title="Grammar Note">
    <SimpleForm
      toolbar={
        <ChildEditToolbar parentField="lesson_id" parentResource="lessons" />
      }
    >
      {grammarInputs}
    </SimpleForm>
  </Edit>
);

export const LessonGrammarCreate = () => (
  <Create redirect={redirectToLessonEdit} title="New Grammar Note">
    <SimpleForm>{grammarInputs}</SimpleForm>
  </Create>
);
