-- Out-of-order webhook protection for the RevenueCat integration.
--
-- RevenueCat webhook delivery is at-least-once and unordered: a retried
-- CANCELLATION can arrive after the RENEWAL that superseded it. The
-- revenuecat-webhook edge function records each applied event's
-- event_timestamp_ms here and skips any incoming event that is older than
-- the last one applied to the same (user_id, entitlement_id) row.
--
-- Rollback:
--   ALTER TABLE public.subscriptions DROP COLUMN IF EXISTS last_event_timestamp_ms;

ALTER TABLE public.subscriptions
    ADD COLUMN IF NOT EXISTS last_event_timestamp_ms bigint;

COMMENT ON COLUMN public.subscriptions.last_event_timestamp_ms IS
    'event_timestamp_ms of the last RevenueCat webhook event applied to this row; used to reject stale/out-of-order deliveries.';
