# MAMA CMMS — To-Do Lijst

_Bijgewerkt: 17 mei 2026_

---

## ✅ Afgerond

| Datum | Item |
|---|---|
| 17 mei 2026 | **SQL-backlog uitgevoerd** — `bedrijf`, `locaties`, `monteurs`, `leveranciers`, `asset_categories`, `storing_activiteiten` tabellen aangemaakt in Supabase |
| 17 mei 2026 | **Locaties-pagina bugfix** — topbar/kaart toonde "Categorieën" i.p.v. "Locaties" |
| 17 mei 2026 | **Medewerkers-pagina bugfix** — Leveranciers-link ontbrak in navigatie |
| 17 mei 2026 | **Actief/inactief toggle** — categorieën, locaties en medewerkers kunnen worden uitgeschakeld zonder verwijdering |
| 17 mei 2026 | **Dropdowns filteren op actief** — categorie en locatie in assets.html, monteurs in werkorders.html; locatie en monteur-dropdowns nu dynamisch (waren hardcoded) |
| 17 mei 2026 | **Verwijderknop conditioneel** — verschijnt alleen als item nergens in gebruik is; pill-stijl gelijk aan actief-toggle |

---

## 🔴 Nu doen — blokkeert bestaande functionaliteit

| # | Item | Status |
|---|---|---|
| 1 | **SQL-backlog uitvoeren in Supabase** — `bedrijf`, `locaties`, `monteurs`, `leveranciers`, `asset_categories`, `storing_activiteiten` tabellen aanmaken | ✅ Klaar |

---

## 🟠 Product — lopende features

| # | Item | Status |
|---|---|---|
| 2 | **Veiligheidsmeldingen op desktop** — nieuwe pagina + dashboard-badge (`safety_reports` tabel bestaat al) | ⬜ Open |
| 3 | **Onderhoud registreren → werkorder aanmaken** — knop in asset-drawer omzetten naar WO-flow met asset pre-ingevuld | ⬜ Open |
| 4 | **WO's filteren per monteur** — dropdown filter op werkorders-pagina | ⬜ Open |
| 5 | **Onderdelen koppelen aan assets** — nieuwe `asset_parts` koppeltabel, zichtbaar in asset-drawer en WO-onderdelen picker | ⬜ Open |
| 6 | **Rapportages module** — MTTR, MTBF, kosten per asset, exporteerbaar (PDF/CSV) | ⬜ Open |
| 7 | **Veiligheidsmeldingen afhandelingsflow** — status + log per melding (niet alleen opslaan, ook opvolging) | ⬜ Open |

---

## 🚀 SaaS — MAMA op de markt brengen

### Fundament (volgorde is dwingend)

| # | Item | Status |
|---|---|---|
| S1 | **Supabase Auth inschakelen** — email/wachtwoord login, basis voor alles wat volgt | ⬜ Open |
| S2 | **`tenants` + `tenant_users` tabel** — bedrijfsregistratie + gebruikersrollen (admin / manager / monteur) | ⬜ Open |
| S3 | **JWT custom claim `tenant_id`** — instellen via Supabase Auth hook zodat RLS werkt | ⬜ Open |
| S4 | **`tenant_id` op alle tabellen + RLS policies** — elke tabel krijgt `tenant_id`, RLS inschakelen per tabel | ⬜ Open |
| S5 | **Login flow** — landingspagina → Supabase Auth → app opent in juiste tenant-sessie | ⬜ Open |

### Landingspagina

| # | Item | Status |
|---|---|---|
| S6 | **Aparte landingspagina** — nieuw GitHub Pages project (bijv. mamacmms.nl) met info, filmpjes, klantlogo's, blog | ⬜ Open |
| S7 | **Demo-aanvraag formulier** — naam, bedrijf, telefoon, aantal assets → e-mailnotificatie naar Leon | ⬜ Open |
| S8 | **Inlogknop prominent bovenaan** — redirect naar app met Supabase Auth sessie | ⬜ Open |
| S9 | **Onboarding flow nieuwe klant** — na aanmelden krijgt nieuwe tenant voorbeelddata (1 asset, 1 WO) zodat ze direct zien hoe het werkt | ⬜ Open |

### Abonnement & beheer

| # | Item | Status |
|---|---|---|
| S10 | **Abonnementsbeheer** — `tenants.abonnement` (trial / starter / pro), `actief` flag, geldigheid; `license_keys` tabel als basis | ⬜ Open |
| S11 | **Tenant admin-paneel** — intern tool voor Leon: klanten beheren, trial verlengen, account blokkeren | ⬜ Open |
| S12 | **Betaalintegratie** — Stripe koppeling voor automatische verlenging abonnement | ⬜ Later |

### Compliance (vóór eerste betalende klant)

| # | Item | Status |
|---|---|---|
| S13 | **Supabase regio instellen op EU (Frankfurt)** — AVG-vereiste voor datalocatie | ⬜ Open |
| S14 | **Verwerkersovereenkomst (DPA)** — juridisch document, klant gaat akkoord bij aanmelden; laat jurist opstellen | ⬜ Open |
| S15 | **Dataretentie bij opzegging** — exportmogelijkheid minimaal 30 dagen na opzegging | ⬜ Open |
| S16 | **Tenant-isolatie penetratietest** — expliciet testen of RLS dicht is, geen data-lekkage tussen tenants | ⬜ Open |

---

## 🔵 Uitgesteld (bewuste keuze)

| # | Item | Reden |
|---|---|---|
| U1 | **Gebruikersrollen & `changed_by` logging** — audit trail per persoon | Wacht op Supabase Auth (S1) |
| U2 | **MAMA Field: QR-scan asset koppeling** | Na auth |
| U3 | **`assigned_to` / `completed_by` als foreign key** | Na gebruikersrollen |
