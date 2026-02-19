---
stepsCompleted: ['step-01-validate-prerequisites', 'step-02-design-epics', 'step-03-create-stories', 'step-04-final-validation']
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/architecture.md'
  - '_bmad-output/planning-artifacts/ux-design-specification.md'
  - '_bmad-output/implementation-artifacts/epic-13-retrospective.md'
---

# pi-trainer - Epic Breakdown (Corrective & Polish)

## Overview

This breakdown focuses on **Epic 14**, designed to polish the Challenge Mode by fixing UX misalignments (Context vs Index), ensuring adaptive logic integrity (Scope), and aligning the interface with the Zen/OLED design system.

## Requirements Inventory

### Functional Requirements

FR-Fix-1: (Contextual UX) Replace technical index-based prompts with user-centric "Continue the sequence" messaging.
FR-Fix-2: (Adaptive Integrity) Ensure all challenge target digits are within the user's highest known index.
FR-Fix-3: (UX Recovery) Strengthen the link between failure and the "Learn Mode" bridge.

### NonFunctional Requirements

NFR1: Latence < 16ms (maintained during animations).
NFR4: WCAG AA & Design System alignment (Keypad aesthetics).

### Additional Requirements

- **UX**: OLED-optimized keyboard (Minimalist, correct colors).
- **Logic**: `ChallengeService` filtering refinements.

### FR Coverage Map

FR-Fix-1: Epic 14 - Story 14.1
FR-Fix-2: Epic 14 - Story 14.2
FR-Fix-3: Epic 14 - Story 14.1
NFR4: Epic 14 - Story 14.3

## Epic List

### Epic 14: Challenge Polish & UX Integrity
**Goal:** Transform the Challenge Mode from a functional prototype into a premium, context-aware experience that respects the user's knowledge scope and the app's Zen aesthetics.
**FRs covered:** FR-Fix-1, FR-Fix-2, FR-Fix-3, NFR4

## Epic 14: Challenge Polish & UX Integrity

**Goal:** Transform the Challenge Mode from a functional prototype into a premium, context-aware experience that respects the user's knowledge scope and the app's Zen aesthetics.

### Story 14.1: Contextual UX & Messaging

As a user,
I want to be prompted to "Continue the sequence" based on what I see on screen,
So that I don't have to think about technical "indexes" or "positions" while training my memory.

**Acceptance Criteria:**

**Given** I am on the Challenge Hub
**When** I see the Daily Challenge card
**Then** the description says "Continue the sequence..." instead of "Find index #X"
**Given** I am in a Challenge Session
**When** looking at the UI
**Then** the header and labels emphasize the sequence continuity
**And** the "Practice This" button (Recovery Bridge) clearly indicates it will help me learn the sequence I just failed.

### Story 14.2: Adaptive Logic Integrity (Scope Guard)

As a user,
I want the challenge to only ask for digits that I have already learned,
So that I am never blocked by an unfair requirement for unknown decimals.

**Acceptance Criteria:**

**Given** my highest known index is N
**When** a challenge is generated (Daily or Train Now)
**Then** the `startIndex + promptLength + targetLength` must be less than or equal to N
**And** the `ChallengeService` filters out any candidate sequences that would overshoot my learned range.

### Story 14.3: Zen Keyboard & Visual Alignment

As a user,
I want the challenge keyboard to feel as premium and "Zen" as the rest of the app,
So that the interface feels cohesive and immersive.

**Acceptance Criteria:**

**Given** I am in a Challenge Session
**When** I use the keyboard
**Then** its design (colors, spacing, typography) perfectly matches the `DesignSystem` (OLED Black, Cyan/Orange accents)
**And** the layout is optimized for the "Prompt + Placeholder" view, maintaining vertical balance.
