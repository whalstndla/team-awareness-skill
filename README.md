# team-awareness

A Claude Code skill that enables **peer-to-peer communication** between team agents instead of the default hub-and-spoke (leader-only) pattern.

## Problem

By default, Claude Code team agents only communicate with whoever spawned them (the team leader). Workers don't talk to each other — all messages flow through the leader, creating a bottleneck.

## Solution

This skill makes agents:
1. **Gather team context** at task start (read config, tasks, inbox)
2. **Identify relevant peers** based on task dependencies and shared files
3. **Message peers directly** instead of routing through the leader
4. **Avoid conversation loops** with anti-pattern rules

## Install

```bash
curl -sL https://raw.githubusercontent.com/whalstndla/team-awareness-skill/main/install.sh | bash
```

Or manually copy `SKILL.md` to `~/.claude/skills/team-awareness/`.

## What It Does

| Phase | Action |
|-------|--------|
| **Context Gathering** | Reads team config, tasks, and inbox at task start |
| **Impact Analysis** | Identifies which peers are affected by your work |
| **Direct Communication** | Messages peers directly for info exchange, reviews, handoffs |
| **Message Discipline** | Blocks thank-you loops and empty acknowledgments |

## Anti-Loop Rules

- No thank-you / encouragement / acknowledgment-only messages
- 3+ round-trips on same topic without new content → stop and work
- Self-check before sending: "Does this contain new info, a question, or a deliverable?"

## Recommended CLAUDE.md Addition

For best results, also add this to your global `~/.claude/CLAUDE.md`:

```markdown
# Team Communication Protocol

## Required at Task Start
1. Read `~/.claude/teams/{teamName}/config.json` — identify all teammates
2. Read `~/.claude/teams/{teamName}/tasks/*.json` — identify who's doing what
3. Read `~/.claude/teams/{teamName}/inboxes/{myName}.json` — check messages

## Peer-to-Peer Rules
- Message relevant members directly — do NOT route through leader
- When your task completion unblocks another task → notify the owner directly
- When you need another member's output → ask them directly
- Report to leader ONLY for blockers, schedule issues, or team decisions
```

## License

MIT
