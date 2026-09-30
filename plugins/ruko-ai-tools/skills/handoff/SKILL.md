---
name: handoff
description: "Compact the current conversation into a handoff document for another agent to pick up. Use for «сделай хендофф», «передай контекст следующей сессии», \"handoff\"."
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---
<!-- Adapted from https://github.com/mattpocock/skills (MIT, © 2026 Matt Pocock). See THIRD_PARTY_LICENSES.md in the plugin root. -->

> **Language.** Talk to the user in Russian. Write the handoff document itself in English: it is read by an agent.

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS - not the current workspace.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
