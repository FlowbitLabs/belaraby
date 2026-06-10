// Shared helpers for the edge-function unit tests.
//
// This file must not match Deno's test discovery glob (*_test.ts / *.test.ts)
// or it would be executed as an empty test module.

// Runs fn with the given env vars applied (null = unset) and restores the
// previous values afterwards, so tests can exercise misconfiguration branches
// without leaking state into other tests or the developer's shell.
export async function withEnv(
  vars: Record<string, string | null>,
  fn: () => Promise<void>,
): Promise<void> {
  const saved = new Map<string, string | undefined>();
  for (const [key, value] of Object.entries(vars)) {
    saved.set(key, Deno.env.get(key));
    if (value === null) {
      Deno.env.delete(key);
    } else {
      Deno.env.set(key, value);
    }
  }
  try {
    await fn();
  } finally {
    for (const [key, value] of saved) {
      if (value === undefined) {
        Deno.env.delete(key);
      } else {
        Deno.env.set(key, value);
      }
    }
  }
}
