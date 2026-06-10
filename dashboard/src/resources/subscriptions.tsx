// RevenueCat subscriptions — READ-ONLY: rows are written exclusively by the
// `revenuecat-webhook` edge function (RevenueCat entitlement events), so the
// resource exposes no edit/create/delete. Premium access is gated solely by
// expires_at via public.has_active_subscription(); status and will_renew are
// informational — a cancellation keeps access until expiry.

import {
  BooleanField,
  Datagrid,
  DateField,
  FunctionField,
  List,
  SelectInput,
  Show,
  SimpleShowLayout,
  TextField,
} from "react-admin";
import { Chip } from "@mui/material";
import type { Subscription } from "../types";
import { ListPagination, UserFilterInput, UserReferenceField } from "./shared";

type ChipColor = "success" | "warning" | "error" | "default";

const STATUS_COLORS: Record<string, ChipColor> = {
  active: "success",
  trialing: "success",
  past_due: "warning",
  billing_issue: "warning",
  paused: "warning",
  canceled: "error",
  cancelled: "error",
  expired: "error",
};

/**
 * Chip color for a RevenueCat subscription status. Unknown statuses render
 * neutral rather than failing — RevenueCat may add event types.
 */
export const subscriptionStatusColor = (status: string): ChipColor =>
  STATUS_COLORS[status] ?? "default";

/**
 * Whether the subscription currently grants premium access. Mirrors
 * public.has_active_subscription(): expires_at > now() is the only criterion.
 * Status alone misleads support — a cancelled subscription keeps access
 * until it expires.
 */
export const hasActiveAccess = (
  record: Pick<Subscription, "expires_at">,
): boolean =>
  record.expires_at != null &&
  new Date(record.expires_at).getTime() > Date.now();

const renderStatusChip = (record: Subscription) => (
  <Chip
    size="small"
    label={record.status}
    color={subscriptionStatusColor(record.status)}
  />
);

const renderHasAccess = (record: Subscription) => (
  <Chip
    size="small"
    label={hasActiveAccess(record) ? "Yes" : "No"}
    color={hasActiveAccess(record) ? "success" : "default"}
  />
);

// Status values written by the revenuecat-webhook edge function.
const statusChoices = [
  "active",
  "cancelled",
  "expired",
  "billing_issue",
  "paused",
].map((status) => ({ id: status, name: status }));

// RevenueCat event values (event.store / event.environment).
const storeChoices = [
  "APP_STORE",
  "MAC_APP_STORE",
  "PLAY_STORE",
  "AMAZON",
  "STRIPE",
  "PROMOTIONAL",
].map((store) => ({ id: store, name: store }));

const environmentChoices = ["PRODUCTION", "SANDBOX"].map((environment) => ({
  id: environment,
  name: environment,
}));

const subscriptionFilters = [
  <SelectInput key="status" source="status" choices={statusChoices} alwaysOn />,
  <SelectInput key="store" source="store" choices={storeChoices} />,
  <SelectInput
    key="environment"
    source="environment"
    choices={environmentChoices}
  />,
  <UserFilterInput key="user_id" source="user_id" />,
];

export const SubscriptionList = () => (
  <List
    sort={{ field: "created_at", order: "DESC" }}
    filters={subscriptionFilters}
    perPage={25}
    pagination={<ListPagination />}
  >
    <Datagrid rowClick="show" bulkActionButtons={false}>
      <UserReferenceField source="user_id" label="User" />
      <FunctionField<Subscription>
        source="status"
        label="Status"
        render={renderStatusChip}
      />
      <FunctionField<Subscription>
        label="Has Access"
        sortBy="expires_at"
        render={renderHasAccess}
      />
      <TextField source="product_id" label="Product" />
      <TextField source="store" />
      <TextField source="environment" />
      <BooleanField source="will_renew" label="Will Renew" />
      <DateField source="expires_at" showTime label="Expires" />
    </Datagrid>
  </List>
);

export const SubscriptionShow = () => (
  <Show>
    <SimpleShowLayout>
      <UserReferenceField source="user_id" label="User" />
      <FunctionField<Subscription>
        source="status"
        label="Status"
        render={renderStatusChip}
      />
      <FunctionField<Subscription>
        label="Has Access"
        render={renderHasAccess}
      />
      <TextField source="entitlement_id" label="Entitlement" />
      <TextField source="product_id" label="Product" />
      <TextField source="store" />
      <TextField source="environment" />
      <BooleanField source="will_renew" label="Will Renew" />
      <TextField
        source="original_transaction_id"
        label="Original Transaction"
      />
      <DateField source="expires_at" showTime label="Expires" />
      <DateField source="created_at" showTime label="Created" />
      <DateField source="updated_at" showTime label="Updated" />
    </SimpleShowLayout>
  </Show>
);
