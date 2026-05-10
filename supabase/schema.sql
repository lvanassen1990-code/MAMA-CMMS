-- MAMA CMMS - Database schema
-- Voer dit uit in Supabase: SQL Editor → New query → plak dit → Run

CREATE TABLE IF NOT EXISTS assets (
  id                  uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id            text NOT NULL UNIQUE,
  name                text NOT NULL,
  model               text,
  category            text,
  location            text,
  status              text DEFAULT 'Operationeel',
  manufacturer        text,
  serial_number       text,
  installation_date   date,
  last_maintenance    date,
  next_maintenance    date,
  responsible_person  text,
  notes               text,
  photo_url           text,
  created_at          timestamptz DEFAULT now()
);

-- Foto-opslag bucket (eenmalig aanmaken)
INSERT INTO storage.buckets (id, name, public)
VALUES ('asset-photos', 'asset-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Iedereen mag foto's lezen (public bucket)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public read asset photos') THEN
    CREATE POLICY "Public read asset photos"
    ON storage.objects FOR SELECT USING (bucket_id = 'asset-photos');
  END IF;
END $$;

-- Iedereen mag foto's uploaden (pas later beperken met auth)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public upload asset photos') THEN
    CREATE POLICY "Public upload asset photos"
    ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'asset-photos');
  END IF;
END $$;

-- ── Onderhoudsplannen ──────────────────────────────────────────
-- Een plan is een herbruikbare template met taken en interval.
-- Het kan aan meerdere assets gekoppeld worden.

CREATE TABLE IF NOT EXISTS maintenance_plans (
  id                  uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name                text NOT NULL,
  description         text,
  interval_type       text NOT NULL DEFAULT 'Kwartaal',
  interval_days       int  NOT NULL DEFAULT 90,
  estimated_duration  int,                      -- in minuten
  created_at          timestamptz DEFAULT now()
);

-- Taken binnen een plan (geordende checklist)
CREATE TABLE IF NOT EXISTS maintenance_tasks (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  plan_id     uuid NOT NULL REFERENCES maintenance_plans(id) ON DELETE CASCADE,
  order_nr    int  NOT NULL DEFAULT 0,
  description text NOT NULL
);

-- Koppeling: welk plan hoort bij welk asset
CREATE TABLE IF NOT EXISTS asset_maintenance_plans (
  id              uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id        text NOT NULL REFERENCES assets(asset_id) ON DELETE CASCADE,
  plan_id         uuid NOT NULL REFERENCES maintenance_plans(id) ON DELETE CASCADE,
  assigned_to     text,
  last_executed   date,
  next_due        date,
  active          boolean DEFAULT true,
  created_at      timestamptz DEFAULT now(),
  UNIQUE (asset_id, plan_id)
);

-- Voorbeeldplannen
INSERT INTO maintenance_plans (id, name, description, interval_type, interval_days, estimated_duration) VALUES
('00000000-0000-0000-0000-000000000001', 'Maandelijkse inspectie',     'Visuele controle en smering',              'Maandelijks',    30,  60),
('00000000-0000-0000-0000-000000000002', 'Kwartaal groot onderhoud',   'Filters, riemen, vloeistoffen controleren', 'Kwartaal',       90, 180),
('00000000-0000-0000-0000-000000000003', 'Jaarlijkse revisie',         'Volledige revisie en keuring',              'Jaarlijks',     365, 480),
('00000000-0000-0000-0000-000000000004', 'Wekelijkse veiligheidscheck','Noodstop, beveiliging en alarmen testen',   'Wekelijks',       7,  30)
ON CONFLICT (id) DO NOTHING;

-- Taken per plan
INSERT INTO maintenance_tasks (plan_id, order_nr, description) VALUES
('00000000-0000-0000-0000-000000000001', 1, 'Visuele inspectie op lekkages'),
('00000000-0000-0000-0000-000000000001', 2, 'Smering lagerpunten controleren'),
('00000000-0000-0000-0000-000000000001', 3, 'Geluids- en trillingsniveau noteren'),
('00000000-0000-0000-0000-000000000002', 1, 'Luchtfilter reinigen of vervangen'),
('00000000-0000-0000-0000-000000000002', 2, 'Riemspanning controleren'),
('00000000-0000-0000-0000-000000000002', 3, 'Koelvloeistofpeil controleren'),
('00000000-0000-0000-0000-000000000002', 4, 'Veiligheidskleppen testen'),
('00000000-0000-0000-0000-000000000002', 5, 'Meetwaarden loggen in systeem'),
('00000000-0000-0000-0000-000000000003', 1, 'Volledige demontage en reiniging'),
('00000000-0000-0000-0000-000000000003', 2, 'Slijtageonderdelen vervangen'),
('00000000-0000-0000-0000-000000000003', 3, 'Electrische aansluitingen controleren'),
('00000000-0000-0000-0000-000000000003', 4, 'Eindkeuring en testrun uitvoeren'),
('00000000-0000-0000-0000-000000000004', 1, 'Noodstopknoppen testen'),
('00000000-0000-0000-0000-000000000004', 2, 'Alarmmelding simuleren'),
('00000000-0000-0000-0000-000000000004', 3, 'Beveiligingskappen controleren')
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS werkorders (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  wo_number   text NOT NULL UNIQUE,
  description text NOT NULL,
  asset_id    text REFERENCES assets(asset_id),
  status      text DEFAULT 'Open',
  priority    text DEFAULT 'Normaal',
  assigned_to text,
  due_date    date,
  completed_at timestamptz,
  created_at  timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS storingen (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id     text REFERENCES assets(asset_id),
  description  text NOT NULL,
  reported_by  text,
  status       text DEFAULT 'Open',
  resolved_at  timestamptz,
  created_at   timestamptz DEFAULT now()
);

-- Voorbeelddata
INSERT INTO assets (asset_id, name, model, category, location, status, manufacturer, last_maintenance, next_maintenance, responsible_person) VALUES
('C-01',  'Compressor Noord',         'Atlas Copco GA55',      'Compressor', 'Hal A',        'Operationeel', 'Atlas Copco',       '2026-04-10', '2026-07-10', 'J. de Vries'),
('C-02',  'Compressor Zuid',          'Atlas Copco GA55',      'Compressor', 'Hal A',        'Operationeel', 'Atlas Copco',       '2026-03-22', '2026-06-22', 'J. de Vries'),
('C-03',  'Compressor Lijn 2',        'Kaeser SK 25',          'Compressor', 'Hal B',        'Operationeel', 'Kaeser',            '2026-04-01', '2026-07-01', 'M. Bakker'),
('C-04',  'Compressor Lijn 2B',       'Kaeser SK 25',          'Compressor', 'Hal B',        'Let op',       'Kaeser',            '2026-02-15', '2026-05-15', 'M. Bakker'),
('HP-07', 'Hydrauliekpomp Lijn 3',    'Bosch Rexroth A10V',    'Hydrauliek', 'Hal C',        'Storing',      'Bosch Rexroth',     '2026-01-20', '2026-04-20', 'P. Jansen'),
('HP-08', 'Hydrauliekpomp Reserve',   'Bosch Rexroth A10V',    'Hydrauliek', 'Hal C',        'Operationeel', 'Bosch Rexroth',     '2026-04-05', '2026-10-05', 'P. Jansen'),
('V-01',  'Ventilatiesysteem Hal A',  'Systemair MUB',         'Ventilatie', 'Hal A',        'Operationeel', 'Systemair',         '2026-03-10', '2026-09-10', 'R. Smit'),
('V-02',  'Ventilatiesysteem Hal B',  'Systemair MUB',         'Ventilatie', 'Hal B',        'Operationeel', 'Systemair',         '2026-03-10', '2026-09-10', 'R. Smit'),
('TB-01', 'Transportband Lijn 1',     'Hytrol E24',            'Transport',  'Hal A',        'Operationeel', 'Hytrol',            '2026-04-20', '2026-07-20', 'K. van Dam'),
('TB-02', 'Transportband Lijn 2',     'Hytrol E24',            'Transport',  'Hal B',        'Let op',       'Hytrol',            '2026-02-01', '2026-05-01', 'K. van Dam'),
('EL-01', 'Schakelkast Hal A',        'Schneider XW+',         'Elektrisch', 'Hal A',        'Operationeel', 'Schneider',         '2026-04-15', '2026-10-15', 'R. Smit'),
('KO-01', 'Koelunit productielijn',   'Danfoss Optyma',        'Koeling',    'Hal C',        'Let op',       'Danfoss',           '2026-03-05', '2026-06-05', 'M. Bakker'),
('KO-02', 'Koelunit magazijn',        'Danfoss Optyma',        'Koeling',    'Buitenterrein','Operationeel', 'Danfoss',           '2026-04-18', '2026-10-18', 'M. Bakker'),
('HP-09', 'Hydrauliekunit CNC',       'Parker VOAC',           'Hydrauliek', 'Hal B',        'Storing',      'Parker',            '2026-01-10', '2026-04-10', 'P. Jansen'),
('EL-02', 'UPS Systeem kantoor',      'APC Smart-UPS',         'Elektrisch', 'Kantoor',      'Operationeel', 'APC',               '2026-04-01', '2026-10-01', 'R. Smit')
ON CONFLICT (asset_id) DO NOTHING;
