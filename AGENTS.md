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

## 7) Gestion des branches de développement

### 7.1 Branches protégées (CI/CD actif)
- `main` : Branche de production, déclenche Xcode Cloud → TestFlight
- **Ne jamais pusher directement sur `main`** pendant le développement V2
- Les merges vers `main` doivent être validés et testés

### 7.2 Branches de développement (CI/CD désactivé)
- `v2-development` : Développement V2 en isolation complète
- Aucun push sur cette branche ne déclenche de build TestFlight
- Permet de commiter librement sans impacter les utilisateurs V1

### 7.3 Workflow de développement V2
1. Travailler sur `v2-development`
2. Tester en local (simulateur uniquement)
3. Commiter régulièrement pour traçabilité
4. Optionnel : pusher vers `origin/v2-development` pour backup
5. Merger vers `main` uniquement quand V2 est prête ET V1 validée

### 7.4 Commandes utiles
```bash
# Vérifier la branche courante
git branch --show-current

# Basculer entre branches
git checkout main           # Pour hotfixes V1
git checkout v2-development # Pour développement V2

# Synchroniser V2 avec les derniers changements V1
git checkout v2-development
git merge main
```
