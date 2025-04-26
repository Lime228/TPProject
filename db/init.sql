-- init_db.sql
-- Инициализация схемы и таблиц для GitHub Actions

-- Создаем схему если не существует
CREATE SCHEMA IF NOT EXISTS tp;

-- Выдаем полные права на схему пользователю zadachok
GRANT ALL PRIVILEGES ON SCHEMA tp TO zadachok;

-- Создаем таблицы в схеме tp
CREATE TABLE IF NOT EXISTS tp.customer (
    customer_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_name character varying,
    customer_email character varying,
    password character varying NOT NULL,
    birthday_date date,
    login character varying NOT NULL UNIQUE,
    admin boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS tp.shop (
    shop_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id text[]  -- Изменено на text[]
);

CREATE TABLE IF NOT EXISTS tp.task (
    task_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_name character varying,
    reward integer,
    description character varying,
    start_point date,
    end_point date,
    customer_id integer NOT NULL REFERENCES tp.customer(customer_id),
    task_state boolean
);

CREATE TABLE IF NOT EXISTS tp.product (
    product_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name character varying,
    product_state boolean,
    price integer NOT NULL,
    customer_id integer NOT NULL REFERENCES tp.customer(customer_id),
    photo bytea,
    description character varying
);

CREATE TABLE IF NOT EXISTS tp.lobby (
    lobby_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shop_id integer NOT NULL REFERENCES tp.shop(shop_id),
    task_id text[],  -- Изменено на text[]
    customer_id text[] NOT NULL  -- Изменено на text[]
);

CREATE TABLE IF NOT EXISTS tp.taskmanager (
    task_lobby_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lobby_id integer REFERENCES tp.lobby(lobby_id),
    task_id integer REFERENCES tp.task(task_id)
);

CREATE TABLE IF NOT EXISTS tp.wallet (
    wallet_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id integer REFERENCES tp.customer(customer_id),
    lobby_id integer REFERENCES tp.lobby(lobby_id),
    balance integer
);

-- Настраиваем путь поиска по умолчанию для пользователя zadachok
ALTER ROLE zadachok SET search_path TO tp, public;

-- Даем полные права на все таблицы в схеме tp
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA tp TO zadachok;