---
name: gtm-pipeline:demo
description: Generate a demo lead list of ~10 enriched contacts with personalized message examples. Use when a demo is requested, a webhook prompt describes a target audience, or someone asks to "create a demo for [client]". Enforces demo mode restrictions (email only, no phone, ~10 contacts). Chains people-search → people-enrichment → message generation.
---

# Demo

Generate a demo lead list of ~10 enriched contacts with personalized message examples, triggered by a webhook prompt.

**Read `~/.claude/skills/gtm-pipeline/_shared/conventions.md` before executing.**

---

## When to Use

- Webhook trigger: user submits a free demo form describing their target audience
- Goal: prove the AI agent writes authentic, non-generic outreach using real leads
- Scope: ~10 contacts, enriched with LinkedIn + email, 2–4 message examples

## Demo Restrictions

- **No phone enrichment** — email only
- **~10 contacts** (request 10–15, expect enrichment drop-off)
- Message generation is optional but recommended

---

## Step 1 — Parse the Prompt & Ask Discovery Questions

The webhook prompt describes the user's target audience. Before running anything, extract or ask for:

**Must have:**
- What do you sell / offer?
- Who is your ideal customer? (industry, role, company size, location)
- What's your value proposition?
- What tone? (formal vs. casual, examples if possible)
- Is this for recruiting OR selling to customers?

**If not in the prompt, infer or ask:**
- Target job titles
- Target location
- Target company size or type

Do NOT proceed to search until ICP is clear enough to build a meaningful filter.

**Save ICP to:** `{client-slug}-gtm/context/icp.md`

---

## Step 2 — Create Working Directory

Create the `{client-slug}-gtm/` directory structure as defined in `conventions.md`. Write the ICP definition to `context/icp.md`.

---

## Step 3 — People Search (10 contacts)

Use the **people-search** skill to find ~10–15 contacts.

**Provider selection for demo:**
- Prefer **BetterContact Lead Finder** or **FullEnrich Finder** — both return LinkedIn URLs directly, needed for email enrichment
- If no company list (persona-based prompt), use **Parallel FindAll** or **BC Search**

**Key fields to collect:**
```
full_name, first_name, last_name,
job_title, company_name, company_domain,
linkedin_profile_url, location
```

Follow the people-search execution protocol: sandbox → test → review → run.

---

## Step 4 — Contact Filter (ICP Ranking)

Run **contact-filter** on the 10–15 contacts found. Even small batches benefit from ICP ranking — it ensures the enrichment step focuses on the best-fit contacts.

- Applies job tier, industry tier, location tier, and company size classification
- Rejects hard non-ICP contacts
- Ranks passed contacts by priority
- Output: `csv/intermediate/contacts_filtered.csv`

For demos: use a relaxed hard-reject threshold (allow tiers 1–5 to pass), prioritize ranking over filtering.

---

## Step 5 — People Enrichment (Email Only)

Run **people-enrichment** on the filtered contacts. **Demo mode: email only, no phone.**

Recommended flow:
1. FullEnrich v2 (email) — all contacts
2. Pipe0 waterfall — for FE misses only

Additional enrichment for message personalization (if available):
- LinkedIn headline and summary (from LinkedIn scrape via PhantomBuster)
- Recent LinkedIn posts (2–3 per contact) — significantly improves message quality

**Minimum viable fields for message generation:**
```
name, job_title, company_name, linkedin_profile_url,
headline (optional), summary (optional), recent_posts (optional)
```

---

## Step 6 — Generate Message Examples

Generate **2–4 sample messages** before committing to the full batch.

### Message Structure

Every message must follow: **Hook → Bridge → Offer → Soft CTA**

| Part | Purpose | Length |
|------|---------|--------|
| Hook | Reference something specific to this person (post, career move, company signal) | 1 sentence |
| Bridge | Connect their situation to your offer | 1 sentence |
| Offer | What you provide, clearly stated | 1 sentence |
| CTA | Soft ask — not "let's schedule a call" | 1 sentence |

**Total: 320–450 characters.** No blank line after greeting. Paragraphs separated by single line break.

### Quality Rules

**Must have:**
- Specific hook (post reference OR career insight — not generic)
- Clear value proposition
- Natural, conversational tone
- Soft CTA

**Must avoid:**
- Repeating profile info they already know ("You work as X at Y")
- Generic observations ("impressive background", "I noticed you're in [industry]")
- Corporate jargon or buzzwords
- Pushy CTAs ("Let's schedule a call this week")

### Generation Process

1. Write a client-specific system prompt (save to `prompts/message_prompt.md`)
2. Generate 2–4 samples — include contacts with and without LinkedIn posts
3. Review against quality checklist above
4. If issues found, refine the system prompt and regenerate
5. **Only batch generate once quality is approved**

### System Prompt Template (key sections)

```
- Client context: what they sell, who they target, their value prop, tone
- Forbidden rules: no profile repetition, no generic flattery
- Message structure: hook → bridge → offer → CTA
- Hook examples: with posts / without posts
- Character limit: 320–450
```

---

## Step 7 — Output

Deliver:
1. **CSV** at `csv/output/contacts_enriched.csv`: lead data + generated messages
2. **Google Sheet** (optional): formatted for easy review

### Output CSV Columns

```
name, first_name, last_name, location, headline, summary,
linkedin_url, email, email_status,
company_name, job_title,
post_1_content, post_1_date,
post_2_content, post_2_date,
generated_message, char_count, has_posts
```

Messages saved separately to `csv/output/messages.csv`.

---

## Quality Checklist (Before Delivering)

- [ ] Messages feel personal, not templated
- [ ] No profile info repetition
- [ ] Clear value proposition in every message
- [ ] Proper formatting (line breaks, character count 320–450)
- [ ] Hook differs between contacts (no copy-paste structure)
- [ ] All data fields populated correctly
- [ ] Client-specific context incorporated

---

## Trigger Context

**Webhook (demo form):** Free demo trigger — user describes their ICP in a text prompt. Run this skill with ~10 contacts and 2–4 message samples.

**Stripe payment (full list):** After successful payment, run the full pipeline via the `pipeline` skill. See pipeline skill for orchestration.

---

## What's Missing (To Document)

- LinkedIn post scraping via PhantomBuster API (launch, poll, download)
- Automated webhook integration (currently manual trigger)
- Stripe payment trigger integration
