# About

This is a configuration for the [statusline](https://github.com/sirmalloc/ccstatusline) command. It is used to display the status of the current git repository in the terminal.

I got the idea from [Matt Pocock's blog post](https://www.aihero.dev/creating-the-perfect-claude-code-status-line).

The `settings.json` file is the configuration for the statusline command, and it's stored at `~/.config/ccstatusline/settings.json`

On the `~/.claude/settings.json` file, you can set:

```json
"statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
},
```
