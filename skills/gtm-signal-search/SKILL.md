---
name: gtm-pipeline:signal-search
description: Find buying intent signals for target companies and score them for purchase intent. Four parallel sources: Parallel web search, Firecrawl website crawl, Parallel enrichment (structured), LinkedIn Job Exporter. Signal Assessment LLM scores 1-100. Runs standalone or in either pipeline workflow — does NOT require ICP scoring as input. Also triggers on "signal search", "find signals for", "buying intent".
---

# Signal Search

Find buying intent signals for target companies. Scores each signal for relevance and buying intent.

**Read `~/.claude/skills/gtm-pipeline/_shared/conventions.md` before executing.**

---

## When to Use

Standalone or within either pipeline workflow. **Does not require ICP scoring** — ICP score is just an upstream filter in the Company-First workflow, not a signal-search input.

- **Standalone:** Score signals on any company list (raw or pre-filtered)
- **Company-First workflow:** Run on ICP-scored companies (gate at `icp_score >= 70` to save credits)
- **Signal-First workflow:** Run as the discovery step — find companies based on signal criteria

The four critical components (in any of these contexts):
1. Parallel web search (recent news/announcements)
2. Firecrawl website crawl (on-site signals)
3. Parallel enrichment (structured signal fields)
4. Signal Assessment LLM prompt (scores 1–100)

## Inputs

| Input | Required | Source |
|-------|----------|--------|
| Company list CSV | Yes | Company list with at minimum `company_name`, `company_domain`, `company_website` |
| ICP / signal criteria | Yes (Signal-First mode) | User prompt or `context/icp.md` |
| Client offering description | Yes | For signal scoring customization |

### Optional Pre-filtering (Company-First mode)

To save credits when running on a large company list, gate by ICP score upstream:
- `icp_score >= 70`
- `website` not empty
- `type` in [Startup, Scaleup] (if available)

Skip this gate when running standalone or in Signal-First mode.

---

## Signal Types

| Signal | Example | Typical Intent |
|--------|---------|---------------|
| Funding / acquisitions | Series A, budget allocation for ops/tech | High |
| Leadership changes | New CXO, VP Ops, Head of Digital | High |
| Hiring signals | Job ads for ops/automation/AI/RevOps | High |
| Digital transformation | AI adoption, process automation, tech stack changes | High |
| Scaling challenges | Team expansion, manual process bottlenecks | Medium |
| Partnerships / launches | Product launches requiring operational scaling | Medium |

---

## Signal Sources (Four Parallel Channels)

Run these in parallel per company. **Ask the user which sources to enable.**

### Source 1: Parallel Web Search

**Node type:** Parallel web search (processor: `pro`, 15 results)

**Objective query (customize per client):**
```
Recent news, press releases, or announcements about {{ company }} ({{ website }}) from the past 4 months indicating:

- Funding rounds, acquisitions, or budget allocation for digital/operations/sales tech
- New leadership in operations, digital, IT, automation, or sales operations/enablement roles
- Team expansion, scaling challenges, or growth announcements
- Job ads for operations, AI, automation, sales ops, sales enablement, or RevOps roles
- Digital transformation, automation projects, or tech stack changes
- Operational challenges, process bottlenecks, or efficiency initiatives
- Sales process overhauls, CRM implementations, or sales tech investments
- Revenue growth targets, expansion into new markets, or aggressive scaling plans
- Outreach automation, lead generation challenges, or conversion rate issues
- SaaS costs, vendor consolidation, or tech spending optimization
- Partnerships or product launches requiring operational or GTM scaling

Focus on concrete business developments, not company descriptions. Prioritize signals relevant to operations, strategy, digital transformation, AI integration, sales/GTM/growth operations, or general decision-making (VPs, directors, executives).
```

**LLM extraction prompt (web search → structured signals):**
```
You are analyzing search results to extract relevant business developments and signals.

Extract content about recent company developments, avoiding generic descriptions or marketing material.

Include:
- Funding, acquisitions, budget announcements
- Leadership changes, new hires, team expansion
- Growth challenges, scaling initiatives
- Technology implementations, digital transformation projects
- Operational improvements, process changes
- Partnerships, product launches, strategic initiatives
- Executive statements about company direction or challenges

Exclude:
- Generic company descriptions, mission statements, product features
- Standard career pages or "about us" content
- Individual LinkedIn profile summaries
- Content that's purely promotional or marketing-focused

Extract the relevant content as written, preserving details, numbers, quotes, and context. Keep enough to understand what's happening and why it matters. For each signal, add a brief relevance note and include the date if available. Return output in English only.
```

**Output schema:**
```json
{
  "signals": [
    {
      "content": "Full signal text with details, numbers, quotes",
      "relevance": "Why this matters for the offering",
      "source": "https://...",
      "date": "2025-08-05"
    }
  ]
}
```

---

### Source 2: Firecrawl Website Crawl

**Request:**
```json
{
  "url": "{{ website }}",
  "sitemap": "include",
  "crawlEntireDomain": false,
  "limit": 15,
  "allowSubdomains": true,
  "excludePaths": [
    "privacy/*", "data/*", "impressum/*", "legal/*", "terms/*",
    "agb/*", "datenschutz/*", "dsgvo/*", "gdpr/*", "cookie*",
    "contact/*", "kontakt/*", "faq/*", "support/*",
    "login/*", "signup/*", "register/*", "checkout/*", "cart/*", "shop/*"
  ],
  "prompt": "AI/automation investment signals from past 4 months: funding rounds, acquisitions, launches, challenges, job postings for operations/tech/ai/gtm roles, new executives, expansion/growth plans, technology/ai initiatives. Can be pages containing news, blog, career, press, investors etc.",
  "scrapeOptions": {
    "formats": ["markdown"],
    "onlyMainContent": true,
    "excludeTags": ["img", "picture", "footer", "nav", "header", "aside"]
  }
}
```

**LLM extraction prompt (crawled markdown → signals):**
```
Extract content indicating potential need for automation, AI implementation, or workflow optimization.

Look for:
- Team growth, new hires in operations/digital/tech roles
- Scaling challenges, process bottlenecks, efficiency goals
- Digital transformation initiatives or tech adoption plans
- Manual processes, workflow pain points, operational inefficiencies
- SaaS costs, subscription management, vendor consolidation efforts
- Product launches, new services requiring operational support
- Compliance requirements, data handling challenges
- Customer service scaling, lead management issues
- Content production workflows, marketing automation gaps
- Recent company milestones indicating growth phase

Do not extract:
- Generic company descriptions or evergreen content
- Old news (older than 4 months)
- Vague statements without specific facts: "we are hiring", "we are growing" only if backed by a fact/figure

For each finding: extracted snippet + source URL. If no signals found, return:
{"websiteSignals": [{"snippet": "No website signals found", "ogUrl": ""}]}
Return all results in English only.
```

**Output schema:**
```json
{
  "signals": [
    {
      "snippet": "Relevant text excerpt",
      "ogUrl": "https://..."
    }
  ]
}
```

---

### Source 3: Parallel Enrichment (Structured Signal Data)

Use when you need structured, non-standard fields as signal inputs — funding stage, hiring signals with job URLs, tech stack indicators, digital initiatives.

**Node type:** Parallel task enrichment, processor: `core`
**Disabled by default** — enable when structured signal fields are needed.

**Input per company:**
```json
{
  "company_name": "{{ name }}",
  "website_url": "{{ website }}",
  "domain": "{{ domain }}",
  "linkedin_url": "{{ linkedInCompanyUrl }}",
  "location": "{{ location }}",
  "description": "{{ description }}"
}
```

**Output schema (customize — add/remove fields per client):**
```json
{
  "recent_funding_round": "Series A / Seed / Grant / IPO or null",
  "recent_funding_amount": "Amount in USD or null",
  "funding_stage": "bootstrapped | seed | series_a | series_b_plus | private_equity | public",
  "hiring_signals": [
    {
      "job_title": "Operations Manager",
      "job_url": "https://...",
      "posted_at": "2025-08-01"
    }
  ],
  "digital_initiatives": [
    {
      "title": "CRM migration announced",
      "description": "...",
      "source_url": "https://...",
      "date": "2025-07-15"
    }
  ],
  "tech_stack_indicators": ["Salesforce", "Zapier", "HubSpot"]
}
```

Output feeds into Signal Assessment scoring as `parallelEnrichment.output`.

**Always ask which processor to use** before running Parallel tasks.

---

### Source 4: LinkedIn Job Exporter (PhantomBuster)

Scrape job postings matching criteria (operations, AI, automation, RevOps, etc.).

**Phantom Script:** LinkedIn Search Export (jobs mode) — config key `PB_AGENT_JOB_SEARCH` in `_shared/local.md`
**Input:** Search URLs defined per geography/role (e.g. in a Google Sheet or CSV)

```
Auth: X-Phantombuster-Key-1: <key>
Launch:  POST /api/v2/agents/launch
Poll:    GET /api/v2/agents/fetch?id=<agent_id>
Result:  GET /api/v2/containers/fetch-result-object
```

Output: job titles, posting dates, company names — used as hiring intent signals.

---

## Signal Assessment (Scoring)

All signals from the four sources merge → LLM agent scores each signal 1–100.

**LLM:** OpenRouter — **ask user which model** (default suggestion: `moonshotai/kimi-k2-thinking` as used in existing n8n flow)

### System Message

```
You are a B2B sales intelligence analyst evaluating buying intent signals. Your job is to assess how likely a company is to purchase based on recent developments.

Analyze each signal and assign a buying intent score from 1-100:

High Intent (70-100):
- Recent funding with budget allocated to operations/tech/digital
- Explicit pain points matching the solution
- New leadership in relevant roles (operations, digital, IT)
- Active transformation projects or stated automation goals
- Urgent timelines or immediate needs mentioned

Medium Intent (40-69):
- Team expansion indicating growing operational complexity
- Technology adoption or integration initiatives
- Partnership/acquisition requiring process consolidation
- General statements about efficiency or productivity goals
- Industry pressures requiring operational changes

Low Intent (1-39):
- Generic hiring (every company says they are hiring on career pages)
- Generic growth announcements without operational context
- Developments not clearly related to operational needs
- Vague or aspirational statements without concrete plans
- Signals from >6 months ago
- No clear connection to decision-making or budget
- ATTENTION: If the website or search signal data is specifically about a company with the same name but mentions a different website, than the website/domain we are assessing the signal for, DO NOT consider that signal in the assessment

Cut through the buzz. Every company depicts itself as growing on their website. Identify signs of specific needs or real pains. Inconclusive statements with buzzwords are not enough.

Consider the contact person's role when available — signals more relevant to their domain score higher.

For EACH signal, first verify it refers to the same company as {{ domain }}. If the signal mentions a different website or domain, set domain_verified: false for that signal.
```

### User Prompt (customize offering section per client)

```
## Company Profile
Company: {{ name }}
Website: {{ website }}
Domain: {{ domain }}

ATTENTION: If the website or search signal data is about a company with the same name but mentions a different website, or otherwise suggests that it's a different company than {{ website }}, DO NOT consider that signal in the assessment. Set domain_verified: false for such signals — they will be automatically scored 0.

## Our Offering
[CUSTOMIZE — Replace with your value proposition. Example below.]

Example:
> We provide a [product category] for [target buyer]. We help companies that
> are dealing with [primary pain point] by [the mechanism / approach].
>
> We specialize in:
> - [capability 1]
> - [capability 2]
> - [capability 3]
>
> Target: [geography] companies in [industries] with [signals of fit].

[END CUSTOMIZE]

## Signals to Evaluate

### 1. Website Signals
{{ websiteSignals }}

### 2. Web Search Signals
{{ searchSignals }}

### 3. Parallel Enrichment Data
{{ parallelEnrichment.output }}

## Task
Evaluate each signal's buying intent for our offering. Return scored signals with reasoning.
```

### Output Schema

```json
{
  "overallScore": 75,
  "signalCount": 3,
  "scoredSignals": [
    {
      "summary": "One sentence description of the signal",
      "score": 82,
      "domain_verified": true,
      "reasoning": "Why this score — specific connection to offering",
      "keyInsight": "Actionable takeaway for outreach hook"
    }
  ],
  "overallSummary": "Overall assessment. Contact if in [role]. Best hook: [signal]."
}
```

---

## Execution Protocol

### 1. Select Sources
Present the four sources to the user. Get approval on which to enable:
- Source 1 (Parallel web search): recommended for all
- Source 2 (Firecrawl crawl): recommended for all
- Source 3 (Parallel enrichment): optional, enable for structured data needs
- Source 4 (LinkedIn Jobs): optional, enable when hiring signals are key

### 2. Customize Prompts
- Swap offering section in Signal Assessment user prompt
- Adjust web search objective for client-specific signals
- Adjust Firecrawl crawl prompt if needed

### 3. Test (3–5 companies)
- Run enabled sources on 3–5 companies
- Review raw signals and scored output
- Check: are signals relevant? Is scoring calibrated? Are scores too high/low?

### 4. Review with User
- Present test company results with scored signals
- Get approval on scoring quality and source selection

### 5. Full Run
- Process remaining companies
- Save results incrementally
- Log each batch to run_log.md

---

## Output

CSV at `csv/intermediate/signals.csv` with columns:
```
company_name, company_domain,
overallScore, signalCount, scoredSignals, overallSummary,
crawledContent, webSearch,
recent_funding_round, recent_funding_amount, funding_stage,
hiring_signals, digital_initiatives, tech_stack_indicators
```

All original company columns preserved.

---

## What's Missing (To Document)

- PhantomBuster LinkedIn Jobs Scraper: full launch/poll/download API flow
- Firecrawl Agent (`POST /v2/agent`) for Workflow 2 signal-first discovery
- Exa Websets via Pipe0 for signal-based company discovery
- n8n workflow API for creating client-specific copies of the signal flow
