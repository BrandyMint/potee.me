# Potee skill for AI agents

Lets an AI agent (Claude Code, Codex and others that support skills) read and
change your board at <https://potee.pismenny.ru>: create projects with
milestones, move them, rename, delete. `SKILL.md` is what the agent reads;
`scripts/potee-mcp` is a small Python 3 CLI (no dependencies) that calls the
board's MCP server.

## 1. Get a token

Register at <https://potee.pismenny.ru> (anonymous boards have no token), open
<https://potee.pismenny.ru/account> and create an API token. It is shown once;
creating a new one revokes the old.

Make it available to the agent as `POTEE_TOKEN`, e.g. in your shell profile:

```sh
export POTEE_TOKEN=...            # bash / zsh
set -gx POTEE_TOKEN ...           # fish
```

## 2. Install the skill

With the [`skills`](https://github.com/vercel-labs/skills) CLI:

```sh
npx skills add BrandyMint/potee.me --skill potee -g           # pick agents interactively
npx skills add BrandyMint/potee.me --skill potee -g -a claude-code -y
npx skills update potee                                        # later, to update
```

Or copy this directory by hand into your agent's skills directory:

```sh
git clone https://github.com/BrandyMint/potee.me
cp -R potee.me/skills/potee ~/.claude/skills/    # Claude Code
cp -R potee.me/skills/potee ~/.codex/skills/     # Codex
```

Check that it works:

```sh
~/.claude/skills/potee/scripts/potee-mcp call list_projects
```

Then ask the agent in plain words: «put the course launch on Potee: 1–28
November, webinars on Wednesdays at 19:00».

## Alternative: connect the MCP server directly

Agents with MCP support can use the server without the skill (the skill adds
working rules, e.g. look at the board before creating duplicates). Endpoint:
`https://potee.pismenny.ru/mcp`, Streamable HTTP, header
`Authorization: Bearer <token>`.

Claude Code:

```sh
claude mcp add --transport http potee https://potee.pismenny.ru/mcp \
  --header "Authorization: Bearer $POTEE_TOKEN"
```

Codex (`~/.codex/config.toml`):

```toml
[mcp_servers.potee]
url = "https://potee.pismenny.ru/mcp"
bearer_token_env_var = "POTEE_TOKEN"
```

## How the CLI talks to the server

Each command is one HTTP POST of a JSON-RPC 2.0 request (`tools/list` or
`tools/call`) with the bearer token; the server is stateless and answers with
plain JSON, so no session or `initialize` handshake is needed.

| Variable | Default |
| --- | --- |
| `POTEE_TOKEN` | — (required) |
| `POTEE_MCP_URL` | `https://potee.pismenny.ru/mcp` |
