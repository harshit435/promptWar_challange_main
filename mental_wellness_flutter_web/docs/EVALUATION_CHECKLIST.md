Evaluation Checklist — mapped to platform scoring signals

Purpose
- Provide concrete, actionable checks that map to the platform's automated code assessment signals: Code Quality, Security, Efficiency, Testing, Accessibility, Problem Statement Alignment.

How to use
- Each milestone should include the checks below. Add CI steps to run these commands so the platform can score automatically.

Checks
- Code Quality
  - Run `flutter analyze` and address all warnings/errors.
  - Enforce formatting with `dart format`.
  - Add linter rules in `analysis_options.yaml` (already present).

- Security
  - Avoid logging sensitive information. Review code for plaintext secrets.
  - Validate and sanitize user inputs in forms.
  - Document data handling in `README.md`.

- Efficiency
  - Basic benchmark: measure app cold start time and list render time (manual measurement or widget test with timing).
  - Avoid unnecessary rebuilds (use const widgets where applicable).

- Testing
  - Add unit tests for model serialization/deserialization.
  - Add widget tests for `EntryForm` validation and `HomeScreen` list rendering.
  - Add a small test for `InferenceService` logic (rules correctness).

- Accessibility
  - Ensure all interactive widgets have semantic labels (buttons, form fields).
  - Test with Flutter's accessibility tools and ensure contrast/readability.

- Problem Statement Alignment
  - Provide a short README section mapping app features to the challenge requirements (meal planning outputs: plans, grocery list, substitutions, budget logic).

CI Suggestions
- Create a GitHub Actions workflow that runs:
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test`
  - Optional: a small integration test run for web-server build.

Deliverables to add
- `docs/EVALUATION_CHECKLIST.md` (this file)
- A short README section: "Evaluation mapping"
- Basic CI workflow: `.github/workflows/ci.yml` (optional next step)
