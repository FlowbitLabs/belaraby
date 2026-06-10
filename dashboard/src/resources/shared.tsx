// Building blocks shared across resource files. Anything here is used by at
// least two resources — one-off components belong next to their resource.

import type { ReactNode } from "react";
import {
  AutocompleteInput,
  CreateButton,
  Datagrid,
  DeleteButton,
  FunctionField,
  Pagination,
  ReferenceField,
  ReferenceInput,
  ReferenceManyField,
  SaveButton,
  Toolbar,
  useRecordContext,
} from "react-admin";
import type { Identifier, RaRecord } from "react-admin";
import type { Profile } from "../types";

/** Pagination with the dashboard-wide page-size options, for every List. */
export const ListPagination = () => (
  <Pagination rowsPerPageOptions={[10, 25, 50, 100]} />
);

/**
 * Arabic authoring helpers: lesson content is written in Arabic, so the
 * inputs render right-to-left with a larger, more readable font size.
 */
export const rtlInputProps = { dir: "rtl" } as const;

export const arabicInputSx = {
  "& .MuiInputBase-input": {
    fontSize: "1.2rem",
    lineHeight: 1.9,
  },
} as const;

/**
 * Redirect a lesson child save (exercise / grammar / keyword) back to the
 * parent lesson's edit view.
 */
export const redirectToLessonEdit = (
  _resource?: string,
  _id?: Identifier,
  data?: Partial<RaRecord>,
): string => (data?.lesson_id ? `/lessons/${data.lesson_id}` : "/lessons");

/**
 * Redirect an exercise option save back to the parent exercise's edit view.
 */
export const redirectToExerciseEdit = (
  _resource?: string,
  _id?: Identifier,
  data?: Partial<RaRecord>,
): string =>
  data?.exercise_id ? `/lesson_exercises/${data.exercise_id}` : "/lessons";

interface AddChildRecordButtonProps {
  /** Child resource to create, e.g. "lesson_exercises". */
  resource: string;
  /** FK column on the child pointing at the current record, e.g. "lesson_id". */
  parentField: string;
  label: string;
}

/**
 * CreateButton for a child resource, prefilled with the current record's id
 * via the `?source={...}` location search react-admin reads on Create pages.
 */
export const AddChildRecordButton = ({
  resource,
  parentField,
  label,
}: AddChildRecordButtonProps) => {
  const record = useRecordContext();
  if (!record) {
    return null;
  }
  return (
    <CreateButton
      resource={resource}
      label={label}
      to={{
        pathname: `/${resource}/create`,
        search: `?source=${encodeURIComponent(
          JSON.stringify({ [parentField]: record.id }),
        )}`,
      }}
    />
  );
};

interface ChildEditToolbarProps {
  /** FK column on the edited record pointing at its parent. */
  parentField: string;
  /** Parent resource whose edit view we return to after delete. */
  parentResource: string;
}

/**
 * Save + pessimistic delete toolbar for lesson child resources. Delete
 * redirects back to the parent record's edit view.
 */
export const ChildEditToolbar = ({
  parentField,
  parentResource,
}: ChildEditToolbarProps) => {
  const record = useRecordContext();
  const parentId = record?.[parentField] as Identifier | undefined;
  return (
    <Toolbar sx={{ display: "flex", justifyContent: "space-between" }}>
      <SaveButton />
      <DeleteButton
        mutationMode="pessimistic"
        redirect={parentId ? `/${parentResource}/${parentId}` : "list"}
      />
    </Toolbar>
  );
};

interface ChildRecordsPanelProps {
  /** Child resource to list and create, e.g. "lesson_exercises". */
  reference: string;
  /** FK column on the child pointing at the current record, e.g. "lesson_id". */
  target: string;
  /** Label for the prefilled create button. */
  addLabel: string;
  /** Optional ReferenceManyField label; hidden by default (tab usage). */
  label?: string | false;
  /** Datagrid columns. */
  children: ReactNode;
}

/**
 * Child-records datagrid + prefilled create button for a parent edit view.
 * Fetches via getManyReference, never a PostgREST embedded select — embeds
 * cannot cross the lessons view boundary (public.lessons is a VIEW, see
 * migration 20260610150100).
 */
export const ChildRecordsPanel = ({
  reference,
  target,
  addLabel,
  label = false,
  children,
}: ChildRecordsPanelProps) => (
  <>
    <ReferenceManyField
      reference={reference}
      target={target}
      label={label}
      pagination={<Pagination />}
    >
      <Datagrid rowClick="edit" bulkActionButtons={false}>
        {children}
      </Datagrid>
    </ReferenceManyField>
    <AddChildRecordButton
      resource={reference}
      parentField={target}
      label={addLabel}
    />
  </>
);

/**
 * Display name for a profile that stays identifiable for anonymous
 * sign-ups: the signup trigger inserts only `id`, so `username` is NULL —
 * fall back to the id instead of rendering a blank cell.
 */
export const profileDisplayName = (
  profile: Pick<Profile, "id" | "username">,
): string => profile.username ?? profile.id;

interface UserReferenceFieldProps {
  source?: string;
  label?: string;
}

/** ReferenceField to profiles, rendered with the anonymous-safe name. */
export const UserReferenceField = ({
  source = "user_id",
  label = "User",
}: UserReferenceFieldProps) => (
  <ReferenceField source={source} reference="profiles" label={label}>
    <FunctionField<Profile> render={profileDisplayName} />
  </ReferenceField>
);

interface ReferenceFilterInputProps {
  /** FK column on the filtered resource. Read by react-admin's FilterForm. */
  source: string;
  label?: string;
  alwaysOn?: boolean;
}

/**
 * List filter: pick a user by typing their username.
 * `source` must be passed on the element itself — react-admin's filter
 * machinery reads it from the element props, not from inside the component.
 */
export const UserFilterInput = ({
  source,
  label = "User",
  alwaysOn,
}: ReferenceFilterInputProps) => (
  <ReferenceInput source={source} reference="profiles" alwaysOn={alwaysOn}>
    <AutocompleteInput
      label={label}
      filterToQuery={(searchText: string) => ({
        "username@ilike": searchText,
      })}
    />
  </ReferenceInput>
);

/** List filter: pick a lesson by typing its title. Same caveat as above. */
export const LessonFilterInput = ({
  source,
  label = "Lesson",
  alwaysOn,
}: ReferenceFilterInputProps) => (
  <ReferenceInput source={source} reference="lessons" alwaysOn={alwaysOn}>
    <AutocompleteInput
      label={label}
      filterToQuery={(searchText: string) => ({ "title@ilike": searchText })}
    />
  </ReferenceInput>
);
