import { List, Datagrid, TextField, BooleanField, DateField } from "react-admin";

export const SubscriptionList = () => (
  <List>
    <Datagrid>
      <TextField source="user_id" />
      <TextField source="status" />
      <TextField source="price_id" />
      <DateField source="started_at" showTime />
      <DateField source="current_period_end" showTime />
      <BooleanField source="cancel_at_period_end" />
    </Datagrid>
  </List>
);
