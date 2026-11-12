# Mathe mit Katzen — adaptiv für Android und iOS

Weiterentwicklung von [mathe_lern_app](https://github.com/markosaraf/mathe_lern_app), Markos Maturaprojekt. Das ursprüngliche Repository bleibt unverändert. Diese Version enthält vollständige Flutter-Projekte für Android und iPhone/iPad.

## Was umgesetzt ist

- **Lokale Profile und dauerhafte Lernstände:** Name, Antworten, Fehler, Antwortzeiten, Punkte und Katzen bleiben nach einem Neustart erhalten. Profile können angelegt, gewechselt, umbenannt und gelöscht werden.
- **Adaptive Aufgaben:** Falsch oder langsam beantwortete Aufgaben werden häufiger wiederholt. Bei Schwierigkeiten wird der Zahlenraum im Training vorübergehend kleiner. Die Challenge-Zeit passt sich an die bisherigen Antwortzeiten an.
- **Fortschritt und Statistiken:** Trefferquote, Antwortzeit, Fortschritt je Rechengruppe, Aktivität der letzten sieben Tage und Übungsverlauf.
- **Punkte und Katzenfutter:** Richtige Antworten bringen Punkte. Diese lassen sich für Futter für die freigeschalteten Katzen ausgeben.
- **Alle neun ursprünglichen Gruppen:** Addition, Subtraktion und Multiplikation jeweils bis 10, 20 und 100. Zehn richtige Antworten in Folge innerhalb der Challenge-Zeit schalten die zugehörige Katze frei. Fehlversuche sind nicht begrenzt.
- **Zusätzliche Lernhilfen:** Training ohne Zeitdruck, neun Aufgaben zur ersten Orientierung, empfohlener Lernpfad, kurze Erklärungen und Rückmeldungen. Alle Gruppen bleiben frei wählbar.
- **Deutsch und Englisch**, Touch-Ziffernfeld, Pause und automatische Pause beim Verlassen der App.

Die Zuordnung zu den ursprünglichen Dokumenten und die konkreten Anpassungsregeln stehen in [docs/IMPLEMENTIERUNG.md](docs/IMPLEMENTIERUNG.md).

## Lokal starten

Getestet mit Flutter **3.50.0 stable**, Dart **3.14.0**. Für diese Flutter-Version wird Material über `material_ui` eingebunden. `pubspec.lock` ist eingecheckt.

```sh
flutter pub get
flutter run
```

Android benötigt das Android SDK und eine kompatible Java-Installation. iOS benötigt macOS und Xcode. Die Mindestversionen ergeben sich aus der Android-Konfiguration beziehungsweise iOS 15.0.

```sh
flutter analyze
flutter test
flutter build apk --release
flutter build ios --simulator --debug
flutter build ios --release --no-codesign
```

Die Android-APK liegt unter `build/app/outputs/flutter-apk/app-release.apk`. Sie ist derzeit **zum lokalen Testen mit dem Debug-Schlüssel signiert**, nicht für eine Store-Veröffentlichung. Vor einer Veröffentlichung einen eigenen Upload-Schlüssel einrichten. Ein iOS-Gerätebuild muss vor der Installation mit dem passenden Apple-Team und Provisioning signiert werden. Der Simulator-Build ist nur für den Simulator bestimmt.

Auf dem Entwicklungs-Mac liegt Flutter separat unter `~/development/matura-modern/flutter`. Falls iCloud im Dokumente-Ordner Finder-Metadaten an Frameworks anhängt und Xcode deshalb die Signierung verweigert, das Projekt zum Bauen ausserhalb von iCloud kopieren, zum Beispiel nach `~/development/matura-adaptiv-build`.

## Daten und Datenschutz

Die App funktioniert offline, ohne Konto, Server oder Tracking. Profile sind lokale Lernprofile und nicht passwortgeschützt. Personen mit Zugriff auf dieselbe App können die Profile wechseln. Ein Spitzname genügt.

Die Daten liegen als `learning-v1.json` im privaten Anwendungsdatenverzeichnis. Schreibvorgänge werden nacheinander ausgeführt und atomar ersetzt. Eine lokale Sicherung ermöglicht die Wiederherstellung bei einer beschädigten Datei. Ein Speicherfehler wird in der App angezeigt. Eine Deinstallation kann die lokalen Daten entfernen. Es gibt keine Synchronisierung zwischen Geräten.

## Aufbau

- `lib/domain/learning.dart`: Aufgaben, Lernstatistik, Anpassungsregeln, Übungssitzung
- `lib/data/store.dart`: Profile und lokale Speicherung
- `lib/ui/app.dart`: Lernübersicht, Katzen, Fortschritt und Übungsbildschirm
- `test/`: Verhalten, Speicherung und Bedienabläufe auf Telefon-/Tablet-Grössen
- `android/`, `ios/`: Native App-Projekte
- `lib/images/`: Die ursprünglichen neun Katzenbilder

Die Anpassungsregeln sind nachvollziehbare Heuristiken. Die kurze Einstufung ist eine Orientierung und kein standardisierter Leistungstest.
