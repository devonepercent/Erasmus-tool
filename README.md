# EM Chance Checker

Free Erasmus Mundus chance checker for 1% Abroad. A student fills a short form (or uploads a CV), Claude scores the profile, the result is saved in Supabase, the report is emailed, and the page shows admission %, scholarship %, gaps and programmes.

```
em-chance-checker/
  README.md                 this file
  frontend/
    index.html              the live page
    config.js               ONE small file: your server address and two on/off switches
    prototype/index.html    the same design on sample data only (for showing and testing the look)
  backend/
    api/index.py            the server (Python)
    api/scoring_prompt.txt  the scoring rules in plain English. Edit this to "train" it.
    requirements.txt        packages the server needs
    supabase.sql            creates AND locks the leads table
    sample_payload.json     a test student you can paste into the test page
    .env.example            the settings list (never upload a filled in .env)
    vercel.json             tells Vercel how to run the server
  design/
    loading-page.html       the loading screen on its own
```

How it works: page -> server (`POST /api/chance`) -> Claude scores it -> saved in Supabase -> email sent -> result shown.

## Set it up, one step at a time

Do the steps in order. Every step ends with a check, so you always know it worked before you move on.

### Step 1. Supabase: create the table and lock it (5 min)
1. Supabase -> your project -> **SQL Editor** -> **New query**.
2. Paste all of `backend/supabase.sql` -> **Run**. You should see "Success".
3. **Important:** the last line of that file locks the table so nobody can read student details with the public website key. Do not skip it. If you ran an older version of the file, just run this one line now: `alter table leads enable row level security;`
4. **Check:** Table Editor -> `leads` exists, and it shows "RLS enabled".
5. Project Settings -> API: keep the **Project URL** and the **service_role** key for Step 5. The service_role key is a secret. Never put it in the page or in GitHub.

### Step 2. Anthropic key (2 min)
console.anthropic.com -> API Keys -> create a key and copy it. Make sure the account has credit.

### Step 3. Gmail App Password (5 min)
A normal Gmail password will not work for sending. Google Account -> Security -> turn on 2-Step Verification -> search "App passwords" -> create one named "EM checker" -> copy the 16 characters.

### Step 4. Put the project on GitHub (10 min)
GitHub's website cannot take a zip, so unzip first. Create a private repository, then drag everything inside the unzipped folder into the browser and click Commit. Never upload a filled in `.env`.

### Step 5. Put the server on Vercel (10 min)
1. vercel.com -> Add New -> Project -> import the repo.
2. **Root Directory: backend**. Framework Preset: Other.
3. Environment Variables: add `ANTHROPIC_API_KEY`, `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, `GMAIL_USER`, `GMAIL_APP_PASSWORD` (see `.env.example`). Optional: `FRONTEND_URL` (the page students open).
4. Deploy. You get an address like `https://your-server.vercel.app`.
5. **Check 1:** open `https://your-server.vercel.app/api/health`. All five settings should say `true`. Any `false` is a setting you forgot to add.
6. **Check 2 (tests each service):** open `https://your-server.vercel.app/api/health?deep=1`. You should see `"ok": true` and "ok" next to `supabase_leads_table`, `claude` and `gmail_login`. If one says "problem", the message tells you which key is wrong (see the table at the bottom).
7. **Check 3 (a real test student):** open `https://your-server.vercel.app/docs` -> `POST /api/chance` -> **Try it out** -> paste the contents of `backend/sample_payload.json` into `payload` (put your own email in it) -> **Execute**. You should get a result, a new row in Supabase, and an email.

### Step 6. Connect the page (10 min)
1. On GitHub open `frontend/config.js` -> pencil icon -> put the server address from Step 5 between the quotes (no slash at the end) -> Commit.
2. Vercel -> Add New -> Project -> import the same repo again -> **Root Directory: frontend** -> Deploy. This address is the page students open.
3. In the server project on Vercel, set `FRONTEND_URL` to that page address, then redeploy.
4. Set `ALLOWED_ORIGINS` on the server to the page address (for example `https://your-page.vercel.app`) so only your page can use the server.

### Step 7. Test like a student
Fill the form on your phone with a real email, with and without a CV. Check: the result appears, a row appears in Supabase, the email arrives. Try a wrong email on purpose: the form should return to the last step and show a clear message, not a fake result.

## What the live page hides on purpose
When `API_URL` is filled in, the page hides two things that are sample content only:
- the **leaderboard** (names on it are made up), and
- the **"Riya just checked her chances"** line.

Turn them on in `frontend/config.js` (`SHOW_LEADERBOARD:true`, `SHOW_LIVE_LINE:true`) only when they show real data. A leaderboard needs an opt-in tick box on the form first: until then no student is shown publicly.

## Changing the scoring
On GitHub open `backend/api/scoring_prompt.txt` -> pencil -> edit in plain English -> Commit. Vercel redeploys in about a minute.

## If something fails

| You see | What it means | Fix |
|---|---|---|
| `/api/health` shows a setting `false` | that setting is missing on Vercel | add it under Settings -> Environment Variables, then redeploy |
| `claude: problem (401)` | wrong Anthropic key | create a new key, paste it again |
| `claude: problem (404)` or "model" | model name not accepted | set `CLAUDE_MODEL` to a model your account can use |
| `claude: problem (400)` mentioning credit | no credit left | add credit in the Anthropic console |
| `supabase_leads_table: problem (404)` | table not created | run `supabase.sql` (Step 1) |
| `supabase_leads_table: problem (401)` | wrong service_role key | copy the **service_role** key, not the anon key |
| `gmail_login: problem` | wrong App Password or 2-Step Verification is off | make a new App Password (Step 3) |
| The page says "Something went wrong" | the page cannot reach the server | check `API_URL` in `config.js`, and `ALLOWED_ORIGINS` |
| "Too many checks from this connection" | the hourly limit protecting your Claude bill | wait, or raise `RATE_LIMIT_PER_HOUR` |

## Before running ads
- Test with at least 5 real students.
- Replace the sample review texts under Archana, Layan and Anjana (and the second sentence under Amaresh) with their real words.
- Check each programme's brand rules before using its logo in ads.
- The "Launch offer, this week only" label and the live fact line must be true on the day you show them.
- Real programme deadlines: Claude's dates can be wrong, so the page shows a deadline only when Claude gives one. For ads, keep a checked list of 2027 deadlines and use that instead.
- Vercel Pro plan for ad traffic (longer time limits and more headroom).
