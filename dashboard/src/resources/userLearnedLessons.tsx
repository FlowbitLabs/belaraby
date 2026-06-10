// Learned-lesson progress — READ-ONLY support view: rows are written by the
// Flutter app (RLS scopes writes to auth.uid()), so the dashboard exposes no
// mutations. CAVEAT: the table's primary key is compound (user_id, lesson_id)
// — see compoundPrimaryKeys in src/primaryKeys.ts; the `id` react-admin shows
// is synthesized by ra-supabase.

import {
  Datagrid,
  DateField,
  List,
  ReferenceField,
  TextField,
} from "react-admin";
import {
  LessonFilterInput,
  ListPagination,
  UserFilterInput,
  UserReferenceField,
} from "./shared";

const userLearnedLessonFilters = [
  <UserFilterInput key="user_id" source="user_id" />,
  <LessonFilterInput key="lesson_id" source="lesson_id" />,
];

export const UserLearnedLessonList = () => (
  <List
    sort={{ field: "learned_at", order: "DESC" }}
    filters={userLearnedLessonFilters}
    perPage={25}
    pagination={<ListPagination />}
  >
    <Datagrid rowClick={false} bulkActionButtons={false}>
      <UserReferenceField source="user_id" label="User" />
      <ReferenceField source="lesson_id" reference="lessons" label="Lesson">
        <TextField source="title" />
      </ReferenceField>
      <DateField source="learned_at" showTime label="Learned" />
    </Datagrid>
  </List>
);
