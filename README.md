# team-awareness

A Claude Code skill that enables **peer-to-peer communication** between team agents instead of the default hub-and-spoke (leader-only) pattern.

## Problem

By default, Claude Code team agents only communicate with whoever spawned them (the team leader). Workers don't talk to each other — all messages flow through the leader, creating a bottleneck.

## Solution

This skill makes agents:
1. **Gather team context** at task start via `TaskList` / `TaskGet` tools
2. **Identify relevant peers** based on task dependencies and shared files
3. **Message peers directly** via `SendMessage` instead of routing through the leader
4. **Avoid conversation loops** with anti-pattern rules

## Install

```bash
# Claude Code only
npx skills add whalstndla/team-awareness-skill -g -y

# All agents (Claude Code, Codex, etc.)
npx skills add whalstndla/team-awareness-skill -g -y --agent '*'
```

Or manually:
```bash
curl -sL https://raw.githubusercontent.com/whalstndla/team-awareness-skill/main/install.sh | bash
```

## What It Does

| Phase | Action |
|-------|--------|
| **Context Gathering** | Calls `TaskList` / `TaskGet` to understand team state at task start |
| **Impact Analysis** | Identifies which peers are affected by your work |
| **Direct Communication** | Uses `SendMessage` to contact peers directly for info exchange, reviews, handoffs |
| **Message Discipline** | Blocks thank-you loops and empty acknowledgments |

## Anti-Loop Rules

- No thank-you / encouragement / acknowledgment-only messages
- 3+ round-trips on same topic without new content → stop and work
- Self-check before sending: "Does this contain new info, a question, or a deliverable?"

## Recommended CLAUDE.md Addition

For best results, also add this to your global `~/.claude/CLAUDE.md`:

```markdown
# Team Communication Protocol (applies to all team agents)

## Model Selection
- Use the model specified in the user's prompt if provided
- Otherwise, proceed with the user's default model (omit model parameter)

## Required at Task Start
1. **Call `TaskList`** — identify all tasks, owners, statuses, and dependencies
2. **Analyze dependencies** — which tasks block yours, which blockers your completion resolves
3. **Check delivered messages** — respond to messages auto-delivered via `SendMessage`

## Peer-to-Peer Rules
- **Use `SendMessage` to contact relevant members directly** — do NOT route through leader
- When your completion unblocks another task → notify that task's owner directly
- When you need another member's output → ask them directly
- When modifying the same file/module as another member → coordinate directly
- **Report to leader ONLY for blockers, schedule issues, or team decisions**
- **No gratitude/encouragement-only messages** — don't send unless it contains new info, a question, or a deliverable
```

## License

MIT
