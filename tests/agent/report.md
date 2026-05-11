Alle 5 modules zijn bekeken. Ik heb voldoende informatie voor een complete evaluatie. Hier volgt het volledige rapport.

---

# MAMA CMMS — Hoogover Evaluatie
**Datum:** 11 mei 2026 | **Evaluator:** Jan Verhoeven, onafhankelijk CMMS-consultant

---

## Eerste indruk & huidige staat

MAMA presenteert zich als een **visueel verzorgd, Nederlandstalig CMMS** in vroeg stadium. De interface is modern, consistent en opgebouwd rond herkenbare CMMS-concepten. Wat opvalt is de aanwezigheid van een **AI-assistent** op het dashboard — dat is ambitieus en weinig gezien bij concurrenten in dit segment. De navigatiestructuur is logisch opgebouwd met de juiste bouwstenen. Als demo/prototype maakt het een serieuze indruk; de data oogt realistisch en geloofwaardig voor een productiebedrijf met meerdere hallen en lijnen.

---

## Aanwezige modules

### 🟢 Dashboard
Sterk. Vier KPI-kaarten (Assets, Werkorders, MTTR, Uptime) direct zichtbaar, aangevuld met actieve werkorders, machinestatus per asset en een uptime-grafiek per locatie. De MAMA AI-banner met contextgevoelig advies ("Compressor C-04 toont afwijkende trilpatronen") is een opvallend differentiërend element. De vermelding van onderhoudskosten (€ 3.840/maand) en monteurs actief (8) geeft een managementlaag die in dit segment niet altijd standaard is.

### 🟢 Assets
Solide basis. Statusoverzicht (42 operationeel / 9 let op / 3 storing) met kleurcodering, locatiefiltering, categorie-filtering en zichtbaarheid van "Volgend onderhoud" inclusief urgentie-signalering in rood/oranje. Import/export-knoppen aanwezig. Wat ontbreekt: de asset-hiërarchie (locatie → systeem → asset → component) is niet zichtbaar in de lijstweergave. Geen aanwijzing voor technische specs, documentopslag of storingshistorie per asset.

### 🟢 Werkorders
Functioneel en overzichtelijk. Vier statussen (Open / In uitvoering / Verlopen / Voltooid), WO-nummering met jaar (WO-2026-XXXX), koppeling naar asset zichtbaar, prioriteitsindicatie (Normaal / Hoog / Kritiek) en toewijzing aan medewerkers aanwezig. Type-indeling (Inspectie / Correctief) is zichtbaar. Wat ontbreekt: preventief/predictief als type, arbeidsuren-registratie, materiaalverbruik per order en een goedkeuringsflow.

### 🟡 Onderhoudsplannen
Aanwezig maar mager uitgewerkt in de lijstweergave. Frequenties (Kwartaals / Halfjaarlijks / Jaarlijks) en geschatte duur in minuten zijn zichtbaar, evenals het aantal taken per plan. Het master-detail layout ("Selecteer een plan om de details te zien") suggereert diepere content achter een klik. Kritiek gemis: er is geen zichtbare koppeling van een plan aan een specifiek asset of asset-groep in de lijstweergave. Ook ontbreekt een kalenderweergave of planningshorizon — essentieel voor preventief onderhoud.

### 🟡 Onderdelen
Verrassend compleet voor een vroeg-stadium product. SKU-nummering, categorie, voorraadniveau met visuele balk, minimumlevel, opslaglocatie tot op rekniveau (Rek A1 Vak 1), prijs en leverancier zijn allemaal aanwezig. Totale voorraadwaarde (€ 5.196,40) direct zichtbaar. Wat ontbreekt: koppeling van onderdelen aan specifieke assets of werkorders, geen bestelworkflow, geen leveranciersmodule en geen ontvangstregistratie (inkomende goederen).

---

## Kritieke ontbrekende functionaliteit

Voor een **werkbaar, productie-rijp CMMS** zijn de volgende elementen nog niet aanwezig of niet zichtbaar:

**1. Asset-hiërarchie en technische stamkaart**
Geen functionele locatieboom (Locatie → Installatie → Asset → Component), geen technische specificaties, geen documentbeheer (P&ID's, handleidingen, certificaten), geen storingshistorie per asset. Dit is het **ruggengraat** van elk CMMS — zonder dit zijn werkorders en onderhoudsplannen zwevend.

**2. Koppeling onderdelen ↔ werkorders ↔ assets**
De drie kernmodules communiceren momenteel niet zichtbaar met elkaar. In een werkend systeem moet een werkorder materiaalverbruik kunnen registreren, moet een asset weten welke reservedelen hem toebehoren, en moet een storingsmelding direct een WO kunnen genereren. Deze **transactionele koppellaag** ontbreekt.

**3. Planning & capaciteitsbeheer**
De navigatie toont "Planning" maar dit is niet geëvalueerd — en de onderhoudsplannen-module mist een kalender/gantt-component. Voor het inplannen van preventief onderhoud over meerdere assets, locaties en monteurs is een planningsmodule onmisbaar. Zonder dit blijft MAMA een registratiesysteem in plaats van een planningssysteem.

**4. Storingen-module**
Zichtbaar in het menu met badge "3" maar niet bezocht (buiten scope). In RCM-context is storingsregistratie met oorzaakanalyse (FMEA/RCA) een kernfunctie. De aanwezigheid van een Storingen-module is positief signaal, maar zonder storingscodering (FMECA-systematiek), oorzaak-gevolg registratie en herhaalstoring-detectie blijft het een logboek.

**5. Gebruikers- en rollenbeheer**
Geen enkel teken van een autorisatiestructuur (monteur / werkvoorbereider / supervisor / manager). In een productieomgeving is dit dag-één-vereiste — een monteur mag geen assets afschrijven, een manager heeft andere dashboardrechten dan een storingsmonteur.

**6. Mobiele interface / veldgebruik**
Niet zichtbaar getest, maar de huidige desktop-layout is niet geoptimaliseerd voor tablet/smartphone gebruik op de werkvloer. In de hedendaagse MRO-praktijk is mobiele WO-afhandeling (QR-scan, foto toevoegen, handtekening) een basisverwachting.

---

## Aanbevolen prioriteiten (top 5)

| # | Prioriteit | Toelichting |
|---|---|---|
| **1** | **Asset-stamkaart uitdiepen** | Voeg technische specs, documentopslag en storingshistorie toe. Zonder dit fundament is de rest van het systeem instabiel. |
| **2** | **Koppeling werkorder ↔ asset ↔ onderdelen activeren** | Materiaalverbruik registreren op WO-niveau en terugkoppelen naar voorraad is de kern van elke CMMS-transactie. |
| **3** | **Planningskalender voor preventief onderhoud** | Zet de onderhoudsplannen om naar concrete WO's op een tijdlijn. Dit is de stap van "plan op papier" naar "plan in uitvoering". |
| **4** | **Gebruikersrollen en autorisaties** | Minimaal 3 rollen (uitvoerder / planner / beheerder) om het systeem veilig in productie te kunnen nemen. |
| **5** | **Mobiele optimalisatie** | Responsieve WO-kaart met QR-koppeling aan asset, fotoregistratie en statuswijziging in het veld. Dit bepaalt dagelijks adoptiegedrag bij monteurs. |

---

## Conclusie & marktpositie

**MAMA is een veelbelovend vroeg-stadium product** met een heldere visuele taal, goede Nederlandse lokalisatie en een ambitieuze AI-positionering die het onderscheidt van generieke CMMS-tools. De vijf kernmodules zijn herkenbaar en logisch gestructureerd — iemand heeft duidelijk nagedacht over wat een CMMS moet zijn.

**De kloof naar een werkbaar systeem** zit niet in de interface maar in de ontbrekende transactionele diepte: assets zonder technische stamkaart, werkorders zonder materiaalregistratie, plannen zonder kalenderintegratie, en modules die nog los van elkaar opereren. Dat is normaal voor dit stadium, maar het zijn ook de zaken die de langste ontwikkeltijd vergen.

**Doelgroep:** MAMA richt zich duidelijk op de **MKB-maakindustrie** (50–500 medewerkers, 1–5 productielocaties), vergelijkbaar met tools als Maintainly, UpKeep en Fiix. Ten opzichte van die concurrenten heeft MAMA een voordeel in Nederlandstaligheid en de AI-laag, maar een achterstand in functiedekking en integratiediepte.

**Mijn advies aan de ontwikkelaar:** focus de komende twee sprints niet op nieuwe modules, maar op het **verbinden van wat er al is**. Een werkorder die een asset kent, een onderdeel verbruikt en een plan uitvoert — dat is de kern. Als die drie ketens kloppen, heb je een MVP waarmee je de eerste echte klanten kunt inboeken. De richting is goed; nu doorpakken op de verbindingen.

---
*Evaluatie uitgevoerd op basis van visuele inspectie van 5 modules. Geen backend-integraties, datamodellen of mobiele weergave getest. Beoordeling geldig als indicatief richtinggevend advies voor vroeg-stadium productontwikkeling.*