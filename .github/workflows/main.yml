name: Flutter APK Yapici
on:
  push:
    branches: [ "main", "master" ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        channel: 'stable'
    - name: Android Iskeletini Kur
      run: flutter create sahih_din_app
    - name: Eski Dosyalari Sil
      run: rm -rf sahih_din_app/lib
    - name: Bizim Kodlari Tasi
      run: |
        cp -r lib sahih_din_app/
        cp pubspec.yaml sahih_din_app/
    - name: APK Uret
      run: |
        cd sahih_din_app
        flutter pub get
        flutter build apk --release
    - name: APK'yi Indirmeye Hazirla
      uses: actions/upload-artifact@v3
      with:
        name: Sahih_Din_Oyunu
        path: sahih_din_app/build/app/outputs/flutter-apk/app-release.apk
