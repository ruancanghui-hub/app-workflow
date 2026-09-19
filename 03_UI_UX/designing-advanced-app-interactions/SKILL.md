---
name: designing-advanced-app-interactions
description: Select, specify, or prompt high-feedback mobile App or mini-program interactions. Use when a prototype or implementation needs motion behavior beyond static screens, or when a user needs an English copyable prompt for a named interaction pattern.
---

# Designing Advanced App Interactions

Turn a visual interaction idea into a **continuous contract**: what starts it, what changes while the user acts, which threshold commits or cancels it, and which state owns the result. This is Phase 3 interaction specification work. It does not add effects that do not advance a user task.

## Inputs

Read the approved PRD, root Tab or prototype contract, and the destination screen/state. Identify the action that the interaction serves: navigation, selection, preview, acknowledgement, or a bounded value change.

Use this skill for one or more named interaction moments. Keep ordinary tap navigation and static state changes simple.

## Workflow

1. Name the task moment and its owner state. State the source, destination or temporary state, and the user-visible value that changes.
2. Select the smallest matching pattern from [the interaction catalog](references/interaction-patterns.md). Adapt its thresholds and visual vocabulary to the product; do not copy a travel-app example or a platform-specific implementation blindly.
3. Write one contract per interaction in `docs/prototype/<product_slug>/interaction-contracts.md`, using this shape:

   ```md
   ### <interaction name>
   - User goal: <what the person is trying to do>
   - Trigger: <gesture or control>
   - Continuous feedback: <what changes before release>
   - Commit: <threshold / valid target / release condition>
   - Cancel or reversal: <how the prior state returns>
   - Accessibility fallback: <equivalent non-gesture action>
   - Implementation boundary: <shared component, route, or local state>
   - Acceptance: <observable behavior>
   ```

4. Add the interaction to the relevant editable prototype or implementation only after the contract identifies its fallback and terminal states. Preserve system navigation gestures and platform gesture areas.
5. Verify the real gesture or control in the target runtime. Test commit, cancellation, reversal, and the fallback once each. Record a limitation only when a platform or runtime prevents the approved behavior.

## Prompt-only requests

When the user asks for an AI prompt rather than implementation, select one primary pattern. Use a secondary pattern only when it has a distinct task role.

Return:

1. **Selected interaction** — English and Chinese pattern name.
2. **Why this fits** — a concise Chinese explanation based on origin, destination, responding elements, or layout reflow.
3. **Interaction behavior** — Chinese trigger, initial state, continuous changes, terminal state, and cancellation behavior.
4. **Copyable prompt** — exactly one English prompt. Include the object, trigger, state transition, concrete motion properties, data/visual state relationship, responsive behavior, keyboard and touch support, reduced-motion fallback, and instruction to preserve unrelated components.

Make one clear assumption when enough context exists to proceed. Do not combine unrelated patterns or add project code to a prompt-only response.

## Outputs

- `docs/prototype/<product_slug>/interaction-contracts.md`
- editable prototype or implementation behavior linked from the contract
- a short verification note in the relevant prototype QA report

Pass the contracts to Flutter implementation with the owning screen or shared component. Motion without a named owner and terminal state is not ready to implement.
