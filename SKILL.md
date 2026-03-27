---
name: team-awareness
description: Enables team agents to automatically gather team context at task start and communicate directly peer-to-peer with relevant members instead of routing everything through the leader. Auto-triggers on task start/completion/blocker events.
user-invocable: false
---

# Team Awareness — Peer-to-Peer Communication Protocol

This skill ensures team agents communicate directly with relevant peers rather than routing all communication through the team leader.

## Trigger Conditions

This skill auto-triggers when the skill description matches any of these contexts:
- You are a team agent (spawned via `Agent` tool with a team)
- You are starting, completing, or blocked on a task
- You need another member's work output

## How Messages Work

Messages from teammates are **delivered automatically** into your conversation context via `SendMessage`. You do NOT poll or check an inbox — messages simply appear in your conversation when they arrive.

## Phase 1: Team Context Gathering (Required at Task Start)

Before starting any work, you **MUST** call `TaskList` to understand the team state:

```
Tool: TaskList (no parameters)
→ Returns: id, subject, status, owner, blockedBy for each task
```

From the result:
1. **Identify your peers** — the `owner` field shows who is working on what
2. **Identify dependencies** — `blockedBy` shows which tasks block yours; find tasks where yours appears in their `blockedBy` to see what you unblock
3. **Use `TaskGet(taskId)`** for full details (description, comments) on any task you need to understand
4. **Respond to any pending messages** that arrived in your conversation before starting work

Do NOT skip this step. Understanding the team context prevents duplicate work and missed handoffs.

## Phase 2: Impact Analysis

Analyze the scope of impact your work has on others:

| My Work Type | Affected Members | Required Action |
|-------------|-----------------|----------------|
| API change/creation | Members consuming the API | Send spec change notification |
| Shared module modification | Module consumers | Send change notification |
| Design/UI change | Frontend developers | Send design spec |
| Test failure discovered | Code author | Send bug report directly |
| Task completion | Owners of tasks in my `blocks` list | Send completion notice + handoff |
| Blocker encountered | Owner of task in my `blockedBy` list | Send direct status inquiry |

## Phase 3: Direct Communication

Use `SendMessage` to communicate with peers. Always specify the teammate's **name** (from the `owner` field in TaskList) in the `to` parameter:

```
Tool: SendMessage
  to: "teammate-name"       ← peer's name (NOT UUID)
  summary: "brief preview"  ← 5-10 words shown in UI
  message: "full content"   ← the actual message
```

To broadcast to all teammates (use sparingly): `to: "*"`

### When to Message Peers Directly (Do NOT route through leader)

1. **My work output is needed by another member**
   → `SendMessage(to: "peer-name", summary: "task X complete", message: "Done. Output at src/foo.js")`

2. **I need another member's work output**
   → `SendMessage(to: "peer-name", summary: "need API spec", message: "I need the API spec for X. When will it be ready?")`

3. **Another member is modifying the same file/module**
   → `SendMessage(to: "peer-name", summary: "coordinate on shared file", message: "I'm also modifying src/shared.js. Let's coordinate.")`

4. **I need a code review**
   → `SendMessage(to: "peer-name", summary: "review request", message: "Please review my changes in src/feature.js")`

5. **I found a bug or issue**
   → `SendMessage(to: "peer-name", summary: "bug in module X", message: "Found a bug in src/module.js:42 — details: ...")`

### When to Report to Leader Only

- External dependency issues (cannot be resolved within the team)
- Expected schedule delays
- Team-level decisions required
- Progress report explicitly requested by leader

## Phase 4: Task Completion

When completing a task:

1. **Call `TaskList`** again — check the `blockedBy` fields to find tasks that list yours
2. If your task unblocks others, **`SendMessage` to each blocked task's owner**:
   - What was completed
   - Where to find the output (file paths, branches, etc.)
   - Context needed for handoff
3. **Update your task status** via `TaskUpdate(taskId, status: "completed")`
4. Send only a brief completion notice to the leader

## Anti-Patterns: Message Discipline

**CRITICAL: Do NOT fall into conversation loops.**

- Do NOT send thank-you, encouragement, or acknowledgment-only messages. If a message contains no actionable information, question, or deliverable — do NOT send it.
- If you and another member have exchanged 3+ round-trips on the same topic without new substantive content (new data, a decision, or a deliverable), STOP messaging and move on to your actual task work.
- After collecting the information you need, immediately switch to writing your document. Do NOT continue chatting.
- Never reply to a thank-you with another thank-you. Never reply to encouragement with more encouragement.

**Test before sending:** Ask yourself — "Does this message contain new information, a question, or a deliverable?" If the answer is no, do NOT send it.

## Core Principles

```
❌ Route all communication through the leader
✅ Communicate directly with relevant peers; send leader only summaries

❌ Finish my work and stop
✅ Handle the downstream impact of my completion on other members

❌ Work without knowing what others are doing
✅ Gather team context before starting any work

❌ Hit a blocker → report to leader → wait
✅ Hit a blocker → message the blockedBy task owner directly

❌ Send thank-you / encouragement / "got it" messages back and forth
✅ Receive info → move on to task work immediately
```
