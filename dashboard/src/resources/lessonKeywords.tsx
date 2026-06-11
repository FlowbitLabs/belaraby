import { Create, Edit, SimpleForm, TextInput, required } from "react-admin";
import {
  ChildEditToolbar,
  arabicInputSx,
  redirectToLessonEdit,
  rtlInputProps,
} from "./shared";

// No list view: keywords are authored from the parent lesson's "Keywords"
// tab (the resource is hidden from the menu). Admin CRUD is granted by RLS
// (migration 20260610120300). Saves redirect back to the parent lesson edit
// view; `lesson_id` arrives prefilled via the `?source={"lesson_id":...}`
// location search on create.

const keywordInputs = [
  <TextInput
    key="keyword"
    source="keyword"
    fullWidth
    validate={required()}
    inputProps={rtlInputProps}
    sx={arabicInputSx}
  />,
  <TextInput
    key="meaning"
    source="meaning"
    multiline
    minRows={2}
    fullWidth
    inputProps={rtlInputProps}
    sx={arabicInputSx}
  />,
];

export const LessonKeywordEdit = () => (
  <Edit redirect={redirectToLessonEdit} title="Keyword">
    <SimpleForm
      toolbar={
        <ChildEditToolbar parentField="lesson_id" parentResource="lessons" />
      }
    >
      {keywordInputs}
    </SimpleForm>
  </Edit>
);

export const LessonKeywordCreate = () => (
  <Create redirect={redirectToLessonEdit} title="New Keyword">
    <SimpleForm>{keywordInputs}</SimpleForm>
  </Create>
);
