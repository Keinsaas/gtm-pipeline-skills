# Contributing

Thanks for your interest in improving the GTM pipeline skills. This guide covers how to contribute.

---

## How to Contribute

1. **Fork** the repo
2. **Create a branch** from `main` for your change
3. **Make your changes** — follow the conventions below
4. **Test** with `./install.sh` and invoke the skill you modified
5. **Submit a PR** to `main`

PRs are reviewed before merging. The `stable` branch is the maintainer's production copy — don't target it.

---

## What You Can Contribute

- **Skill improvements:** Better instructions, clearer steps, edge case handling
- **New provider support:** Add a data provider to an existing skill's provider table
- **Bug fixes:** Incorrect field names, broken references, missing steps
- **Documentation:** Architecture docs, examples, README improvements
- **New skills:** Propose via an issue first — discuss scope before building

---

## Conventions

### Skill Files

- Each skill lives in `skills/gtm-{name}/SKILL.md`
- Follow the YAML frontmatter format:
  ```yaml
  ---
  name: gtm-pipeline:{skill-name}
  description: One-line description. Trigger phrases at the end.
  ---
  ```
- Reference shared files with `~/.claude/skills/gtm-pipeline/_shared/conventions.md`
- Use snake_case for all CSV field names (see `_shared/conventions.md` for canonical names)

### No Personal Data

Never commit:
- API keys, session cookies, or secrets
- PhantomBuster agent IDs (these go in `_shared/local.md`, which is gitignored)
- Absolute paths (use `~/.claude/skills/...` or `$HOME`)
- Client names, domains, or real contact data
- Your name or identifying information

If a skill needs user-specific config, reference `_shared/local.md` with a config key.

### Shared Files

- `_shared/conventions.md` — field naming, terminology, directory structure
- `_shared/phantombuster.md` — PB API patterns and script templates
- `_shared/local.example.md` — template for personal config (update if you add new config keys)

### Examples

If your change affects the expected project structure, update `examples/sample-client-gtm/` to match.

---

## Testing Your Changes

```bash
# Install skills from your fork
./install.sh

# Open a project in Claude Code
claude .

# Invoke the skill you changed
/gtm-pipeline:{skill-name}
```

Verify:
- The skill runs without referencing missing files
- Field names match `_shared/conventions.md`
- No hardcoded paths, IDs, or personal data
- Existing skills that reference your changed skill still work

---

## Reporting Issues

Open an issue with:
- Which skill is affected
- What you expected vs. what happened
- Your provider setup (which API keys you have configured)

---

## Code of Conduct

Be constructive. This project exists to make GTM pipelines accessible — contributions that support that goal are welcome.
