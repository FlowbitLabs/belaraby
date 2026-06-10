import { describe, expect, it } from "vitest";
import { hasActiveAccess, subscriptionStatusColor } from "./subscriptions";

describe("subscriptionStatusColor", () => {
  it.each([
    ["active", "success"],
    ["trialing", "success"],
    ["past_due", "warning"],
    ["billing_issue", "warning"],
    ["paused", "warning"],
    // RevenueCat and our webhook have used both spellings.
    ["canceled", "error"],
    ["cancelled", "error"],
    ["expired", "error"],
  ])("colors %s as %s", (status, color) => {
    expect(subscriptionStatusColor(status)).toBe(color);
  });

  it("falls back to neutral for statuses the webhook adds later", () => {
    expect(subscriptionStatusColor("some_future_status")).toBe("default");
    expect(subscriptionStatusColor("")).toBe("default");
  });
});

describe("hasActiveAccess", () => {
  it("denies access when expires_at is missing", () => {
    expect(hasActiveAccess({ expires_at: null })).toBe(false);
  });

  it("denies access once expires_at has passed", () => {
    expect(hasActiveAccess({ expires_at: "2000-01-01T00:00:00.000Z" })).toBe(
      false,
    );
  });

  it("grants access while expires_at is in the future, whatever the status", () => {
    const future = new Date(Date.now() + 60_000).toISOString();
    expect(hasActiveAccess({ expires_at: future })).toBe(true);
  });
});
