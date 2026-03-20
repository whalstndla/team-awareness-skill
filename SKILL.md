---
name: team-awareness
description: Enables team agents to automatically gather team context at task start and communicate directly peer-to-peer with relevant members instead of routing everything through the leader. Auto-triggers on task start/completion/blocker events.
user-invocable: false
---

# Team Awareness — Peer-to-Peer Communication Protocol

This skill ensures team agents communicate directly with relevant peers rather than routing all communication through the team leader.

## Trigger Conditions

This skill applies automatically when:
- Spawned as a team agent (team task start)
- Assigned a new task
- Completing a task
- Encountering a blocker
- Needing another member's work output

## Phase 1: Team Context Gathering (Required at Task Start)

Before starting any work, you **MUST** perform the following:

### 1. Identify Team Members
```bash
# Read team config — identify all members and their roles
cat ~/.claude/teams/{teamName}/config.json
```

Extract from the result:
- **All member names and roles** — these are your peers
- Which members work in the same domain/area as you

### 2. Identify Current Work in Progress
```bash
# Check all task files
ls ~/.claude/teams/{teamName}/tasks/
# Read each task file
cat ~/.claude/teams/{teamName}/tasks/*.json
```

Extract from the result:
- **Who is working on what** (owner field)
- **Which tasks have dependencies on my task** (blockedBy, blocks fields)
- **Whose blockers will my task completion resolve**

### 3. Check My Inbox
```bash
# Check messages sent to me
cat ~/.claude/teams/{teamName}/inboxes/{myName}.json
```

If there are unread messages, you **MUST** respond to them.

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

### When to Message Peers Directly (Do NOT route through leader)

1. **My work output is needed by another member**
   → Message them directly: "Done. Here's where to find it."

2. **I need another member's work output**
   → Message them directly: "I need X. When will it be ready?"

3. **Another member is modifying the same file/module**
   → Message them directly: "I'm also working on this file. Let's coordinate."

4. **I need a code review**
   → Message the domain peer directly with a review request

5. **I found a bug or issue**
   → Message the code owner directly with a report

### When to Report to Leader Only

- External dependency issues (cannot be resolved within the team)
- Expected schedule delays
- Team-level decisions required
- Progress report explicitly requested by leader

## Phase 4: Task Completion

When completing a task:

1. **Check the `blocks` field** — Does my task unblock other tasks?
2. If yes, **message the owner of each blocked task directly**:
   - What was completed
   - Where to find the output (file paths, branches, etc.)
   - Context needed for handoff
3. Send only a brief completion notice to the leader

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
