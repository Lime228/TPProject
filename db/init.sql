-- init_db.sql
-- Полная инициализация базы данных с обработкой ошибок

-- Устанавливаем параметры для чистого выполнения
SET client_min_messages TO WARNING;
\set ON_ERROR_STOP on

-- Создаем пользователя если не существует
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'zadachok') THEN
    CREATE ROLE zadachok WITH LOGIN PASSWORD 'zadachok';
  ELSE
    ALTER ROLE zadachok WITH PASSWORD 'zadachok';
  END IF;
END
$$;

-- Создаем базу данных если не существует
SELECT 'CREATE DATABASE zadachok_db WITH OWNER zadachok ENCODING ''UTF8'' LC_COLLATE ''en_US.utf8'' LC_CTYPE ''en_US.utf8'''
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'zadachok_db')\gexec

-- Подключаемся к созданной базе данных
\c zadachok_db

-- Создаем схему если не существует
CREATE SCHEMA IF NOT EXISTS tp;
GRANT ALL PRIVILEGES ON SCHEMA tp TO zadachok;

-- Таблица customer
CREATE TABLE IF NOT EXISTS tp.customer (
    customer_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_name varchar(255),
    customer_email varchar(255),
    password varchar(255) NOT NULL,
    birthday_date date,
    login varchar(255) NOT NULL UNIQUE,
    admin boolean DEFAULT false
);

-- Таблица shop
CREATE TABLE IF NOT EXISTS tp.shop (
    shop_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id text[] NOT NULL DEFAULT '{}'
);

-- Таблица task
CREATE TABLE IF NOT EXISTS tp.task (
    task_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_name varchar(255),
    reward integer NOT NULL DEFAULT 0,
    description text,
    start_point timestamp,
    end_point timestamp,
    customer_id integer NOT NULL REFERENCES tp.customer(customer_id),
    task_state boolean DEFAULT false
);

-- Таблица product
CREATE TABLE IF NOT EXISTS tp.product (
    product_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name varchar(255),
    product_state boolean DEFAULT true,
    price integer NOT NULL,
    customer_id integer NOT NULL REFERENCES tp.customer(customer_id),
    photo bytea,
    description text
);

-- Таблица lobby
CREATE TABLE IF NOT EXISTS tp.lobby (
    lobby_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shop_id integer NOT NULL REFERENCES tp.shop(shop_id),
    task_id text[] NOT NULL DEFAULT '{}',
    customer_id text[] NOT NULL DEFAULT '{}'
);

-- Таблица taskmanager
CREATE TABLE IF NOT EXISTS tp.taskmanager (
    task_lobby_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lobby_id integer REFERENCES tp.lobby(lobby_id),
    task_id integer REFERENCES tp.task(task_id)
);

-- Таблица wallet
CREATE TABLE IF NOT EXISTS tp.wallet (
    wallet_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id integer REFERENCES tp.customer(customer_id),
    lobby_id integer REFERENCES tp.lobby(lobby_id),
    balance integer NOT NULL DEFAULT 0
);

-- Настройка прав
ALTER DEFAULT PRIVILEGES IN SCHEMA tp GRANT ALL PRIVILEGES ON TABLES TO zadachok;
ALTER DEFAULT PRIVILEGES IN SCHEMA tp GRANT ALL PRIVILEGES ON SEQUENCES TO zadachok;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA tp TO zadachok;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA tp TO zadachok;

-- Настраиваем путь поиска
ALTER ROLE zadachok SET search_path TO tp, public;

-- Создаем индексы для улучшения производительности
CREATE INDEX IF NOT EXISTS idx_customer_login ON tp.customer(login);
CREATE INDEX IF NOT EXISTS idx_task_customer ON tp.task(customer_id);
CREATE INDEX IF NOT EXISTS idx_product_customer ON tp.product(customer_id);

-- Финализация
VACUUM ANALYZE;