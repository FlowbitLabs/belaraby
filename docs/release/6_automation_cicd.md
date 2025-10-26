## Sample GitHub Actions Workflow

```yaml
name: Deploy to Play Store
on:
  push:
    tags:
      - "v*"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Build App Bundle
        run: flutter build appbundle

      - name: Deploy to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          packageName: com.yourapp.package
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production
```
