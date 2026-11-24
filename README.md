# SnapSplit

Scan a receipt, check the items, assign them to people and see who owes what.

Flutter (Android) · Google ML Kit OCR · Supabase · Riverpod · go_router.

## Run it

```bash
flutter pub get
flutter run            # on an Android phone with USB debugging on
flutter test           # unit + widget tests
flutter analyze        # must say "No issues found!" before you open a PR
```

The app currently runs on **fake in-memory data** (signed in as a demo user,
with two sample receipts), so every screen works before Supabase is connected.
Camera and ML Kit only work on a real Android phone. Chrome (`flutter run -d chrome`)
is fine for checking layouts.

Screens still showing "Being built by Track …" are placeholders to replace.

## How the code fits together

```
lib/
  main.dart, app.dart     start-up and MaterialApp
  models/                 Receipt, ReceiptItem, Assignment, Person, Category,
                          SplitMethod, AppUser, money helpers
  data/
    repositories.dart     interfaces screens use (Auth, Receipt, People, Category)
    fake/                 in-memory versions + sample data (used until week 2)
    providers.dart        Riverpod providers; Track B swaps fakes for Supabase here
  router/                 every route path (routes.dart) and the bottom nav shell
  theme/                  colours (coral #FF6253, cream #FFFCF3, mint #A8E6CF),
                          Nunito text, button/card/input styles
  widgets/                shared UI (mascot, placeholder screen)
  features/<area>/        one folder per area; each screen is a placeholder for now
assets/branding/logo.webp the mascot
```

- **Reading data in a screen:** `ref.watch(receiptsProvider)` (also `peopleProvider`,
  `categoriesProvider`, `authStateProvider`, `receiptByIdProvider(id)`).
- **Changing data:** `ref.read(receiptRepositoryProvider).save(receipt)`.
- **Navigating:** `context.push(Routes.review)` (with back button) or
  `context.go(Routes.home)` (switch tab). Never type a path string by hand.
- **Replacing a placeholder:** rewrite the screen's `build` with the real UI; keep
  the class name so the router doesn't change.

## Rules that keep the maths right

- Money is **whole cents** (`Cents` = `int`): Rs. 450.50 → `45050`. Never `double`.
  Use `formatRs()` to show it and `parseRs()` to read typed or OCR text.
- Percentages are basis points: 100% = `10000`.
- An item's assignments must add up exactly to its amount; leftover cents go to
  the first person.

## Git workflow

1. `git checkout -b feature/scan-screen` (one branch per feature)
2. Commit small, push, open a pull request into `main`
3. One other member reviews it; merge when `flutter analyze` and `flutter test` pass

Never commit Supabase keys. They go in `env/dev.json`, which git ignores.
