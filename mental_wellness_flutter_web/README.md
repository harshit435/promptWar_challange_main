Mental Wellness Tracker — Flutter Web skeleton

Quick start

1. Install Flutter SDK and enable web support: `flutter channel stable && flutter upgrade && flutter config --enable-web`
2. From this folder run:

```bash
flutter pub get
flutter run -d chrome
```

What I created

- Basic `lib/main.dart` app shell
- Data models in `lib/models/`
- Skeleton services in `lib/services/` for injection and inference
- Sample data in `assets/sample_data.json`

Next steps

- Confirm backend / offline persistence choice
- Expand UI and implement analytics/inference logic
