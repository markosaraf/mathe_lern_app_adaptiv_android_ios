# Umsetzung der geplanten Weiterentwicklung

Stand: 12. November 2026

## Grundlage

Massgeblich ist «Adaptive Lernapp - Maturaprojekt Abgabedokument v04a - original - delivered for matura», insbesondere die Abschnitte App-Beschreibung, Adaptivität und Gamification. Ergänzend wurden die Projektplanung und Entwicklungsnotizen berücksichtigt. Die persönlichen Quelldokumente werden nicht ins Repository übernommen.

| Geplanter Schritt | Umsetzung |
| --- | --- |
| Speichern beim Schliessen, Statistik und Fortschritt | Lokale Profile, Speicherung nach jeder Antwort und Profilaktion, Sicherungsdatei, Fortschritt je Gruppe, Antwortzeiten, Aktivität und Verlauf |
| Zeit und Fehler zur Adaptivität nutzen | Gewichtete Wiederholung unsicherer Aufgaben, leichterer Zahlenraum bei Schwierigkeiten, angepasste Challenge-Zeit und Empfehlung der nächsten Gruppe |
| Punkte sammeln und Katzen ernähren | Zwei Punkte pro richtiger Antwort, einmalig zehn Punkte bei einer neu freigeschalteten Katze, fünf Punkte pro Futterportion |
| Mehrere lokale Profile ohne Backend, gemäss Projektplanung | Profilwahl, Anlegen, Umbenennen und Löschen ohne Login oder Netzwerk |
| Englische Fassung, gemäss Entwicklungsnotizen | Umschaltbare deutsche und englische Oberfläche |

Die ursprünglichen neun Gruppen und die Bedingung «zehn korrekte Antworten hintereinander in der gegebenen Zeit» bleiben erhalten. Eine falsche Antwort setzt die Serie zurück, nicht die gesammelten Punkte. Eine bereits freigeschaltete Katze wird nicht erneut als Bonus vergütet.

Training ohne Zeitdruck, kurze Einstufung und Lernempfehlung sind konkrete Ergänzungen, mit denen die geplante Adaptivität zugänglich gemacht wird. Sie waren nicht sämtlich als fertige Bildschirmabläufe im Abgabedokument vorgegeben.

## Anpassungsregeln

1. Jede beantwortete Aufgabe speichert Versuche, richtige Antworten, Gesamtzeit und eine geglättete Antwortzeit. Pausen und das Lesen von Rückmeldungen zählen nicht zur Antwortzeit.
2. Im Training werden mit 60 Prozent Wahrscheinlichkeit bereits unsichere Aufgaben aus derselben Gruppe wiederholt, sofern solche vorhanden sind. Fehler und längere Antwortzeiten erhöhen ihr Gewicht. Die unmittelbar letzte Aufgabe wird dabei ausgeschlossen.
3. Nach mindestens fünf Antworten in einer Gruppe wird der Zahlenraum für neue Trainingsaufgaben halbiert, wenn die Trefferquote unter 60 Prozent oder die durchschnittliche Antwortzeit über 25 Sekunden liegt. Bereits schwierige Aufgaben können weiterhin gezielt wiederkehren.
4. Die Challenge beginnt mit 120 Sekunden. Ab fünf bisherigen Antworten ist die Grenze das Fünfzehnfache der durchschnittlichen Antwortzeit, begrenzt auf 120 bis 240 Sekunden. Challenge und Einstufung verwenden stets den vollständigen Zahlenraum.
5. Eine Gruppe gilt für die Empfehlung als ausreichend geübt, wenn ihre Katze frei ist oder mindestens fünf Antworten, 80 Prozent Trefferquote und höchstens zwölf Sekunden mittlere Antwortzeit vorliegen. Vor grösseren Zahlenräumen werden kleinere vorgeschlagen, vor Subtraktion und Multiplikation die entsprechende Addition. Alle Gruppen sind trotzdem frei zugänglich.
6. Die Einstufung umfasst eine Aufgabe je Gruppe und speichert dieselben Messwerte. Daraus und aus weiterem Üben entsteht die Empfehlung. Neun Antworten allein belegen keine sichere Beherrschung.
7. Das Training endet nach zehn Versuchen. Die Challenge endet bei zehn richtigen Antworten in Folge oder Zeitablauf. Bisherige Antworten und Punkte bleiben auch beim vorzeitigen Beenden gespeichert.

## Bewusste Grenzen

- Keine Online-Rangliste, kein Backend, keine geräteübergreifende Synchronisierung. Das entspricht der späteren Projektplanung für lokale Profile.
- Katzen werden weiterhin durch Challenges freigeschaltet. Punkte bezahlen Futter, kein Echtgeld und keine In-App-Käufe.
- Kein behaupteter Wirksamkeitsnachweis: Schwellenwerte sind überprüfbare Ausgangswerte für praktische Erprobung.
- Keine Store-Einreichung. Android-Tests verwenden eine lokal signierte APK, iOS ist als Xcode-Projekt und Build vorbereitet.
