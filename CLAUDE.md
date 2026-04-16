# GTM Pipeline Skills

This repo contains 10 Claude Code skills for B2B lead generation pipelines.

## Skill Namespacing

All skills use the `gtm-pipeline:` prefix. Invoke them with `/gtm-pipeline:<skill-name>`.

## How Skills Relate

Skills chain together — each outputs a CSV that becomes the next skill's input:

```
company-search
    → company-enrichment (+ ICP scoring)
        → signal-search
        → people-search
            → contact-filter
                → people-enrichment
                    → outreach
```

The `pipeline` skill orchestrates this sequence. The `demo` skill runs a condensed version for ~10 contacts.

## Per-Project Work

Each project lives in a `{slug}-gtm/` directory (created by the setup skill):
- `context/icp.md` — ICP definition (job tiers, industries, locations, size filter)
- `context/profile.md` — what the company sells, value prop, tone
- `csv/` — input, intermediate, and output CSVs

See `examples/sample-client-gtm/` for a fully filled-out reference.

## Shared Configuration

- `skills/_shared/conventions.md` — field naming, terminology, provider disambiguation
- `skills/_shared/phantombuster.md` — PB API patterns and agent config key reference
- `skills/_shared/local.md` — personal config (gitignored): PB agent IDs, GTM_ENV_PATH

## Field Naming Convention

All CSV outputs use `snake_case`. Provider-native names are mapped on ingestion.
See the Canonical Field Names table in `_shared/conventions.md`.

## New to this repo?

Run `/gtm-pipeline:setup` — it handles installation verification, API key configuration,
PhantomBuster agent lookup, and first client ICP setup.
