# Project Documentation Index - pi-trainer

Welcome to the comprehensive documentation for `pi-trainer`. This documentation set provides a detailed overview of the project's architecture, patterns, and implementation details, optimized for both human developers and AI assistants.

## 📊 Quick Reference

- **Project Name:** pi-trainer
- **Language:** Swift (iOS 17+)
- **Architecture:** Feature-Sliced MVVM + `@Observable`
- **Primary Domain:** Mobile / Memory Athletics

---

## 📂 Documentation Set

### [Project Overview](./project-overview.md)
Start here for a high-level executive summary, key value propositions, and a feature inventory of the v2 platform.

### [Architecture Guide](./architecture.md)
Detailed breakdown of the MVVM structure, the `PracticeEngine` logic, and the high-performance `GhostEngine` implementation.

### [Source Tree Analysis](./source-tree-analysis.md)
An annotated guide to the directory structure and critical files, explaining the purpose of each layer in the feature-sliced architecture.

### [Data Models](./data-models-root.md)
Explanations of the persistence models (`PersonalBestRecord`, `SessionRecord`) and the hybrid storage strategy using `UserDefaults` and JSON.

### [Component Inventory](./component-inventory-root.md)
A catalog of UI components (ProPad, TerminalGrid) and core logic services (HapticService, StatsStore).

### [Development Guide](./development-guide.md)
Prerequisites, environment setup, build instructions, and testing strategies for the iOS platform.

---

## 🏁 Getting Started

If you are new to the project or starting a new feature branch:
1. Review the **[Architecture Guide](./architecture.md)** to understand the observation and persistence patterns.
2. Check the **[Development Guide](./development-guide.md)** for setup and testing commands.
3. Consult **[project-context.md](../../project-context.md)** for critical V2-specific rules.

---
*Documentation generated on 2026-01-23*
