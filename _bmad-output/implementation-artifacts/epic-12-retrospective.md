# Retrospective: Epic 12 - UI Zen-ification & Challenge Hub (RE-RUN)

**Date:** 2026-01-25
**Facilitator:** Bob (Scrum Master)
**Status:** Completed (Interactive Session)

## 1. Executive Summary

This retrospective was re-opened following user feedback that the initial run ignored critical functional failures. While the visual "Zen" refactor was successful, the **Challenge Mode** feature delivered in Epic 12 was functionally broken: it reused an incompatible UI (Game Mode) that provided no context or guidance, and the initial logic (now fixed) was random rather than adaptive.

- **Completion:** Visuals (Done) / Challenge Mode (FAILED - Critical Rework Needed)
- **Quality:** High for UI Layout, FAILED for User Experiment ($Challenge$ != $Game$).
- **User Feedback:** "The Challenge Mode doesn't function at all. The interface doesn't show the sequence or the goal. None of the objectives are met."

## 2. Review: What Went Well

- **Zen Restored:** The Home Screen layout refactor (12.1) successfully reclaimed vertical space and achieved the desired aesthetic.
- **Hotfix Responsiveness:** The team quickly fixed the "Freeze" (Main Thread) and "Random Logic" issues once reported.

## 3. Critical Failures & Lessons Learned

### Failure 1: The "Reuse" Trap
- **Issue:** To save time, we reused the existing `SessionView` (Game Mode) for Challenges.
- **Impact:** The user was presented with a blank keypad, no prompt ("What is the sequence?"), and no goal ("How many digits?"). It was unplayable.
- **Lesson:** **Context is King.** A "Challenge" (complete the sequence) is a fundamentally different mental model than "Game" (recite from scratch). Reusing the UI without adaptation was a product design failure.

### Failure 2: Feature gaps in "MVP"
- **Issue:** The Challenge Hub was released with only "Daily" logic, blocking users who wanted to test the feature more than once.
- **Impact:** Users could not verify or enjoy the feature after one attempt.
- **Lesson:** **Testability:** For engagement features, always provide a "Debug" or "Practice" trigger so users (and testers) aren't blocked by arbitrary time limits (24h).

## 4. Action Items

| Action Item | Owner | Priority |
| :--- | :--- | :--- |
| **Epic 13 Definition:** Scope "Challenge Interaction Repair" + "On-Demand Generation" | Product Owner | **Immediate** |
| **UI Design:** Mockup a specific "Challenge Session" view (Prompt + Placeholder Slots) | Design | High |
| **Tech Refactor:** Decouple `ChallengeService` from Date to allow on-demand generation | Senior Dev | High |

## 5. Next Epic: Epic 13 - Challenge Mode Repair & Expansion

Based on this retro, Epic 13 is explicitly defined to fix the broken experience and expand it.

**Title:** Epic 13 - Challenge Interaction & On-Demand
**Goals:**
1.  **Correct UI:** Implement a dedicated Challenge Interface displaying the **Prompt** (Unique Sequence) and the **Goal** (Target Slots based on Grade).
2.  **On-Demand:** Allow users to generate new challenges instantly from the Hub ("Training Mode"), separate from the "Daily Challenge".
3.  **Engagement:** Maintain the Daily Notification system but allow unlimited play.

**Readiness:**
- **Product:** Clear (Feedback is explicitly validated).
- **Tech:** Adaptive Logic V2 is ready; UI needs to be built.
