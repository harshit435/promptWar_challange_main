Implementation plan (high-level)

1) Scaffold
- Add `lib/screens/` with `home_screen.dart`, `entry_form.dart`, `profile_screen.dart`, `insights_screen.dart`.
- Update `lib/main.dart` to use named routes and `HomeScreen`.

2) Data wiring
- Use `InjectionService` to load sample data into `HomeScreen` for now.
- Add simple in-memory add function in `EntryForm` to push a new `MoodEntry` to `HomeScreen`.

3) Inference
- Keep `InferenceService` as a stateless utility returning insights from a list of `MoodEntry`.
- Implement simple rules (average mood, frequent triggers) in a later iteration.

4) Persistence
- Add persistence (SharedPreferences / local file) after UI+inference validated.

5) Tests & audit
- Unit tests for model serialization and inference rules.
- Manual QA checklist and gap audit.

6) Evaluation criteria mapping
- Map implementation milestones to the platform code assessment signals (Code Quality, Security, Efficiency, Testing, Accessibility, Problem Statement Alignment).
- For each milestone, add concrete checks (linters, unit tests, accessibility smoke tests, performance measurements) so the automated platform can score reliably.

Example mapping (per milestone):
- M1 (Navigation + Home list): Code quality (lint), Accessibility (semantics checks for list items), Problem Alignment (home lists entries from sample data).
- M2 (Entry form): Testing (form validation unit tests), Accessibility (labels, focus), Security (input sanitization checks).
- M3 (Profile): Data correctness tests, Privacy notes in README (problem alignment).
- M4 (Inference): Unit tests for inference rules, efficiency benchmarks (simple dataset), documentation mapping inference inputs/outputs.
- M5 (Persistence + tests): End-to-end tests, data integrity checks, CI linting, and build verification.

Next steps (short-term):
- Add `docs/EVALUATION_CHECKLIST.md` linking concrete tools and commands to each signal.
- Draft `docs/INFERENCE_PLAN.md` describing inputs/outputs, rule examples, and test cases.

Milestones (short iterations)
- M1: Navigation + Home list (done after scaffolding)
- M2: Entry form + add entry flow
- M3: Profile view + edit
- M4: Basic inference endpoints + insights screen
- M5: Persistence + tests + audit
