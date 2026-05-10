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

-- Extra assets tot 50+
INSERT INTO assets (asset_id, name, model, category, location, status, manufacturer, last_maintenance, next_maintenance, responsible_person) VALUES
('C-05',  'Compressor Lijn 3',           'Atlas Copco GA37',      'Compressor', 'Hal C',        'Operationeel', 'Atlas Copco',  '2026-03-15', '2026-09-15', 'J. de Vries'),
('C-06',  'Compressor Reserve Hal B',    'Kaeser SM 15',          'Compressor', 'Hal B',        'Offline',      'Kaeser',       '2025-11-20', '2026-02-20', 'M. Bakker'),
('C-07',  'Compressor Lijn 4A',          'Atlas Copco GA75',      'Compressor', 'Hal C',        'Operationeel', 'Atlas Copco',  '2026-04-22', '2026-07-22', 'J. de Vries'),
('C-08',  'Compressor Lijn 4B',          'Atlas Copco GA75',      'Compressor', 'Hal C',        'Let op',       'Atlas Copco',  '2026-02-28', '2026-05-28', 'J. de Vries'),
('HP-01', 'Hydrauliekpomp Lijn 1',       'Bosch Rexroth A7V',     'Hydrauliek', 'Hal A',        'Operationeel', 'Bosch Rexroth','2026-04-08', '2026-10-08', 'P. Jansen'),
('HP-02', 'Hydrauliekpomp Lijn 1B',      'Bosch Rexroth A7V',     'Hydrauliek', 'Hal A',        'Operationeel', 'Bosch Rexroth','2026-04-08', '2026-10-08', 'P. Jansen'),
('HP-03', 'Hydrauliekunit Pers 1',       'Parker PV046',          'Hydrauliek', 'Hal A',        'Let op',       'Parker',       '2026-01-30', '2026-04-30', 'P. Jansen'),
('HP-04', 'Hydrauliekunit Pers 2',       'Parker PV046',          'Hydrauliek', 'Hal B',        'Operationeel', 'Parker',       '2026-03-20', '2026-09-20', 'P. Jansen'),
('HP-05', 'Hydrauliekpomp CNC 2',        'Parker VOAC F11',       'Hydrauliek', 'Hal C',        'Operationeel', 'Parker',       '2026-04-01', '2026-10-01', 'P. Jansen'),
('HP-06', 'Hydrauliekunit Spuitgiet',    'Bosch Rexroth A10V',    'Hydrauliek', 'Hal B',        'Storing',      'Bosch Rexroth','2026-01-05', '2026-04-05', 'P. Jansen'),
('V-03',  'Ventilatiesysteem Hal C',     'Systemair DVNI',        'Ventilatie', 'Hal C',        'Operationeel', 'Systemair',    '2026-02-15', '2026-08-15', 'R. Smit'),
('V-04',  'Rookafzuiging Lijn 1',        'Nederman MF-E',         'Ventilatie', 'Hal A',        'Operationeel', 'Nederman',     '2026-03-25', '2026-09-25', 'R. Smit'),
('V-05',  'Rookafzuiging Lijn 2',        'Nederman MF-E',         'Ventilatie', 'Hal B',        'Operationeel', 'Nederman',     '2026-03-25', '2026-09-25', 'R. Smit'),
('V-06',  'Luchtbehandeling kantoor',    'Daikin VRV IV',         'Ventilatie', 'Kantoor',      'Operationeel', 'Daikin',       '2026-01-10', '2027-01-10', 'R. Smit'),
('V-07',  'Overdrukventilatie magazijn', 'Systemair TUNE-S',      'Ventilatie', 'Buitenterrein','Let op',       'Systemair',    '2025-12-01', '2026-03-01', 'R. Smit'),
('TB-03', 'Transportband Lijn 3',        'Hytrol E24',            'Transport',  'Hal C',        'Operationeel', 'Hytrol',       '2026-04-10', '2026-07-10', 'K. van Dam'),
('TB-04', 'Transportband Lijn 4',        'Hytrol E24',            'Transport',  'Hal C',        'In onderhoud', 'Hytrol',       '2026-03-01', '2026-06-01', 'K. van Dam'),
('TB-05', 'Rollenband magazijn in',      'Hytrol TS',             'Transport',  'Buitenterrein','Operationeel', 'Hytrol',       '2026-02-20', '2026-08-20', 'K. van Dam'),
('TB-06', 'Rollenband magazijn uit',     'Hytrol TS',             'Transport',  'Buitenterrein','Operationeel', 'Hytrol',       '2026-02-20', '2026-08-20', 'K. van Dam'),
('TB-07', 'Hefplatform dock 1',          'Stertil ST 1085',       'Transport',  'Buitenterrein','Operationeel', 'Stertil',      '2026-01-15', '2027-01-15', 'K. van Dam'),
('TB-08', 'Hefplatform dock 2',          'Stertil ST 1085',       'Transport',  'Buitenterrein','Let op',       'Stertil',      '2025-10-15', '2026-01-15', 'K. van Dam'),
('EL-03', 'Transformator 1',             'ABB TM315',             'Elektrisch', 'Hal A',        'Operationeel', 'ABB',          '2026-01-20', '2027-01-20', 'R. Smit'),
('EL-04', 'Transformator 2',             'ABB TM315',             'Elektrisch', 'Hal B',        'Operationeel', 'ABB',          '2026-01-20', '2027-01-20', 'R. Smit'),
('EL-05', 'Schakelkast Hal B',           'Schneider XW+',         'Elektrisch', 'Hal B',        'Operationeel', 'Schneider',    '2026-04-15', '2026-10-15', 'R. Smit'),
('EL-06', 'Schakelkast Hal C',           'Schneider XW+',         'Elektrisch', 'Hal C',        'Operationeel', 'Schneider',    '2026-04-15', '2026-10-15', 'R. Smit'),
('EL-07', 'Generator noodstroom',        'Caterpillar C9',        'Elektrisch', 'Buitenterrein','Operationeel', 'Caterpillar',  '2026-03-01', '2026-09-01', 'R. Smit'),
('EL-08', 'Zonnepaneelomvormer 1',       'SMA Sunny Tripower',    'Elektrisch', 'Buitenterrein','Operationeel', 'SMA',          '2026-02-01', '2027-02-01', 'R. Smit'),
('EL-09', 'Zonnepaneelomvormer 2',       'SMA Sunny Tripower',    'Elektrisch', 'Buitenterrein','Operationeel', 'SMA',          '2026-02-01', '2027-02-01', 'R. Smit'),
('KO-03', 'Chiller productie',           'Trane CGAM 30',         'Koeling',    'Buitenterrein','Operationeel', 'Trane',        '2026-04-01', '2026-10-01', 'M. Bakker'),
('KO-04', 'Koelcel grondstoffen',        'Carrier 30RBS',         'Koeling',    'Hal A',        'Operationeel', 'Carrier',      '2026-03-10', '2026-09-10', 'M. Bakker'),
('KO-05', 'Koelcel eindproduct',         'Carrier 30RBS',         'Koeling',    'Hal C',        'Operationeel', 'Carrier',      '2026-03-10', '2026-09-10', 'M. Bakker'),
('KO-06', 'Vrieskist archief',           'Liebherr GTP 2756',     'Koeling',    'Kantoor',      'Operationeel', 'Liebherr',     '2025-12-15', '2026-06-15', 'M. Bakker'),
('KO-07', 'Waterkoeler CNC-centrum',     'Frigel Microgel R',     'Koeling',    'Hal B',        'Let op',       'Frigel',       '2026-02-01', '2026-05-01', 'M. Bakker'),
('HP-10', 'Hydrauliekpomp Lijn 5',       'Bosch Rexroth A10V',    'Hydrauliek', 'Hal A',        'Operationeel', 'Bosch Rexroth','2026-04-12', '2026-10-12', 'P. Jansen'),
('C-09',  'Persluchtdroger Hal A',       'Kaeser TE 141',         'Compressor', 'Hal A',        'Operationeel', 'Kaeser',       '2026-03-05', '2026-09-05', 'J. de Vries'),
('C-10',  'Persluchtdroger Hal B',       'Kaeser TE 141',         'Compressor', 'Hal B',        'Operationeel', 'Kaeser',       '2026-03-05', '2026-09-05', 'M. Bakker'),
('C-11',  'Persluchtdroger Hal C',       'Atlas Copco FD 370',    'Compressor', 'Hal C',        'Buiten gebruik','Atlas Copco', '2024-08-01', null,          'J. de Vries'),
('TB-09', 'Kraan magazijn 5T',           'Stahl CraneSystems',    'Transport',  'Buitenterrein','Operationeel', 'Stahl',        '2026-01-08', '2027-01-08', 'K. van Dam'),
('TB-10', 'Vorklifter elektrisch',       'Toyota 8FBET15',        'Transport',  'Buitenterrein','Operationeel', 'Toyota',       '2026-04-18', '2026-07-18', 'K. van Dam'),
('TB-11', 'Vorklifter diesel',           'Toyota 8FDF15',         'Transport',  'Buitenterrein','Afgeschreven',  'Toyota',       '2023-01-01', null,          'K. van Dam'),
('EL-10', 'Laadpalen elektrisch (4x)',   'Alfen Eve Double',      'Elektrisch', 'Buitenterrein','Operationeel', 'Alfen',        '2026-04-01', '2027-04-01', 'R. Smit'),
('V-08',  'Spuitcabine afzuiging',       'Coral Sprint',          'Ventilatie', 'Hal B',        'Operationeel', 'Coral',        '2026-03-15', '2026-09-15', 'R. Smit')
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

-- Onderdelencatalogus (spare parts)
CREATE TABLE IF NOT EXISTS parts (
  id               uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  part_number      text NOT NULL UNIQUE,
  name             text NOT NULL,
  description      text,
  category         text DEFAULT 'Mechanisch',
  unit             text DEFAULT 'stuk',
  stock_qty        numeric(10,2) DEFAULT 0,
  min_stock        numeric(10,2) DEFAULT 1,
  max_stock        numeric(10,2) DEFAULT 10,
  storage_location text,
  supplier         text,
  supplier_ref     text,
  unit_price       numeric(10,2),
  photo_url        text,
  created_at       timestamptz DEFAULT now()
);

-- Koppeling onderdelen ↔ werkorders (reservering + afboeking)
CREATE TABLE IF NOT EXISTS werkorder_parts (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  wo_id        uuid NOT NULL REFERENCES werkorders(id),
  part_id      uuid NOT NULL REFERENCES parts(id),
  qty_reserved numeric(10,2) DEFAULT 0,
  qty_used     numeric(10,2) DEFAULT 0,
  status       text DEFAULT 'Gereserveerd',
  notes        text,
  created_at   timestamptz DEFAULT now()
);

-- Voorbeelddata onderdelen
INSERT INTO parts (part_number, name, description, category, unit, stock_qty, min_stock, max_stock, storage_location, supplier, supplier_ref, unit_price) VALUES
('OND-0001', 'Oliefilter Atlas Copco GA55',     'Oliefilter voor Atlas Copco GA55 compressor',           'Filter',      'stuk',   8,   3,  15, 'Rek A1 Vak 1', 'Atlas Copco',     'AC-1622-3151',  24.50),
('OND-0002', 'Luchtfilter Atlas Copco GA55',     'Luchtfilter voor GA55/GA75 serie',                      'Filter',      'stuk',   5,   2,  10, 'Rek A1 Vak 2', 'Atlas Copco',     'AC-1614-5714',  31.00),
('OND-0003', 'Separatorfilter Atlas Copco GA55', 'Olie-luchtseparator voor GA55',                         'Filter',      'stuk',   2,   2,   6, 'Rek A1 Vak 3', 'Atlas Copco',     'AC-1614-9073',  89.00),
('OND-0004', 'V-snaar Hytrol E24',               'V-snaar voor transportband Hytrol E24',                 'Mechanisch',  'stuk',   6,   4,  20, 'Rek B2 Vak 1', 'Hytrol',          'HY-E24-VB',     18.75),
('OND-0005', 'Transportband riem 500mm',          'Platte transportband riem 500mm breed per meter',       'Mechanisch',  'meter',  12,  5,  30, 'Rek B2 Vak 2', 'Habasit',         'HB-NNB-15E',    22.40),
('OND-0006', 'Hydrauliekolie HLP 46 (20L)',       'Minerale hydrauliekolie ISO VG 46',                    'Smering',     'liter', 120, 40, 200, 'Opslagruimte',  'Shell',           'SH-TELLUS46',    3.80),
('OND-0007', 'Compressorolie (4L)',               'Synthetische compressorolie Atlas Copco',               'Smering',     'liter',  32, 16,  60, 'Opslagruimte',  'Atlas Copco',     'AC-ROTO-INJECT', 12.90),
('OND-0008', 'Pakking hydrauliekpomp A10V',       'Pakkingset Bosch Rexroth A10V serie',                  'Afdichting',  'set',    3,   2,   8, 'Rek A2 Vak 1', 'Bosch Rexroth',   'BR-R909605642',  67.00),
('OND-0009', 'O-ring set hydrauliek (50 stuks)',  'Assortiment O-ringen NBR voor hydrauliek',             'Afdichting',  'set',    4,   2,   8, 'Rek A2 Vak 2', 'Eriks',           'ER-OR-NBR-50',   28.50),
('OND-0010', 'Lager 6205-2RS',                   'Gesloten kogellager 6205-2RS 25x52x15mm',               'Mechanisch',  'stuk',  10,   4,  20, 'Rek B1 Vak 1', 'SKF',             'SKF-6205-2RS',   14.20),
('OND-0011', 'Lager 6305-2RS',                   'Gesloten kogellager 6305-2RS 25x62x17mm',               'Mechanisch',  'stuk',   7,   3,  15, 'Rek B1 Vak 2', 'SKF',             'SKF-6305-2RS',   19.80),
('OND-0012', 'Lager 6308-2RS',                   'Gesloten kogellager 6308-2RS 40x90x23mm',               'Mechanisch',  'stuk',   4,   2,  10, 'Rek B1 Vak 3', 'SKF',             'SKF-6308-2RS',   34.60),
('OND-0013', 'Koudemiddel R410A (10kg)',          'Koelmiddel R410A cilinder 10kg',                        'Koeling',     'kg',     0,   5,  30, 'Opslagruimte',  'Reftrade',        'RT-R410A-10',    98.00),
('OND-0014', 'Droogmiddelpatroon koeling',        'Droogmiddelpatroon voor Danfoss Optyma',                'Filter',      'stuk',   3,   2,   8, 'Rek A3 Vak 1', 'Danfoss',         'DF-023Z5014',    45.00),
('OND-0015', 'Zekering 63A traag',                'Installatie automaat 63A traag 3-fase',                 'Elektrisch',  'stuk',   6,   2,  12, 'Rek C1 Vak 1', 'Schneider',       'SC-A9N61563',    22.30),
('OND-0016', 'Zekering 32A traag',                'Installatie automaat 32A traag 3-fase',                 'Elektrisch',  'stuk',   8,   3,  15, 'Rek C1 Vak 2', 'Schneider',       'SC-A9N61532',    18.70),
('OND-0017', 'Drukschakelaar 6-10 bar',           'Pressostat / drukschakelaar 6-10 bar aanpasbaar',       'Pneumatisch', 'stuk',   2,   1,   5, 'Rek C2 Vak 1', 'Condor',          'CO-MDR-53',      38.90),
('OND-0018', 'Pneumatisch filter 1/2"',           'FRL eenheid filter 1/2" met waterafscheider',           'Pneumatisch', 'stuk',   3,   1,   6, 'Rek C2 Vak 2', 'Festo',           'FE-LFR-1/2',     54.00),
('OND-0019', 'Hydrauliekslang DN12 (1m)',         'Hoge druk hydrauliekslang DN12 per meter',              'Hydrauliek',  'meter',  15,  5,  30, 'Rek A3 Vak 2', 'Gates',           'GA-HY-DN12',      8.50),
('OND-0020', 'Hydrauliekkoppeling 3/8"',          'Snelkoppeling hydrauliek 3/8" binnendraad',             'Hydrauliek',  'stuk',   8,   3,  15, 'Rek A3 Vak 3', 'Parker',          'PA-SK-3/8F',     12.40),
('OND-0021', 'Thermisch relais 4-6A',             'Motorbeveiliging thermisch relais instelbaar 4-6A',     'Elektrisch',  'stuk',   4,   2,   8, 'Rek C1 Vak 3', 'Schneider',       'SC-LRD10',       29.50),
('OND-0022', 'Contactor 18A 24V',                 '3-fase contactor 18A spoelspanning 24VDC',              'Elektrisch',  'stuk',   5,   2,  10, 'Rek C1 Vak 4', 'Schneider',       'SC-LC1D18BD',    42.80),
('OND-0023', 'Motorolie SAE 10W-40 (5L)',         'Motorolie voor noodaggregaat Caterpillar C9',           'Smering',     'liter',  25, 10,  50, 'Opslagruimte',  'Castrol',         'CA-10W40-5L',     7.20),
('OND-0024', 'Tandwielpomp hydrauliek',           'Tandwielpomp 16cc/omw voor hydrauliekunit',             'Hydrauliek',  'stuk',   1,   1,   3, 'Rek A4 Vak 1', 'Bosch Rexroth',   'BR-0510325022', 285.00),
('OND-0025', 'Drukregelventiel 250 bar',          'Proportioneel drukregelventiel max 250 bar',            'Hydrauliek',  'stuk',   1,   1,   2, 'Rek A4 Vak 2', 'Parker',          'PA-RDBA-LCN',   195.00),
('OND-0026', 'Ventilatormotor 0.75kW',            'Elektromotor 0.75kW 1400rpm IP55',                     'Elektrisch',  'stuk',   2,   1,   4, 'Rek C2 Vak 3', 'WEG',             'WE-W21-075-4',  168.00),
('OND-0027', 'Luchtvering compressor',            'Anti-trillingsdemper rubber 60x60mm M10',               'Mechanisch',  'stuk',  16,   8,  30, 'Rek B3 Vak 1', 'Grayston',        'GR-RB-6060',      6.40),
('OND-0028', 'Patroonfilter perslucht 0.01µm',    'Fijnfilterpatroon voor perslucht nabehandeling',        'Filter',      'stuk',   4,   2,   8, 'Rek A1 Vak 4', 'Donaldson',       'DO-P-SH000',     38.00),
('OND-0029', 'Veiligheidsmembraan 16 bar',        'Breekschijf drukveiligheid 16 bar DN50',                'Pneumatisch', 'stuk',   3,   2,   6, 'Rek C3 Vak 1', 'Rembe',           'RE-KUB-A',       72.00),
('OND-0030', 'Sensorbekabeling M12 5m',           'Aansluitkabel sensor M12 4-polig 5 meter',              'Elektrisch',  'stuk',   0,   3,  15, 'Rek C3 Vak 2', 'Pepperl+Fuchs',   'PE-V1-G-5M',      9.80)
ON CONFLICT (part_number) DO NOTHING;
