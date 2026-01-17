# Story 4.3: Historique Détaillé des Performances

Status: done

## Story

As a utilisateur,
I want pouvoir consulter la liste de mes 200 sessions les plus récentes,
so that analyser mon évolution de vitesse et de précision.

## Acceptance Criteria

1. **Given** l'écran de statistiques
2. **When** je consulte l'historique
3. **Then** les 200 dernières sessions sont listées (date, score, vitesse moyenne en CPS)
4. **And** les données sont chargées de manière asynchrone depuis le stockage fichier.

## Tasks / Subtasks

- [ ] Create `HistoryRow` component (AC: 3)
- [ ] Implement `HistoryListView` in `StatsView` (AC: 1, 2)
- [ ] Connect `StatsStore.loadHistory` to the view (AC: 4)
- [ ] Verify UI performance with large datasets (AC: 4)

## Dev Notes

- Use the already implemented `StatsStore.loadHistory(for:)` which fetches from `SessionHistoryStore`.
- The history is stored per constant; ensure the view switches history when the constant changes.
- Records include bits like `digitsPerMinute`; convert to CPS (Characters Per Second) if required (CPS = DPM / 60) or similar. The spec mentions CPS.
- Follow the Zen aesthetic: Cyan accents, monospaced fonts, dark background.

### Project Structure Notes

- New components in `PiTrainer/PiTrainer/` (or a sub-feature folder if preferred).

### References

- [Epics: Story 4.3](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md#L308-L320)
- [StatsStore.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/StatsStore.swift)
- [StatsView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/StatsView.swift)
