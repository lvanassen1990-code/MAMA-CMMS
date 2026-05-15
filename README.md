# MAMA — Maintenance Manager

> *"MAMA knows best."*

MAMA is een moderne, Nederlandstalig CMMS-platform (Computerized Maintenance Management System) gebouwd als SaaS. Ontworpen voor de MKB-maakindustrie — van kleine werkplaatsen tot multi-locatie productiebedrijven.

---

## Modules

| Module | Status | Beschrijving |
|---|---|---|
| **Dashboard** | ✅ Live | KPI's, machinestatus, AI-assistent, uptime-grafiek |
| **Assets** | ✅ Live | Assetbeheer, stamkaart, asset hiërarchie (parent/child boom), drag & drop koppelmodus |
| **Werkorders** | ✅ Live | WO-beheer met prioriteit, type, onderdelen, statusflow |
| **Planning** | ✅ Live | Maand/week kalender met WO's en onderhoudsplannen |
| **Storingen** | ✅ Live | Storingsregistratie, oorzaakanalyse, MTTR, herhaaldetectie, WO-koppeling |
| **Onderhoudsplannen** | ✅ Live | Preventieve plannen, auto WO-generatie, actief/inactief toggle |
| **Onderdelen** | ✅ Live | Voorraadmodule met SKU, min/max stock, reservering, afboeking |
| **Quality Control** | ✅ Live | Keuringen en inspecties |
| **MAMA Field** | ✅ Live | Mobiele PWA voor monteurs op de werkvloer |

---

## MAMA Field (mobiele app)

Gratis installeerbare PWA voor monteurs. Geen individuele login — toegang via een bedrijfsgebonden licentiesleutel.

**URL:** `https://lvanassen1990-code.github.io/MAMA-CMMS/mama-field/`  
**QR-pagina:** `https://lvanassen1990-code.github.io/MAMA-CMMS/mama-field/qr.html`

**Functies:**
- 🔴 Storing melden (foto + asset + prioriteit + automatische herhaaldetectie)
- ⚠️ Veiligheidsmelding (foto + locatie + risiconiveau)
- 📷 Foto toevoegen aan werkorder of asset
- Installeerbaar op Android en iOS via "Voeg toe aan beginscherm"

**Licentiesleutels** worden beheerd in de Supabase `license_keys` tabel. Elke klant krijgt één sleutel — alle medewerkers gebruiken dezelfde sleutel op hun eigen toestel.

---

## Kernprincipes & dataregels

> **⚠️ Data mag nooit worden gewist.**

- **Assets** worden nooit verwijderd — alleen van status gewijzigd
- **Werkorders** worden nooit verwijderd — geannuleerd = status "Geannuleerd"
- **Storingen** worden nooit verwijderd — afgesloten = status "Opgelost"
- **WO-nummers** zijn oplopend en uniek, nooit hergebruikt (`WO-YYYY-XXXX`)
- **Storingnummers** zijn oplopend en uniek (`ST-YYYY-XXXX`)
- **Veiligheidsmeldingen** zijn oplopend en uniek (`VV-YYYY-XXXX`)

---

## Projectstructuur

```
MAMA-CMMS/
├── index.html                  ← Dashboard
├── assets/
│   ├── mama.css                ← Gedeeld design system
│   └── logo-mark.svg
├── pages/
│   ├── assets.html             ← Assetbeheer + stamkaart drawer
│   ├── werkorders.html         ← Werkorderbeheer + onderdelen
│   ├── planning.html           ← Maand/week kalender
│   ├── storingen.html          ← Storingsmodule
│   ├── onderhoudsplannen.html  ← Preventief onderhoud
│   ├── onderdelen.html         ← Voorraadmodule
│   └── qc.html                 ← Quality Control
├── mama-field/
│   ├── index.html              ← Mobiele PWA (licentiesleutel + meldingen)
│   ├── manifest.json           ← PWA manifest
│   ├── sw.js                   ← Service worker (offline support)
│   └── qr.html                 ← QR-code afdrukpagina
└── tests/
    └── agent/
        ├── cmms-tester.js      ← AI Playwright tester agent
        ├── tools.js            ← Playwright tool-definities
        └── report.md           ← Gegenereerd consultancy rapport
```

---

## Technische stack

| Laag | Technologie |
|---|---|
| Frontend | Vanilla HTML / CSS / JavaScript |
| Design system | `mama.css` — Apple-geïnspireerde tokens |
| Backend | Supabase (PostgreSQL + Storage + RLS) |
| Hosting | GitHub Pages |
| AI | Claude API (Anthropic) — dashboard assistent + Playwright tester |
| Mobiel | PWA (installeerbaar, geen app store) |

---

## Database tabellen (Supabase)

| Tabel | Beschrijving |
|---|---|
| `assets` | Machines en installaties (incl. `parent_id` voor hiërarchie) |
| `werkorders` | Onderhoudsopdrachten |
| `maintenance_plans` | Preventieve onderhoudsplannen |
| `asset_maintenance_plans` | Koppeling asset ↔ plan |
| `parts` | Onderdelenmagazijn |
| `werkorder_parts` | Onderdelen per werkorder |
| `storingen` | Storingsregistratie |
| `safety_reports` | Veiligheidsmeldingen (via Field app) |
| `license_keys` | Bedrijfssleutels voor MAMA Field |

---

## Roadmap

### Afgerond ✅
- [x] Dashboard met KPI's en AI-assistent
- [x] Assetbeheer met technische stamkaart (specs, docs, storingshistorie)
- [x] Werkorderbeheer met onderdelen en statusflow
- [x] Onderhoudsplannen met auto WO-generatie
- [x] Voorraadmodule (onderdelen, reservering, afboeking)
- [x] Storingsmodule (oorzaakanalyse, MTTR, herhaaldetectie)
- [x] Planningskalender (maand/week)
- [x] MAMA Field mobiele PWA
- [x] Licentiesleutelsysteem voor Field app
- [x] Foto upload via Field app (Supabase Storage)
- [x] AI Playwright tester agent (consultancy rapport)
- [x] Dynamische sidebar badges (verlopen WO's + open storingen, alle pagina's)
- [x] Asset hiërarchie — parent/child boom, uitklap/inklap, sub-assets tab in drawer
- [x] Drag & drop koppelmodus — assets visueel koppelen/loskoppelen via slepen
- [x] Edge-detectie op kaarten — rand = loskoppelen, midden = koppelen

### Gepland 🔜
- [ ] Veiligheidsmeldingen zichtbaar in MAMA desktop
- [ ] Gebruikersrollen & autorisaties (Supabase Auth)
- [ ] Mobiele CSS optimalisatie desktop-app
- [ ] MAMA Field: QR-scan asset koppeling
- [ ] Rapportages module (MTTR, MTBF, kosten)
- [ ] Power BI API integratie

---

## Bedrijfsstructuur

| Rol | Wie |
|---|---|
| Board / Eigenaar | Leon |
| Development | Claude (Anthropic) |

---

## Licentie

© 2026 MAMA – Maintenance Manager. Alle rechten voorbehouden.
