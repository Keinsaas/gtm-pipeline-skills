# GTM Pipeline — Architecture

## Two Workflows

### Company-First (Finite Markets)

Use when you have a company list, a known industry, or a Sales Navigator search.

```
┌─────────────────────────────────────────────────────────────────────┐
│                     COMPANY-FIRST WORKFLOW                          │
└─────────────────────────────────────────────────────────────────────┘

 ┌──────────────────┐
 │  company-search  │  Providers: Sales Navigator + PB, Parallel FindAll,
 │                  │  Firecrawl Agent, web scraping
 └────────┬─────────┘
          │ csv/input/companies_raw.csv
          ▼
 ┌──────────────────────┐
 │  company-enrichment  │  Phase 1: Enrich (PB SN Scraper, Parallel, SimilarWeb,
 │                      │  Firecrawl, SerpAPI)
 │                      │  Phase 2: ICP scoring → icp_score 0–100
 └────────┬─────────────┘
          │ csv/intermediate/companies_scored.csv
          │
          │  [optional gate: icp_score >= 70 to save credits downstream]
          │
          ├──────────────────────────────────┐
          ▼                                  ▼
 ┌─────────────────┐              ┌──────────────────┐
 │  signal-search  │              │  people-search   │
 │                 │  (parallel   │                  │
 │  4 sources:     │   or         │  company mode:   │
 │  - Parallel web │   sequential)│  find contacts   │
 │  - Firecrawl    │              │  at companies    │
 │  - Parallel     │              │                  │
 │    enrichment   │              │  persona mode:   │
 │  - PB Jobs      │              │  no company list │
 └────────┬────────┘              └────────┬─────────┘
          │ csv/intermediate/signals.csv   │ csv/intermediate/contacts_found.csv
          │ (used as outreach context)     │
          │                               ▼
          │                    ┌──────────────────┐
          │                    │  contact-filter  │  Rank by job tier, industry tier,
          │                    │                  │  location tier, company size,
          │                    │                  │  ICP keywords
          │                    └────────┬─────────┘
          │                             │ csv/intermediate/contacts_filtered.csv
          │                             ▼
          │                    ┌──────────────────────┐
          │                    │  people-enrichment   │  Email waterfall: FE → Pipe0
          │                    │                      │  Phone: BetterContact → FE
          │                    └────────┬─────────────┘
          │                             │ csv/output/contacts_enriched.csv
          │                             ▼
          └──────────────────► ┌─────────────────┐
                               │    outreach     │  LinkedIn connections + messages
                               │                 │  via PhantomBuster
                               └─────────────────┘
```

---

### Signal-First (Infinite Markets)

Use when you have no company list — discover companies based on buying behavior.

```
┌─────────────────────────────────────────────────────────────────────┐
│                     SIGNAL-FIRST WORKFLOW                           │
└─────────────────────────────────────────────────────────────────────┘

 ┌─────────────────────────────┐
 │  signal-search (discovery)  │  FindAll by signal criteria, Firecrawl Agent,
 │                             │  LinkedIn Job Exporter, Exa Websets (via Pipe0)
 └─────────────────┬───────────┘
                   │ csv/input/companies_raw.csv  (raw company names from signals)
                   ▼
          ┌──────────────────────┐
          │  company-enrichment  │  Enrich + ICP score discovered companies
          └────────┬─────────────┘
                   │ csv/intermediate/companies_scored.csv
                   │
                   │  [optional gate: icp_score >= 70]
                   ▼
          ┌──────────────────┐
          │  people-search   │
          └────────┬─────────┘
                   │
                   ▼
          ┌──────────────────┐
          │  contact-filter  │
          └────────┬─────────┘
                   │
                   ▼
          ┌──────────────────────┐
          │  people-enrichment   │
          └────────┬─────────────┘
                   │
                   ▼
          ┌─────────────────┐
          │    outreach     │
          └─────────────────┘
```

---

## CSV Handoffs

| Output File | Written By | Read By |
|-------------|-----------|---------|
| `csv/input/companies_raw.csv` | company-search | company-enrichment |
| `csv/intermediate/companies_enriched.csv` | company-enrichment Phase 1 | ICP scoring (Phase 2) |
| `csv/intermediate/companies_scored.csv` | company-enrichment Phase 2 | signal-search, people-search |
| `csv/intermediate/signals.csv` | signal-search | outreach (context) |
| `csv/intermediate/contacts_found.csv` | people-search | contact-filter |
| `csv/intermediate/contacts_filtered.csv` | contact-filter | people-enrichment |
| `csv/output/contacts_enriched.csv` | people-enrichment | outreach |

---

## Cost Checkpoints

The pipeline has natural checkpoints where credits are spent. Review output quality before continuing.

```
company-search          ← credits: Parallel FindAll or Pipe0 searches
        ↓
company-enrichment      ← credits: PB SN scrape (free w/ plan), or Parallel (~$0.025–0.05/row)
        ↓
[ICP gate icp_score ≥ 70]  ← saves downstream credits (signal-search, people-search)
        ↓
signal-search           ← credits: Parallel web search + enrichment, Firecrawl, OpenRouter
        ↓
people-search           ← credits: Pipe0, PB scrape, BC Lead Finder, FE Finder
        ↓
contact-filter          ← no API cost — local classification only
        ↓
people-enrichment       ← credits: FullEnrich (~$0.10–0.30/email), BetterContact (phone)
        ↓
outreach                ← LinkedIn plan quota (no API cost per message)
```

---

## Provider Summary

| Skill | Recommended Provider | Alternative |
|-------|---------------------|-------------|
| Company search | Parallel FindAll | Sales Nav + PB, Firecrawl Agent |
| Company enrichment | PB SN Account Scraper | Parallel enrichment |
| ICP scoring | Any LLM via OpenRouter | Claude directly |
| Signal web search | Parallel (processor: pro) | SerpAPI |
| Website crawl | Firecrawl | — |
| People search | Pipe0 | PB Employee Finder, BC Lead Finder, FE Finder |
| Email enrichment | FullEnrich | Pipe0 |
| Phone enrichment | BetterContact | FullEnrich |
| LinkedIn automation | PhantomBuster | — |

---

## Shared Files

All skills read from `~/.claude/skills/gtm-pipeline/_shared/`:

| File | Purpose |
|------|---------|
| `conventions.md` | Field names (snake_case), terminology, provider disambiguation |
| `phantombuster.md` | PB API patterns, agent config key reference, load_env helper |
| `local.md` | Personal config — PB agent IDs, GTM_ENV_PATH (gitignored) |
| `local.example.md` | Template to copy when setting up |
