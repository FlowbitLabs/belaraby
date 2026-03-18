import {
  List,
  Datagrid,
  TextField,
  BooleanField,
  DateField,
  FunctionField,
  ChipField,
} from "react-admin";
import type { Subscription } from "../types";

export const SubscriptionList = () => (
  <List sort={{ field: "started_at", order: "DESC" }}>
    <Datagrid bulkActionButtons={false}>
      <FunctionField<Subscription>
        label="User"
        render={(record) => record.user_id.slice(0, 8) + "…"}
      />
      <ChipField source="status" />
      <TextField source="price_id" label="Plan" />
      <DateField source="started_at" label="Started" />
      <DateField source="current_period_end" label="Renews" />
      <BooleanField source="cancel_at_period_end" label="Canceling" />
    </Datagrid>
  </List>
);
