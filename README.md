# My Skills

A collection of custom [Claude Code skills](https://docs.anthropic.com/en/docs/claude-code/skills) that extend Claude's capabilities with reusable, domain-specific workflows.

## Skills

| Skill | Description |
|-------|-------------|
| [notion-to-markdown](./notion-to-markdown/SKILL.md) | Export a Notion page to a local `.md` file with automatic cleanup of Notion-specific markup |
| [plan-validator](./plan-validator/SKILL.md) | Validate refactoring plans and architectural changes for security, circular dependencies, architectural fit, scalability, and maintainability |
| [ubiquitous-language](./ubiquitous-language/SKILL.md) | Extract a DDD-style ubiquitous language glossary from the current conversation, flagging ambiguities and proposing canonical terms |

## Usage

Add this repository as a skill source in your Claude Code configuration, then invoke skills by name or let Claude match them automatically based on your request.

## Adding a new skill

1. Create a directory named after the skill (e.g. `my-skill/`)
2. Add a `SKILL.md` file with frontmatter (`name`, `description`) and instructions
3. Commit and push

## Structure

```
my-skills/
├── <skill-name>/
│   └── SKILL.md          # Skill definition with frontmatter + instructions
└── README.md
```
