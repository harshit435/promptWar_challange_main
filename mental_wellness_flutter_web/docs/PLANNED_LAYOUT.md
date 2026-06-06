Planned layout (code-first approach)

Purpose
- Define a clear screen/component structure before implementation.

Top-level structure
- `lib/main.dart` — app entry, routes, theme
- `lib/screens/` — screen widgets (Home, EntryForm, Profile, Insights)
- `lib/models/` — data classes (already present)
- `lib/services/` — injection and inference services (already present)
- `lib/widgets/` — reusable UI components (future)

Screen responsibilities
- HomeScreen: list of mood entries, quick add, navigation drawer
- EntryForm: form to add or edit `MoodEntry` (validation + save via InjectionService)
- ProfileScreen: view/edit `UserProfile`
- InsightsScreen: visualization + inference results from `InferenceService`

Navigation
- Use named routes to keep navigation explicit: `/`, `/entry`, `/profile`, `/insights`.

Data flow
- InjectionService: load, save, sample-data loading, persistence abstraction
- InferenceService: analysis functions returning recommendations/insights
- For now use in-memory list + sample JSON; later replace with local storage or backend.

Next steps
- Scaffold screens and basic navigation
- Wire InjectionService for read-only sample data
- Add Entry form UI (save becomes no-op placeholder until persistence added)

Notes
- Keep UI simple and testable; separate concerns (UI vs data vs inference).
