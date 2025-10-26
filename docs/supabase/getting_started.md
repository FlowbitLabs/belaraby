### Prerequisites

- [Install Docker](https://www.docker.com/)
- [Install Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started)

```
docker --version
supabase --version
```

### Quick Start

1. Login to Supabase
   Authenticate your CLI with your Supabase account:

```bash
supabase login
```

2. Link your project ID

```bash
supabase link
```

3. Start/Stop the local Supabase environment

```bash
supabase start
```

```bash
supabase stop
```

4. Open Supabase Studio

Once started, open: http://localhost:54323

That’s your local Supabase Studio — identical to the hosted one, but fully offline.
