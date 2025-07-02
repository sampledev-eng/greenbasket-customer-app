# greenbasket

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Steps for flutter:
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter

echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

$HOME/flutter/bin/flutter --version

flutter doctor

flutter build web -v
flutter clean
flutter pub get
flutter build web


cd ~/workspaces/greenbasket-customer-app   # adjust path
flutter pub get
flutter build web


cd build/web
python3 -m http.server 8080

flutter upgrade

python3 -m http.server 8080
