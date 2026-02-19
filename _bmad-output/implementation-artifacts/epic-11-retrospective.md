# Retrospective: Epic 11 - Engagement & Récompenses

**Date:** 2026-01-25
**Facilitator:** Bob (Scrum Master)
**Status:** Completed

## 1. Executive Summary

Epic 11 successfully delivered the engagement engine (XP, Grades, Daily Challenges) with a highly efficient "Zero-Code" architecture. The team demonstrated high autonomy and delivered a stable build. However, the addition of these features without a UI overhaul has created clutter and layout issues on the Home screen, necessitating a dedicated UI-focused epic next.

- **Completion:** 100% (3/3 Stories) + 1 Hotfix (Story 10.3)
- **Quality:** High (Stable build, Non-regressions validated)
- **User Feedback:** "Autonomy and stability are great," but "Home screen is too cluttered" and "Daily Challenge UI is missing."

## 2. Review: What Went Well

- **Zero-Code Architecture:** The decision to use existing `StatsStore` data for XP instead of a complex DB migration allowed for rapid delivery and zero backend maintenance.
- **Team Autonomy:** The team moved from story to test to build with minimal friction, delivering a "working out of the box" experience.
- **Stability:** Strict non-regression testing paid off; the simulator build runs perfectly at the end of the epic.

## 3. Challenges & Lessons Learned

### Challenge 1: UI Scalability & "Feature Creep"
- **Issue:** Adding XP, Grades, Mode Selector, and Slider to the Home screen broke the "Zen" layout on smaller screens (cut-off content).
- **Lesson:** **Layout Budget:** When adding visible features, we must simultaneously "pay" for the space by removing or condensing old elements. We can't just keep adding.

### Challenge 2: Headless Features
- **Issue:** The Daily Challenge engine (Story 11.1) works perfectly but has no UI entry point, making it untestable by the user.
- **Lesson:** **Full-Stack Stories:** Even "engine" stories should include a minimal debug UI or entry point if they are user-facing features.

### Challenge 3: Logic Ordering Risk
- **Issue:** A near-miss race condition in `StatsStore` for the "Double Bang" reward.
- **Lesson:** **State Transition Analysis:** For rewards/animations dependent on state changes, explicitly map out the "Before -> Action -> Persistence -> Notification -> After" flow during design.

## 4. Action Items

| Action Item | Owner | Priority |
| :--- | :--- | :--- |
| **Fix `GRADE.NOVICE` Bug:** Use `.displayName` in `GradeBadge` | Elena | **Immediate** |
| **Epic 12 Prep:** Design "Challenge Hub" wireframe | Design | High |
| **Epic 12 Prep:** Audit Home Screen layout on SE/Mini devices | iOS Dev | Medium |

## 5. Preview: Epic 12 - UI Zen-ification & Challenge Hub

We are pivoting to a **UI/UX Polish** epic to absorb the complexity added in Epic 11.

- **Focus:** Restore the "Zen" aesthetic and give Daily Challenges a proper home.
- **Key Stories:**
    1.  **Home Screen Zen:** Remove Title, Compact Start Button, Adaptive Layout.
    2.  **Challenge Hub:** Dedicated view for launching/tracking daily challenges.
    3.  **Visual Polish:** Fix raw strings, alignment issues.

- **Readiness:**
    - **Needs Design:** We need a quick wireframe/sketch for the Challenge Hub before coding.
    - **Tech Stack:** SwiftUI `Canvas` usage validated in Epic 11 will be useful here.
