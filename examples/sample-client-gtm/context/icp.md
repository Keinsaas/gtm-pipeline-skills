# Flowline — ICP Definition

> This is a fictional example company. Use it as a reference for how to structure your own `context/icp.md`.

---

## Company ICP

### Target Industry
B2B services, wholesale/distribution, manufacturing, consulting, and mid-market SaaS with established sales teams.

### Company Size
- Min employees: 30
- Max employees: 600

### Location
DACH (primary), Benelux + Nordics (secondary), UK + Ireland (secondary), US/CA (tertiary).

### Revenue Range
€3M–€50M ARR for SaaS; revenue-equivalent for services firms.

### Exclusions
Consumer, healthcare, pharma, legal, government, early-stage pre-revenue, pure dev tools.

---

## Contact ICP

### Target Job Titles / Roles
Operations, Revenue Operations, Sales Operations, GTM Operations.

### Seniority
Manager, Senior, Lead, Head of, Director. C-level only at companies < 80 employees.

---

## Contact Filter Configuration

### Job Tier Definitions

- **Tier 1** (Primary — operations ownership, mid-seniority): keywords = [revops, revenue operations, sales ops, sales operations, gtm ops, operations manager, ops lead], seniority = [manager, senior, lead, specialist]
- **Tier 2** (Primary — operations ownership, other seniority): keywords = [revops, revenue operations, sales ops, gtm ops], seniority = [head of, director, IC, analyst]
- **Tier 3** (Leadership — sales/revenue domain): keywords = [sales, revenue, commercial, business development, go to market], seniority = [VP, director, head of]
- **Tier 4** (Domain — adjacent roles): keywords = [account executive, account manager, inside sales, business development rep, SDR], seniority = any
- **Tier 5** (C-level): keywords = [CRO, CSO, COO, chief revenue, chief sales, chief operating], seniority = C-level
- **Tier 6 — Reject**: keywords = [student, intern, junior, coordinator, assistant, marketing analyst, recruiter, HR]

**C-level promotion rule:** If `company_employee_count < 80`, promote C-level from tier 5 → tier 3.
**Hard reject threshold:** tier >= 6 (tier 6 = reject, missing title = tier 6 = reject by default).

### Industry Tiers

- **Tier 1** (Best fit): B2B services, management consulting, staffing & recruiting, wholesale, distribution, manufacturing, logistics
- **Tier 2** (Good fit): SaaS, software (with established sales team signal), IT services, marketing agencies
- **Tier 3** (Neutral): Retail with B2B arm, media, real estate
- **Tier 4** (Low fit): Deeptech, aerospace, biotech, non-profit
- **Tier 5** (Hard): Healthcare, pharma, finance, legal, government, consumer

### Location Tiers

- **Tier A**: DE, AT, CH, NL, BE, LU
- **Tier B**: DK, SE, NO, FI, GB, IE
- **Tier C**: FR, ES, IT, PL, CZ, HU, PT
- **Tier D**: US, CA, AU, NZ, and all others

**Hard reject threshold:** none — all tiers pass, used for sorting only.

### Company Size Filter
- Min: 30 employees
- Max: 600 employees
- Outside range AND field present: reject

### ICP Keywords (company specialities)
keywords = [workflow automation, process automation, crm, sales enablement, revops, revenue operations, salestech, operations, no-code, integration]

### Sort Order
job_tier → industry_tier → comp_loc_tier → person_loc_tier → employee_count_missing (penalty) → icp_kw_score (desc) → follower_count (desc)

---

## Signal Search Configuration

### Our Offering (for Signal Assessment prompt)

> We provide a no-code workflow automation platform for operations and revenue teams.
> We help B2B companies that are dealing with manual handoffs, disconnected tools, and
> slow approval processes by automating their internal workflows without engineering resources.
>
> We specialize in:
> - CRM and ERP data sync automation
> - Lead routing and approval workflow automation
> - Cross-tool handoff elimination (Salesforce, HubSpot, SAP, Jira, Slack)
>
> Target: DACH-first, then Benelux/Nordics/UK. B2B companies with 30–600 employees
> in operations-heavy industries or scaling SaaS with revenue teams.

### High-Intent Signals
- New Head of RevOps, Sales Ops, or Operations hired
- Recent funding (Series A–C) with stated intent to scale operations/GTM
- Active job postings for RevOps, Ops Manager, Sales Ops roles
- CRM migration or tool stack consolidation announced
- Manual process complaints in press/blog/job ads

### Web Search Objective (last 4 months)
Focus on: funding, new ops/sales leadership, scaling announcements, digital transformation, CRM/tool changes, hiring signals in operations roles.

---

## ICP Scoring Prompt Context

Score each company on a scale of 0–100 based on fit with the following ICP:

**Ideal:** DACH-based B2B company, 50–300 employees, in services/distribution/SaaS, with an established revenue team and signs of operational scaling. Growing headcount in sales + ops roles. No mention of in-house engineering-heavy workflows.

**Positive signals:** RevOps hire, CRM in their stack (Salesforce, HubSpot), funding announcement, operations job postings, B2B business model with complex pipeline.

**Negative signals:** Consumer-facing, < 30 employees (too small), > 600 employees (too complex), healthcare/finance/gov compliance context.
