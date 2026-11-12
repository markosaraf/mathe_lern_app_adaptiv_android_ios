# Prüfbericht

Stand: 12. November 2026

## Erfolgreich geprüft

- Dart-Formatierung: keine Abweichungen.
- Flutter-Analyse: keine Befunde.
- 13 automatisierte Tests bestanden. Sie prüfen Aufgabengenerierung in allen neun Gruppen, Anpassung anhand von Fehlern und Antwortzeiten, Challenge und einmalige Belohnung, Pausen, Einstufung, Punkte und Futter sowie das Speichern und Wiederherstellen von Lernständen.
- Speichertests umfassen aufeinanderfolgende Schreibvorgänge, einen Neustart mit erneutem Laden und die Wiederherstellung aus einer Sicherungsdatei.
- Bedienablauf im Widget-Test: Profil erstellen, Training beginnen, pausieren, Antwort eingeben, Rückmeldung erhalten und beenden, ohne doppelte Verlaufseinträge.
- Oberfläche und Ziffernfeld in automatisierten Tests mit Telefon- und Tablet-Grössen, einschliesslich 320 × 568 und 1024 × 768.
- Android-Release-APK erfolgreich gebaut.
- iOS-Gerätebuild erfolgreich ohne Codesignierung gebaut.
- iOS-Simulatorbuild erfolgreich gebaut. Der Startbildschirm wurde im iPhone-17e-Simulator gestartet und visuell geprüft.
- Git-Diff auf Formatfehler geprüft. Build-Dateien und lokale Signierschlüssel werden nicht eingecheckt.

## Grenzen der Prüfung

Auf dem Intel-Mac zeigte der Android-Emulator Grafik- und Startprobleme. Die APK konnte installiert werden, ein vollständiger nativer Bedienablauf ist damit noch nicht nachgewiesen. Es erfolgte kein Test auf einem physischen Android-Gerät oder iPhone. Die getesteten Bedienabläufe wurden zusätzlich als Flutter-Widget-Tests ausgeführt.

Die Android-APK verwendet den lokalen Debug-Schlüssel für Testinstallationen. Der iOS-Gerätebuild ist unsigniert und vor einer Geräteinstallation zu signieren. Es wurde keine Store-Einreichung vorgenommen. Praktische Erprobung mit Lernenden und die fachliche Evaluation der adaptiven Schwellenwerte stehen aus.

## Lokale Build-Dateien

Im nicht versionierten Ordner `artifacts/`:

- `Mathe-mit-Katzen-2.0.0-Android-Test.apk`
- `Mathe-mit-Katzen-2.0.0-iOS-Simulator.zip`
- `Mathe-mit-Katzen-2.0.0-iOS-unsigniert.zip`

Die ursprüngliche Matura-Fassung wurde nicht verändert.
