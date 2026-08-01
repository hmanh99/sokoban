# 🧩 Sokoban

A modern implementation of the classic **Sokoban** puzzle game built with **Flutter**.

Push all the boxes onto their target positions while avoiding deadlocks. Every move matters!

## Demo

| Gameplay                         | Level Complete                              | Screens                                 |
|----------------------------------|---------------------------------------------|-----------------------------------------|
| [Gameplay](screenshots/lv20.png) | [Level Complete](screenshots/lv20_win.png)  | [Screens](screenshots/dashboard.png)    |
| [Gameplay](screenshots/lv38.png) | [Level Complete](screenshots/lv38_win.png)  | [Screens](screenshots/select_level.png) |

---

## Features

- 🎮 Classic Sokoban gameplay
- 📦 Multiple handcrafted levels
- ↩️ Undo moves
- 🔄 Restart current level
- ➡️ Next level progression
- 💾 Save game progress
- 📱 Android, iOS, Web, Windows, macOS, Linux support (Flutter)
- ⚡ Smooth animations
- 🏗️ Clean Architecture + BLoC

---

## Game Rules

The objective is simple:

- Push every box (`$`) onto a target (`.`).
- Boxes **cannot be pulled**.
- Only **one box** can be pushed at a time.
- Avoid pushing boxes into corners where they cannot be moved.

### Symbols

| Symbol | Meaning             |
|--------|---------------------|
| `#`    | Wall                |
| `@`    | Player              |
| `$`    | Box                 |
| `.`    | Target              |
| `*`    | Box on Target       |
| `+`    | Player on Target    |
| '` `'   | Floor               |

---

## Controls

| Action     | Control                   |
|------------|---------------------------|
| Move       | Arrow Keys / WASD / Swipe |
| Undo       | Undo Button               |
| Restart    | Restart Button            |
| Next Level | After completing a level  |

---

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── extensions/
│   ├── theme/
│   └── utils/
│
├── data/
│   ├── datasource/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── presentation/
│   ├── bloc/
│   ├── pages/
│   └── widgets/
│
└── main.dart
```

---

## Architecture

The project follows **Clean Architecture** principles.

```
Presentation
      │
      ▼
   Domain
      │
      ▼
     Data
```

State management is implemented using **flutter_bloc**, keeping business logic independent from the UI.

---

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK

Check your environment:

```bash
flutter doctor
```

### Installation

Clone the repository

```bash
git clone https://github.com/hmanh99/sokoban.git
```

Navigate to the project

```bash
cd sokoban
```

Install dependencies

```bash
flutter pub get
```

Run the application

```bash
flutter run
```

---

## Level Format

Levels use the standard Sokoban text format.

Example:

```
#######
#     #
# .$@ #
#  .  #
#######
```
## Dependencies

- flutter_bloc
- go_router
- equatable
- shared_preferences

---


## Acknowledgements

- The original Sokoban game created by Hiroyuki Imabayashi. 
- Flutter
- flutter_bloc
- The Sokoban community for level design inspiration.

---
