# MAMA — Maintenance Manager

> *"MAMA knows best."*

MAMA is een moderne, AI-gedreven CMMS-oplossing (Computerized Maintenance Management System) gebouwd als SaaS-platform. Ontworpen voor bedrijven van elke omvang — van kleine workshops tot grote industriële ondernemingen.

---

## Wat is MAMA?

MAMA helpt bedrijven hun machines, apparatuur en technische installaties professioneel te beheren. Van preventief onderhoud tot storingsregistratie, werkorderbeheer en kwaliteitscontrole — alles in één platform met een strak, Apple-geïnspireerd design.

---

## Kernfuncties

- **Dashboard** — real-time overzicht van machineparken, werkorders en KPI's
- **Werkorderbeheer** — aanmaken, toewijzen en opvolgen van onderhoudsopdrachten
- **Machinebeheer** — assets registreren, status bijhouden, onderhoudshistorie
- **Preventief onderhoud** — onderhoudsschema's plannen en automatisch werkorders aanmaken
- **Storingsmeldingen** — via de gratis token-app direct meldingen insturen
- **Quality Control** — keuringen, inspecties en compliance vastleggen
- **MAMA AI** — ingebouwde AI-assistent die proactief adviseert en werkorders suggereert
- **Power BI integratie** — volledige REST API voor externe dashboards
- **Rapportages** — KPI's zoals MTTR, MTBF, uptime en onderhoudskosten

---

## Kernprincipes & dataregels

> **⚠️ Data mag nooit worden gewist.**

MAMA hanteert een strikte no-delete policy op alle operationele data:

- **Assets worden nooit verwijderd.** Een machine die buiten gebruik gaat, krijgt een nieuwe status (bijv. *Buiten gebruik*, *Afgeschreven*, *Verkocht*). De volledige historie blijft altijd raadpleegbaar.
- **Werkorders worden nooit verwijderd.** Afgeronde en geannuleerde orders blijven zichtbaar in de historie.
- **Storingen worden nooit verwijderd.** Opgeloste storingen krijgen status *Opgelost* met datum en verantwoordelijke.
- **Onderhoudslogboeken zijn onveranderlijk.** Uitgevoerd onderhoud wordt geregistreerd en kan niet worden aangepast — alleen aangevuld.
- **Alle wijzigingen worden gelogd** met tijdstempel en gebruiker (audit trail).

Deze regel geldt voor alle lagen van het systeem: frontend, API en database. Soft-delete (een `deleted_at` veld of statuswijziging) is de enige toegestane manier om data "te verwijderen".

---

## Platform

| Platform | Gebruiker | Beschrijving |
|---|---|---|
| Web (desktop) | Manager / Admin | Volledig beheer, rapportages, planning |
| Tablet (iPad-first) | Monteur op de vloer | Werkorders uitvoeren, checklists, foto's |
| Mobiel (iOS + Android) | Iedereen | Gratis app, token-login, storingen melden |

---

## Abonnementen

| Tier | Prijs | Wat krijg je? |
|---|---|---|
| Free | €0/mnd | Met advertenties, tot 10 assets |
| MAMA+ | €5/mnd | Ad-free, tot 50 assets, basis AI |
| MAMA Pro | €10/mnd | Onbeperkt, volledige AI, Power BI, multi-locatie |
| Enterprise | Op maat | White-label, SLA, SSO, dedicated support |

---

## Power BI & API

MAMA biedt een volledige REST API waarmee externe tools zoals Power BI rechtstreeks verbinding kunnen maken met de MAMA-database.

Beschikbare endpoints (zie `/docs/api.md`):
- `GET /api/assets` — alle assets en status
- `GET /api/workorders` — werkorders met filters
- `GET /api/maintenance` — onderhoudshistorie
- `GET /api/kpis` — KPI's (MTTR, MTBF, uptime, kosten)
- `GET /api/locations` — locaties en machineparken
- Webhooks voor real-time data

---

## Projectstructuur

```
MAMA-CMMS/
├── README.md
├── index.html              ← hoofddashboard
├── assets/
│   ├── css/
│   │   └── mama.css
│   └── js/
│       └── mama.js
├── pages/
│   ├── werkorders.html
│   ├── assets.html
│   ├── storingen.html
│   ├── planning.html
│   └── qc.html
├── app/
│   └── index.html          ← gratis token-app voor monteurs
└── docs/
    └── api.md              ← Power BI API documentatie
```

---

## Bedrijfsstructuur

| Rol | Wie |
|---|---|
| Board / Eigenaar | Leon |
| CEO | AI Agent |
| Development | AI Programmer Agents |
| Quality Control | AI QC Agent |

---

## Roadmap

- [x] Dashboard prototype
- [x] README & projectstructuur
- [ ] Werkorderpagina
- [ ] Asset managementpagina
- [ ] Storingsmeldingen pagina
- [ ] Gratis token-app (monteurs)
- [ ] Quality Control module
- [ ] Power BI API documentatie
- [ ] Backend (Node.js + PostgreSQL)
- [ ] Authenticatie & multi-tenant
- [ ] iOS & Android app (React Native)
- [ ] AI agent integratie

---

## Technische Stack (gepland)

- **Frontend:** HTML, CSS, JavaScript (later React)
- **Backend:** Node.js + Express
- **Database:** PostgreSQL
- **API:** REST + Webhooks
- **AI:** Claude API (Anthropic)
- **Hosting:** TBD
- **Mobile:** React Native

---

## Licentie

© 2026 MAMA – Maintenance Manager. Alle rechten voorbehouden.  
Ontwikkeld door Leon — Board / Eigenaar.
