Inference Pipeline Plan

Goal
- Define a testable, maintainable inference pipeline that produces insights from user data. For the cooking to-do challenge the pipeline should produce:
  - Breakfast/Lunch/Dinner plan
  - Grocery list
  - Substitutions
  - Budget feasibility suggestions

Design overview
- InferenceService responsibilities:
  - Accept structured inputs (user profile, preferences, inventory, budget, day schedule).
  - Run rule-based and simple statistical components to produce outputs.
  - Return typed results that UI can render (e.g., `MealPlan`, `GroceryList`, `SubstitutionSuggestion`).

Inputs
- `UserProfile` (from `lib/models/user_profile.dart`): dietary preferences, allergies, budget
- `Inventory` (optional): list of available ingredients
- `DayContext`: time availability, planned meals, number of people
- `RecipeDB` (static sample or lightweight dataset): simple recipes with ingredients, cost estimates, and prep time

Outputs (typed)
- `MealPlan { breakfast: Recipe, lunch: Recipe, dinner: Recipe }`
- `GroceryList { items: List<GroceryItem>, estimatedCost: double }`
- `SubstitutionSuggestion { original: Ingredient, substitute: Ingredient, reason: String }`
- `BudgetAssessment { feasible: bool, shortfall: double }

Pipeline stages
1. Input normalization: map free-form preferences to internal enums (e.g., vegetarian -> exclude meat).
2. Candidate selection: filter `RecipeDB` by dietary constraints and prep time.
3. Scoring & ranking: score candidates by fit (preference match, time, cost) and pick top items for each meal slot.
4. Grocery generation: union ingredients across selected recipes, subtract inventory, compute cost.
5. Substitution engine: for common missing ingredients, suggest substitutes using a small mapping.
6. Budget check: compare estimated cost to user budget, flag infeasible plans and propose cheaper alternatives.

Testing & Validation
- Unit tests for each stage (normalization, selection, scoring, grocery math, substitution mapping).
- Example test cases:
  - Vegetarian user with low budget -> produces vegetarian mealplan within budget.
  - Missing ingredient -> produces substitution suggestion and updated grocery list.

Implementation notes
- Start with a purely rule-based engine (deterministic and testable).
- Keep `InferenceService` pure (no side effects); accept inputs and return outputs.
- Later iterations can introduce ML components (ranking models) if needed.

File additions recommended
- `lib/services/inference_service.dart` (expand with typed inputs/outputs)
- `lib/models/meal_plan.dart`, `lib/models/grocery_item.dart`, `lib/models/ingredient.dart`
- Unit tests under `test/` for inference logic
