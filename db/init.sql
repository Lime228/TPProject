-- init_db.sql
-- Ïîëíàÿ èíèöèàëèçàöèÿ áàçû äàííûõ ñ îáðàáîòêîé îøèáîê

-- Óñòàíàâëèâàåì ïàðàìåòðû äëÿ ÷èñòîãî âûïîëíåíèÿ
SET client_min_messages TO WARNING;
\set ON_ERROR_STOP on

-- Ñîçäàåì ïîëüçîâàòåëÿ åñëè íå ñóùåñòâóåò
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'zadachok') THEN
    CREATE ROLE zadachok WITH LOGIN PASSWORD 'zadachok';
  ELSE
    ALTER ROLE zadachok WITH PASSWORD 'zadachok';
  END IF;
END
$$;

-- Ñîçäàåì áàçó äàííûõ åñëè íå ñóùåñòâóåò
SELECT 'CREATE DATABASE zadachok_db WITH OWNER zadachok ENCODING ''UTF8'' LC_COLLATE ''en_US.utf8'' LC_CTYPE ''en_US.utf8'''
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'zadachok_db')\gexec

-- Ïîäêëþ÷àåìñÿ ê ñîçäàííîé áàçå äàííûõ
\c zadachok_db

-- Ñîçäàåì ñõåìó åñëè íå ñóùåñòâóåò
CREATE SCHEMA IF NOT EXISTS tp;
GRANT ALL PRIVILEGES ON SCHEMA tp TO zadachok;

-- Òàáëèöà customer
CREATE TABLE IF NOT EXISTS tp.customer (
    customer_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_name varchar(255),
    customer_email varchar(255),
    password varchar(255) NOT NULL,
    birthday_date date,
    customer_photo bytea,
    login varchar(255) NOT NULL UNIQUE,
    admin boolean DEFAULT false
);

-- Òàáëèöà shop
CREATE TABLE IF NOT EXISTS tp.shop (
    shop_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id varchar NOT NULL DEFAULT '{}'
);

-- Òàáëèöà task
CREATE TABLE IF NOT EXISTS tp.task (
    task_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_name varchar(255),
    reward integer NOT NULL DEFAULT 0,
    description text,
    start_point date,
    end_point date,
    customer_id integer REFERENCES tp.customer(customer_id), -- убран NOT NULL
    task_state boolean DEFAULT false
);

-- Òàáëèöà product
CREATE TABLE IF NOT EXISTS tp.product (
    product_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name varchar(255),
    product_state boolean DEFAULT true,
    price integer NOT NULL,
    customer_id integer NOT NULL REFERENCES tp.customer(customer_id),
    photo bytea,
    description text
);

-- Òàáëèöà lobby
CREATE TABLE IF NOT EXISTS tp.lobby (
    lobby_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shop_id integer NOT NULL REFERENCES tp.shop(shop_id),
    task_id varchar NOT NULL DEFAULT '{}',
    customer_id varchar NOT NULL DEFAULT '{}'
);

-- Òàáëèöà wallet
CREATE TABLE IF NOT EXISTS tp.wallet (
    wallet_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id integer,
    lobby_id integer,
    balance integer NOT NULL DEFAULT 0
);

-- Íàñòðîéêà ïðàâ
ALTER DEFAULT PRIVILEGES IN SCHEMA tp GRANT ALL PRIVILEGES ON TABLES TO zadachok;
ALTER DEFAULT PRIVILEGES IN SCHEMA tp GRANT ALL PRIVILEGES ON SEQUENCES TO zadachok;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA tp TO zadachok;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA tp TO zadachok;

-- Íàñòðàèâàåì ïóòü ïîèñêà
ALTER ROLE zadachok SET search_path TO tp, public;

-- Ñîçäàåì èíäåêñû äëÿ óëó÷øåíèÿ ïðîèçâîäèòåëüíîñòè
CREATE INDEX IF NOT EXISTS idx_customer_login ON tp.customer(login);
CREATE INDEX IF NOT EXISTS idx_task_customer ON tp.task(customer_id);
CREATE INDEX IF NOT EXISTS idx_product_customer ON tp.product(customer_id);

-- Ôèíàëèçàöèÿ
VACUUM ANALYZE;
