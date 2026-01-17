# AGENTS.md — Règles de collaboration (PiTrainer)

Ce document définit notre manière de travailler avec Antigravity sur ce repo.  
But : éviter les erreurs, les oublis, les “ça a été push” alors que non, et standardiser la qualité.

## 1) Méthode de travail (obligatoire)
1. **Modifier le code en local uniquement** (dans ce repo).
2. **Exécuter les tests en local** avant toute affirmation “c’est OK”.
3. **Ne jamais dire qu’un commit/push est fait** sans preuve (voir section 4).
4. **Commit/push seulement quand tout est vert**.
5. **Ne pas faire d’archive manuelle** : Xcode Cloud gère build/archive/TestFlight.
6. **Toujours rédiger les actions et explications en français**.

## 2) Règles Git (anti-perte de temps)
### 2.1 Avant de commencer
- Afficher l’état du repo :
  - `git status`
  - `git log -1 --oneline --decorate`
  - `git remote -v`

### 2.2 Après modifications (avant commit)
- Vérifier qu’aucun fichier important n’est “untracked” par oubli :
  - `git status`
- Si des fichiers doivent être versionnés : les ajouter explicitement.

### 2.3 Commit / Push : preuve obligatoire
Quand tu annonces que c’est commité/pushé, tu DOIS fournir :
- le SHA du commit local : `git rev-parse HEAD`
- la correspondance remote :
  - `git ls-remote origin refs/heads/main`
- et confirmer que les deux pointent sur le même SHA.
- vérifier que la branche est correcte :
  - `git branch --show-current`
  - `git status` (doit indiquer “up to date with 'origin/main'”)

Aucun “c’est push” sans ces preuves.

## 3) Tests (toujours en local, et en parallèle par défaut)
### 3.1 Par défaut
- Exécuter les tests **avec parallélisation** :
  - `xcodebuild test -scheme PiTrainer -destination 'platform=iOS Simulator,name=iPhone 16e' -only-testing:PiTrainerTests -parallel-testing-enabled YES`

### 3.2 Si flakiness / crash / Busy simulator
- Repasser temporairement en non-parallèle :
  - `-parallel-testing-enabled NO`
- Si erreur “Busy / preflight checks” :
  - `xcrun simctl shutdown all || true`
  - `killall Simulator || true`
  - `xcrun simctl erase all`
  - puis relancer le test

### 3.3 Règle d’or
- Les tests locaux sont la source de vérité.
- Xcode Cloud sert à **builder et livrer**, pas à “découvrir” les erreurs.

## 4) Règles d’exécution (confirmations)

### Commandes autorisées sans confirmation
- Tu exécutes directement (sans me demander “Proceed?”) :
  - xcodebuild test (et toutes variantes : -only-testing, -parallel-testing-enabled, -enableAddressSanitizer, etc.)
  - xcodebuild build / archive
  - commandes de diagnostic NON destructives :
    git status, git diff, git log, git show, git rev-parse, git branch, git ls-remote, git remote -v,
    ls, find, grep/rg, cat, pwd, echo, sw_vers, xcrun simctl list
  - commandes de nettoyage NON risquées et ciblées :
    rm -rf ~/Library/Developer/Xcode/DerivedData/PiTrainer-* (uniquement ce pattern)

- Après exécution : tu fournis les sorties utiles (erreurs + résumés), et tu continues à avancer.

### Commandes nécessitant confirmation
- Tu DOIS me demander validation avant :
  - git commit / git push / git tag
  - git reset --hard / rebase / amend / force push
  - suppression de fichiers dans le repo (rm -rf … dans le workspace)
  - changements de config Xcode Cloud / App Store Connect
  - xcrun simctl erase all (Uniquement si Busy persistant ET après validation), ou toute commande destructive sur simulateurs
  - toute action irréversible ou à impact large

## 5) Definition of Done (DoD) pour toute PR/itération
Avant de dire “c’est terminé” :
1. `git status` = clean (ou seulement les fichiers attendus)
2. Tests locaux OK (commande en 3.1 ou 3.2)
3. Commit créé avec un message clair
4. Push vérifié avec preuves (section 2.3)
5. Résumé : liste des fichiers modifiés + ce que ça change côté user

## 6) Communication et anti-hallucination
- Si une action n’a pas été exécutée, dire “je propose de faire …” au lieu de l’affirmer.
- Ne jamais inventer un résultat de commande.
- Toujours distinguer :
  - “Je vais faire X”
  - “J’ai fait X (preuve ci-dessous)”
- En cas d’incertitude : vérifier via commandes plutôt que supposer.

## 7) Gestion des branches V1 / V2

> ⚠️ **LECTURE OBLIGATOIRE** : Tout agent DOIT lire cette section AVANT de modifier du code.

### 7.1 Vue d'ensemble des branches

| Branche | Version | CI/CD | TestFlight | Usage |
|---------|---------|-------|------------|-------|
| `main` | V1 | ✅ Actif | ✅ Oui | Production, hotfixes critiques |
| `v2-development` | V2 | ❌ Désactivé | ❌ Non | Développement nouvelles fonctionnalités |

### 7.2 🚨 VÉRIFICATION OBLIGATOIRE AU DÉMARRAGE

**AVANT toute modification de code, exécuter :**
```bash
git branch --show-current
git status
```

**Interpréter le résultat :**
- Si `main` → Tu es sur V1 (production)
- Si `v2-development` → Tu es sur V2 (développement)
- Si autre chose → STOP et demander clarification à l'utilisateur

---

## 📋 PROCÉDURE A : Correction V1 (Hotfix Production)

> **Quand utiliser** : L'utilisateur demande de "corriger la V1", "fix V1", "hotfix", ou mentionne un bug en production/TestFlight.

### Étape A.1 — Préparer l'environnement V1
```bash
# 1. Sauvegarder le travail V2 en cours (si applicable)
git stash push -m "WIP-V2-avant-hotfix-V1"

# 2. Basculer sur main
git checkout main

# 3. S'assurer d'être à jour
git pull origin main

# 4. Vérifier l'état
git status
git log -1 --oneline --decorate
```

### Étape A.2 — Appliquer le correctif
1. Modifier le code nécessaire
2. Exécuter les tests : `xcodebuild test -scheme PiTrainer -destination 'platform=iOS Simulator,name=iPhone 16e' -only-testing:PiTrainerTests`
3. Vérifier que tous les tests passent

### Étape A.3 — Commiter et pusher (avec validation utilisateur)
```bash
git add .
git commit -m "fix(v1): [description du fix]"
git push origin main
```
**⚠️ Ce push déclenche automatiquement Xcode Cloud → TestFlight**

### Étape A.4 — Fournir les preuves (obligatoire)
```bash
git rev-parse HEAD
git ls-remote origin refs/heads/main
# Les deux SHA doivent correspondre
```

### Étape A.5 — Synchroniser V2 avec le fix V1
```bash
# Retourner sur V2
git checkout v2-development

# Récupérer le stash si applicable
git stash pop

# Merger le fix V1 dans V2
git merge main -m "merge: sync V2 with V1 hotfix"
```

---

## 📋 PROCÉDURE B : Développement V2

> **Quand utiliser** : L'utilisateur demande de "travailler sur V2", "nouvelle fonctionnalité", "développement", ou fait référence aux epics/stories V2.

### Étape B.1 — Vérifier la branche courante
```bash
git branch --show-current
```

**Si résultat = `main`** → Basculer sur V2 :
```bash
git checkout v2-development
```

**Si résultat = `v2-development`** → ✅ Continuer

### Étape B.2 — Vérifier si V1 a des changements récents
```bash
git log main --oneline -3
git log v2-development --oneline -3
```

**Si `main` a des commits plus récents que le dernier merge** → Synchroniser d'abord :
```bash
git merge main -m "merge: sync V2 with latest V1"
```

### Étape B.3 — Développer normalement
1. Modifier le code
2. Tester en local (simulateur uniquement)
3. Commiter régulièrement sur `v2-development`

### Étape B.4 — Commiter (avec validation utilisateur)
```bash
git add .
git commit -m "feat(v2): [description]"
```

**Note** : Pas de push obligatoire. Push optionnel vers `origin/v2-development` pour backup (ne déclenche PAS TestFlight).

---

## 📋 PROCÉDURE C : Gérer une interruption V1 pendant le travail V2

> **Quand utiliser** : Tu travailles sur V2 et l'utilisateur demande un fix V1 urgent.

### Étape C.1 — Sauvegarder le travail V2
```bash
# Vérifier les modifications en cours
git status

# Option 1 : Commiter le travail en cours
git add .
git commit -m "wip(v2): sauvegarde avant hotfix V1"

# Option 2 : Stash si pas prêt à commiter
git stash push -m "WIP-V2-interruption-hotfix"
```

### Étape C.2 — Exécuter PROCÉDURE A (Correction V1)

### Étape C.3 — Reprendre le travail V2
```bash
git checkout v2-development
git merge main -m "merge: sync V2 after V1 hotfix"

# Si stash utilisé :
git stash pop
```

---

## 🔒 Règles de sécurité

1. **JAMAIS de push sur `main`** sans validation explicite de l'utilisateur
2. **JAMAIS de merge V2 → main** sans validation utilisateur ET tests complets
3. **TOUJOURS** vérifier la branche courante avant de modifier du code
4. **TOUJOURS** synchroniser V2 après un hotfix V1

## 📊 Commandes de diagnostic rapide

```bash
# Où suis-je ?
git branch --show-current

# État des deux branches
git log main --oneline -1
git log v2-development --oneline -1

# Différences entre V1 et V2
git log main..v2-development --oneline

# Y a-t-il des changements V1 non mergés dans V2 ?
git log v2-development..main --oneline
```
