# Retrospective: Epic 10 - Raffinements Expérience Utilisateur

**Date:** 2026-01-22
**Facilitator:** Bob (Scrum Master)
**Status:** Completed

## 1. Executive Summary

Epic 10 focused on refining the user experience based on community feedback, specifically introducing "Indulgent Mode" and "Loop Reset". While the core logic was delivered successfully, a critical UI regression was identified in Learn Mode during the retrospective, leading to an immediate hotfix action item.

- **Completion:** 100% (2/2 Original Stories Done) -> Re-opened for Hotfix (Story 10.3)
- **Quality:** Mixed (Good logic, UI regression in Learn Mode)
- **User Feedback:** "Auto-Advance" is a game changer for flow. "Loop Reset" is essential but currently hindered by the UI bug.

## 2. Review: What Went Well

- **Feature Impact:** The "Auto-Advance" (Story 10.1) significantly improved the flow for speed users, transforming the practice rhythm.
- **Core Logic:** The "Loop Reset" (Story 10.2) logic was implemented cleanly, preserving session stats while resetting local progress.
- **Team Agility:** The team quickly identified the Learn Mode regression and pivoted to a Hotfix strategy immediately during the retro.

## 3. Challenges & Lessons Learned

### Challenge 1: Integration Regressions causing UI Bugs
- **Issue:** The Learn Mode keyboard layout broke (Appeared in middle of screen) likely due to recent view hierarchy changes.
- **Detection:** Found during final user review/retro.
- **Lesson:** **Visual Regression Testing:** We need to manually verify ALL modes (Learn, Practice, Game) even if changes seem isolated to one.

### Challenge 2: UX Optimization Opportunities
- **Issue:** The "Back" button on the dedicated keyboard is redundant with standard navigation gestures, while the new "Reset Loop" feature needed a prime spot.
- **Decision:** Replace the unused "Back" button with "Reset Loop" in Learn Mode.
- **Lesson:** **Contextual UI:** Don't just stick to standard layouts; optimize for the specific mode's needs.

## 4. Action Items

| Action Item | Owner | Priority |
| :--- | :--- | :--- |
| **STORY 10.3 (HOTFIX):** Fix Learn Mode UI & Implement Loop Reset Button on Keyboard | Alex | **CRITICAL** |
| **Epic 11 Prep:** Finalize `challenges.json` dataset | Alice | High |
| **Epic 11 Prep:** Create "Double Bang" particle assets | Design | Medium |

## 5. Preview: Epic 11 - Engagement & Récompenses

We are shifting focus to **Retention**.

- **Focus:** Daily habits (Challenges) and progression (XP/Grades).
- **Dependencies:** None blocking, but stability of Epic 10 features is required.
- **Readiness:**
    - Architecture for "Zero-Code" XP is approved.
    - **CAUTION:** Do not start Epic 11 until Story 10.3 is verified.
