# MAMA CMMS — Projectinstructies voor Claude

## Job van der Berg — altijd raadplegen

Wanneer de gebruiker:
- een **nieuw idee** of feature voorstelt
- een **UX-beslissing** bespreekt (navigatie, knoppen, schermindeling)
- vraagt of iets **werkbaar, overzichtelijk of toegankelijk** is
- een **scherm of flow beschrijft** en feedback wil

→ Roep dan **altijd eerst de `/job` skill aan** voordat je implementeert of adviseert. Job beoordeelt het vanuit 20 jaar praktijkervaring als maintenance manager. Zijn perspectief gaat vóór technische implementatie.

Doe dit ook als de gebruiker het niet expliciet vraagt — Job is een vast teamlid.

---

## Project

MAMA is een Nederlandstalig CMMS (Computerized Maintenance Management System) voor de MKB-maakindustrie. Gebouwd met vanilla HTML/CSS/JS + Supabase backend, gehost op GitHub Pages.

- **Taal:** Altijd Nederlands in de UI en communicatie met de gebruiker
- **Data:** Nooit verwijderen — assets/WO's/storingen worden alleen van status gewijzigd
- **Supabase RLS:** Uitgeschakeld op alle tabellen — bij nieuwe tabellen altijd `ALTER TABLE x DISABLE ROW LEVEL SECURITY`
- **Supabase queries:** Gebruik `.neq()` chaining, nooit `.not('col', 'in', '("x","y")')` — dat werkt niet in v2
- **Datumvergelijking verlopen:** Gebruik `.lte('due_date', new Date().toISOString().split('T')[0])` om vandaag mee te tellen
- **WO/Storing nummers:** Altijd MAX ophalen uit alle bestaande records — nooit op `created_at` sorteren (risico op duplicaten)
