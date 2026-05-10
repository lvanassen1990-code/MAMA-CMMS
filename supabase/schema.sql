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

CREATE TABLE IF NOT EXISTS werkorders (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  wo_number    text NOT NULL UNIQUE,
  description  text NOT NULL,
  asset_id     text REFERENCES assets(asset_id),
  wo_type      text DEFAULT 'Correctief',
  status       text DEFAULT 'Open',
  priority     text DEFAULT 'Normaal',
  assigned_to  text,
  due_date     date,
  notes        text,
  completed_at timestamptz,
  created_at   timestamptz DEFAULT now()
);

-- Voorbeelddata werkorders
INSERT INTO werkorders (wo_number, description, asset_id, wo_type, status, priority, assigned_to, due_date, notes) VALUES
('WO-2026-0001', 'Periodieke oliewissel en filtervervanging',  'C-01',  'Preventief',  'Open',          'Normaal', 'J. de Vries', '2026-05-20', null),
('WO-2026-0002', 'Storing hydrauliekpomp onderzoeken',         'HP-07', 'Correctief',  'In uitvoering', 'Hoog',    'P. Jansen',   '2026-05-12', 'Drukval gemeten op circuit B'),
('WO-2026-0003', 'Jaarlijkse ventilatiecontrole Hal A',        'V-01',  'Inspectie',   'Open',          'Normaal', 'R. Smit',     '2026-06-01', null),
('WO-2026-0004', 'V-snaar vervangen transportband lijn 2',     'TB-02', 'Correctief',  'Open',          'Hoog',    'K. van Dam',  '2026-05-15', 'Let op! Snaar vertoont scheuren'),
('WO-2026-0005', 'Koeling productielijn bijvullen koudemiddel','KO-01', 'Correctief',  'In uitvoering', 'Normaal', 'M. Bakker',   '2026-05-18', null),
('WO-2026-0006', 'Hydrauliekunit CNC spoelen en testen',       'HP-09', 'Correctief',  'Open',          'Kritiek', 'P. Jansen',   '2026-05-11', 'Machine ligt stil wegens lekkage'),
('WO-2026-0007', 'UPS batterijtest en capaciteitsmeting',      'EL-02', 'Inspectie',   'Voltooid',      'Laag',    'R. Smit',     '2026-05-05', null),
('WO-2026-0008', 'Compressor lijn 2B naregelen drukinstelling','C-04',  'Correctief',  'Open',          'Normaal', 'M. Bakker',   '2026-05-19', null)
ON CONFLICT (wo_number) DO NOTHING;

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

-- Onderhoudshistorie per asset (onveranderlijk logboek)
CREATE TABLE IF NOT EXISTS maintenance_history (
  id               uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_id         text NOT NULL REFERENCES assets(asset_id),
  date             date NOT NULL,
  maintenance_type text DEFAULT 'Preventief',
  description      text NOT NULL,
  technician       text,
  parts_used       text,
  cost             numeric(10,2),
  created_at       timestamptz DEFAULT now()
);
