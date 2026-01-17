# Story 4.2: Dashboard des Records Personnels (PB)

Status: done

## Story

As a utilisateur,
I want voir un résumé de mes meilleures performances pour chaque constante,
so that visualiser mes sommets.

## Acceptance Criteria

1. **Given** l'écran d'accueil
2. **When** je consulte mes records
3. **Then** le record (nombre max de chiffres) s'affiche pour Pi, e et Phi
4. **And** la date de réalisation du record est affichée à côté du score.

## Tasks / Subtasks

- [ ] Create `RecordDashboardView` component (AC: 3, 4)
- [ ] Integrate `RecordDashboardView` into `HomeView` footer (AC: 1, 2)
- [ ] Update `StatsStore` to provide formatted PB data if needed (AC: 3)
- [ ] Verify UI layout and data binding (AC: 3, 4)

## Dev Notes

- Use the existing `StatsStore` which already tracks `bestStreak` and `lastSession` for each constant.
- The footer in `HomeView` currently has a placeholder "RECORDS PERSONNELS >". This should be expanded or replaced with a concise summary.
- Display the PB for Pi, E, and Phi (and SQRT2 as it is in the `Constant` enum).

### Project Structure Notes

- New view components should go into `PiTrainer/PiTrainer/`.

### References

- [Epics: Story 4.2](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md#L295-L306)
- [HomeView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/HomeView.swift)
- [StatsStore.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/StatsStore.swift)
