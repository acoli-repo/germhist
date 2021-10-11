# ReM Treebank / Baumbank Mittelhochdeutsch, Version 0.1

Die ReM Treebank / Baumbank Mittelhochdeutsch ist ein syntaktisch und semantisch annotiertes Korpus, das auf dem Referenzkorpus Mittelhochdeutsch (ReM), Version 1.0, basiert und dieses erweitert. Das ursprüngliche ReM-Korpus bietet lediglich morphosyntaktische Annotationen und kann [auf den Seiten der Ruhr-Universität Bochum](https://www.linguistics.ruhr-uni-bochum.de/rem/) erworben und angefragt werden.

Die Baumbank enthält:
- [ReM]: sämtliche Texte des ReM, version 1.0, mit deren ursprünglichen Identifikatoren (im Dateinamen)
- [ReM]: Klassifikation der Texte nach Zeitraum (Jahrhundert / Hälfte) und Genre (Prosa / Vers), kodiert in den Dateinamen
- [ReM]: Tokenisierung und ursprüngliche Token-IDs des ReM
- [ReM]: originale morphosyntaktische Annotation des ReM (LEMMA, POS, INFL)
- [Neu]: automatisch generierte Annotation von Nominal-, Präpositional- und Verbphrasen (Chunks)
- [Neu]: automatisch generierte Annotation nach Topologischen Feldern (Vorfeld, Mittelfeld, Nachfeld, Satzklammern)
- [Neu]: automatisch generierte Klassifikation ausgewählter Nomina nach Belebtheit (inanimate, animate, human)

Die Baumbank enthält nicht:
- [ReM]: verschiedene Normalisierungen und der digitalen Edition, die im ReM angeboten werden
- [ReM]: Metadaten der Einzeldateien

Die Baumbank wird in Einzeldateien bereitgestellt, die die Annotationen und den Text jeweils vollständig enthalten, sie ist jedoch nicht als selbstständiges Korpus, sondern als zusätzliche Annotationsebene über das ReM zu sehen, da die notwendigen Metadaten nur auszugsweise bewahrt werden.

## Inhalt

- `conll/` Baumbank Mittelhochdeutsch in einem leicht verarbeitbaren Tabellenformat.
- `ttlchunked/` Baumbank Mittelhochdeutsch in CoNLL-RDF-Format.   
- `orig/` originales ReM v.1.0, beinhaltend die originale Edition in CorA-XML (`orig/rem-corralled-20161222`) und eine daraus erzeugte Darstellung in einem Tabellenformat (`orig/conll`)

Die Dateien unter `conll/` sind die offiziellen Release-Daten.
Die Dateien unter `ttlchunked/` enthalten zusätzlich noch Zwischenschritte der semantischen Annotation (Hyperlemmatisierung, Wörterbuchverknüpfung mit Lexer und Köbler), die teilweise heuristisch erfolgten und aus dem offiziellen Release ausgeschieden wurden, da sie philologischen Ansprüchen wahrscheinlich nicht genügen.

Die CorA-XML-Dateien sind im Repository aufgrund ihrer Größe nicht enthalten. Sie (ebenso wie die daraus abgeleiteten Annotationen) können in einer Linux/Unix-Umgebung wie folgt erzeugt werden:

    $> cd ..
    $> make corpus

## Status und Versionsgeschichte

- Mittelhochdeutsche Baumbank, Version 0.1 (Chiarcos et al., 2018)
  - syntaktische Annotation (Phrasenstruktur, topologische Felder): automatisiert
  - semantische Annotation (Belebtheit): automatisiert
- Referenzkorpus Mittelhochdeutsch, Version 1.0 (Klein et al., 2016)
  - morphosyntaktische Annotation: semiautomatisch

Die existierenden syntaktischen und semantischen Annotationen sind automatisch gewonnen. Wir erwarten, dass künftige Versionen diese Annotationen manuell verifizieren, und dass das Ergebnis dieser Bemühungen durch eine separate Versionsnummer ausgewiesen wird. Solange dies nicht erfolgt, sind die Annotationen nur unter Vorbehalt als zuverlässig zu bewerten, können jedoch als Grundlage von Korpussuche und quantitativen Auswertungen dienen, sofern dabei Art und Natur möglicher Artefakte und Verzerrungen berücksichtigt werden.

Bekannte Artefakte beinhalten:
- `S`, `Cl`: Bei Satz- und Klauselngrenzen folgen wir dem ReM. In älteren Fassungen fehlte die Angrenzung von Klauselgrenzen teilweise und wurde in diesen Fällen von uns auch nicht ergänzt. Statt dessen werden längere ReM-Fragmente, die keine Satz- oder Klauselgrenzen annotieren, als jeweils ein einziger Satz annotiert.
- `NX`, `VX`, etc.: Wir identifizieren Nominal-, Verbal- usw. Phrasen mit heuristischen Regeln. Diese werden daher in der Annotation als "Chunks" (`...X`), nicht als "Phrasen" (`...P`) angesprochen.
- `Frag`-Knoten: Worte oder Phrasen, die nicht in die Satzstruktur integriert werden konnten, sind als `Frag` markiert.
- low attachment: Attachment von Präpositionalphrasen ist meist ambig zwischen low und high attachment. Für Präpositionalphrasen annotieren *wir* durchweg low attachment, d.h., "Er sah den Mann mit dem Fernglas" wird *immer* als "[den Mann [mit dem Fernglas]]" analysiert, *nie* als "sah [den Mann] [mit dem Fernglas]". Dies ist dem Zweck der automatischen Annotation geschuldet, die auf das Studium von Dativ- und Akkusativ-Argumenten abzielte und für die so eine Verkleinerung des Suchraums erreicht werden konnte.

Die mittelhochdeutsche Baumbank enthält den gesamten Textbestand des ReM, mit Ausnahme von 11 
Texten (2.8 % des Gesamtkorpus: `M121K-N1_12-1_V`, `M131-N1_12-2_V`, `M157-G1_12-2_P`, `M199A-G1_12-1_V`, `M213-N1_13-1_V`, `M241y-N1_13-1_V`, `M319-G1_xx-x_x`, `M330-G1_13-1_P`, `M503-N1_13-1_V`, `M510-N0_13-2_V`, `M541H1-N_14-1_V`).
Diese Texte haben TImeouts hervorgerufen, die weiteres Debugging erfordern, möglicherweise jedoch nur Kapazitätsengpässe des Referenzsystems anzeigen.

## Lizenz und Nutzung

Wie das zugrundeliegende Referenzkorpus Mittelhochdeutsch ist die Mittelhochdeutsche Baumbank lizenziert unter einer Creative Commons Namensnennung - Weitergabe unter gleichen Bedingungen 4.0 International Lizenz.

Wenn Sie die Baumbank verwenden, zitieren Sie die Publikation zur Syntaxannotation bitte gemeinsam mit dem ursprünglichen ReM:

* syntaktische Annotation

  Christian Chiarcos, Benjamin Kosmehl, Christian Fäth, Maria Sukhareva (2018), Analyzing Middle High German Syntax with RDF and SPARQL, In: Proceedings of the Eleventh International Conference on Language Resources and Evaluation (LREC 2018), May 2018, Miyazaki, Japan, European Language Resources Association (ELRA), https://aclanthology.org/L18-1717, p. 4525-4534.

* Referenzkorpus Mittelhochdeutsch

    Klein, Thomas; Wegera, Klaus-Peter; Dipper, Stefanie; Wich-Reif, Claudia
    (2016). Referenzkorpus Mittelhochdeutsch (1050–1350), Version 1.0, https://
    www.linguistics.ruhr-uni-bochum.de/rem/. ISLRN 332-536-136-099-5.
