# claude-token-statusline

A simple, native **statusline** for [Claude Code](https://code.claude.com) on Windows (PowerShell) that shows your token usage, context window %, and estimated cost right below the input box — no browser extensions, no external services, no API keys, 100% local.

```
[Sonnet] ##-------- 25% | tokens in:15000 out:3000 | custo: $0.12
```

## Why

Claude Code supports a native "statusline" feature — a script that receives session data (as JSON) via stdin and prints whatever you want back to the terminal. Most examples online are written for bash/macOS/Linux. This repo is a **ready-to-use PowerShell version** for Windows users (including inside the VS Code integrated terminal), since the official docs' bash examples fail with `ParserError` when pasted into PowerShell.

## What it shows

- Current model in use
- A 10-character progress bar of context window usage
- Context window usage percentage
- Input / output token counts
- Estimated session cost in USD

## Requirements

- Windows with PowerShell (built-in, nothing extra to install)
- [Claude Code](https://code.claude.com) already installed and working

## Installation

1. Clone this repo or just download `statusline.ps1`.

   ```powershell
   git clone https://github.com/waine-r/claude-token-statusline-.git
   ```

2. Copy `statusline.ps1` into your Claude Code config folder:

   ```powershell
   copy statusline.ps1 $env:USERPROFILE\.claude\statusline.ps1
   ```

3. Open (or edit) `$env:USERPROFILE\.claude\settings.json` and add the `statusLine` block from [`settings.example.json`](./settings.example.json), replacing `YOUR_USERNAME` with your Windows username. **If you already have a `settings.json` with other keys (plugins, theme, model, etc.), only add the `statusLine` key — don't overwrite the rest of the file.**

   You can do this safely from PowerShell without hand-editing JSON:

   ```powershell
   cd $env:USERPROFILE\.claude
   $settings = Get-Content settings.json -Raw | ConvertFrom-Json
   $statusLine = @{
       type = "command"
       command = "powershell -NoProfile -File `"$env:USERPROFILE\.claude\statusline.ps1`""
   }
   $settings | Add-Member -MemberType NoteProperty -Name "statusLine" -Value $statusLine -Force
   $settings | ConvertTo-Json -Depth 10 | Out-File -FilePath settings.json -Encoding utf8
   ```

4. Test the script directly (optional but recommended):

   ```powershell
   '{"model":{"display_name":"Sonnet"},"context_window":{"used_percentage":25,"total_input_tokens":15000,"total_output_tokens":3000},"cost":{"total_cost_usd":0.12}}' | .\statusline.ps1
   ```

   Expected output:

   ```
   [Sonnet] ##-------- 25% | tokens in:15000 out:3000 | custo: $0.12
   ```

5. Restart Claude Code (`claude`). The statusline should now appear below the prompt input, updating as you chat.

## Customizing

The script is a single, short PowerShell file — feel free to edit `statusline.ps1` to:
- Change colors (add ANSI codes)
- Show/hide fields
- Change the bar width or characters
- Add git branch info, date/time, etc.

Claude Code sends the full session JSON on every render — check the [official statusline docs](https://code.claude.com/docs/statusline) for all available fields (model, context window, cost, workspace, output style, and more).

## Notes

- Runs 100% locally — no data leaves your machine, no API calls, no extra cost.
- Only affects the terminal display; it does not change Claude Code's actual behavior or limits.
- Tested on Windows 10/11, PowerShell 5.1+, using the VS Code integrated terminal.

## License

MIT — do whatever you want with it.
