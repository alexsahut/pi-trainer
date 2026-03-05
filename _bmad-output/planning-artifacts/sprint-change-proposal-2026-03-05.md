# Sprint Change Proposal — Bug Fix Clavier

**Date :** 2026-03-05
**Déclencheur :** Retours TestFlight post-Epic 17
**Scope :** Minor — fixes directs

---

## 1. Résumé du problème

Deux bugs liés à la configuration du clavier identifiés via retours TestFlight :

1. **Challenge mode** : la roue crantée du clavier est inopérante (callback `onOptions` désactivé, layout hardcodé)
2. **Practice mode** : le switch de disposition clavier (mobile/PC) dans les options de session n'a aucun effet (binding vers `SessionViewModel` au lieu de `StatsStore`)

## 2. Analyse d'impact

- **Epic :** Aucun epic impacté — tous sont done
- **PRD :** Pas de conflit — la config clavier est dans les specs
- **Architecture :** Le pattern StatsStore est correct, c'est un bug de câblage
- **UX :** L'UX prévue est correcte, elle n'était pas connectée partout

## 3. Approche recommandée

**Ajustement direct** — deux fixes ciblés sans impact sur le backlog.

- Effort : Low
- Risque : Low
- Timeline : Immédiat

## 4. Changements effectués

### Fix 1 : SessionSettingsView.swift (ligne 29)

**Avant :**
```swift
selection: $viewModel.keypadLayout
```

**Après :**
```swift
selection: $statsStore.keypadLayout
```

**Justification :** Le binding écrivait dans `SessionViewModel.keypadLayout` (variable locale non persistée) alors que `ProPadView` lit depuis `StatsStore.keypadLayout`. Alignement sur la même source, comme `SettingsView` (Home).

### Fix 2 : ChallengeSessionView.swift

**Changements :**
- Ajout de `statsStore = StatsStore.shared` et `@State showOptions`
- `ProPadView` reçoit `layout: statsStore.keypadLayout` au lieu du défaut `.phone`
- `onOptions` câblé vers `showOptions = true` au lieu du no-op
- Ajout `.sheet(isPresented: $showOptions)` → `ChallengeOptionsSheet`
- Nouvelle vue `ChallengeOptionsSheet` : disposition clavier + retour haptique

**Justification :** Le clavier Challenge était hardcodé sans accès config. Alignement avec le pattern Practice mode.

## 5. Handoff

- **Scope :** Minor — implémentation directe
- **Statut :** Fixes déjà implémentés et build validé
- **Prochaine étape :** Test manuel sur simulateur/device, puis soumission TestFlight
