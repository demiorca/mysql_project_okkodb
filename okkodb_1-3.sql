-- Курсовой проект к курсу "Базы данных".

-- База данных онлайн-кинотеатра Okko.

/* Пункт 1. Общее текстовое описание БД и решаемых ею задач.

   База данных онлайн-кинотеатра Okko содержит в себе несколько таблиц, обеспечивающих работу сервиса.  
   Каждая таблица отвечает за определённые аспекты проекта, некоторые из таблиц напрямую взаимосвязаны:
   Таблица users содержит в себе список всех пользователей сервиса.
   Таблицы media_types, pictures, videos, movies относятся к медиаконтенту сервиса. Между данными таблицами созданы различные связи.
   Таблицы subscriptions, catalogs, novelties являются связанными с таблицей movies и содержут в себе те или иные фильмы (или другой видеоконтент).
   Таблицы orders_products и orders созданы для реализации покупок на сервисе.
   Таблицы devices_types и devices содержат в себе информацию о поддерживаемых сервисом устройствах для просмотра видеоконтента.
   Таблицы users_content и users_devices относятся к учётным записям пользователей. В них содержится информация о привязанных устройствах, активных подписках и совершённых покупках.
   Таблица promos содержит в себе всю информацию по поводу акций сервиса (промокоды, скидки, пробные периоды подписок).
*/

/* Пункт 2. Минимальное количество таблиц - 10;

   Пункт 3. Скрипты создания структуры БД (с первичными ключами, индексами, внешними ключами).
*/

DROP DATABASE IF EXISTS okko;
CREATE DATABASE okko;
USE okko;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    firstname VARCHAR(50) COMMENT 'Имя',
    lastname VARCHAR(50) COMMENT 'Фамилия',
    email VARCHAR(120) UNIQUE COMMENT 'Электронная почта',
    phone BIGINT COMMENT 'Номер телефона',
    INDEX users_firstname_lastname_idx(firstname, lastname),
    INDEX users_phone_idx(phone)
) COMMENT = 'Пользователи сервиса';

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) COMMENT 'Название типа медиафайла',
    created_at DATETIME DEFAULT NOW()
) COMMENT = 'Типы медиафайлов';

DROP TABLE IF EXISTS pictures;
CREATE TABLE pictures(
    id SERIAL PRIMARY KEY,
    picture_type_id BIGINT UNSIGNED NOT NULL COMMENT 'К какому типу медиафайлов относится изображение',
    filename VARCHAR(255) COMMENT 'Название файла изображения с расширением',
    size INT COMMENT 'Размер файла изображения',
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (picture_type_id) REFERENCES media_types(id)
) COMMENT = 'Графический контент';

DROP TABLE IF EXISTS videos;
CREATE TABLE videos(
    id SERIAL PRIMARY KEY,
    video_type_id BIGINT UNSIGNED NOT NULL COMMENT 'К какому типу медиафайлов относится видеофайл',
    filename VARCHAR(255) COMMENT 'Название видеофайла с расширением',
    size INT COMMENT 'Размер видеофайла',
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (video_type_id) REFERENCES media_types(id)
) COMMENT = 'Видео контент';

DROP TABLE IF EXISTS subscriptions;
CREATE TABLE subscriptions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) COMMENT 'Название подписки',
    description TEXT COMMENT 'Описание',
    price DECIMAL (11,2) COMMENT 'Цена',
    subscription_picture_id BIGINT UNSIGNED NOT NULL COMMENT 'Обложка подписки',
    UNIQUE unique_name(name(20)) COMMENT 'Присвоение уникального имени подписке',
    INDEX subscriptions_name_idx(name),
    FOREIGN KEY (subscription_picture_id) REFERENCES pictures(id)
) COMMENT = 'Подписки';

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) COMMENT 'Название каталога',
    catalog_picture_id BIGINT UNSIGNED NOT NULL COMMENT 'Обложка каталога',
    UNIQUE unique_name(name(20)) COMMENT 'Присвоение уникального имени каталогу',
    INDEX catalogs_name_idx(name),
    FOREIGN KEY (catalog_picture_id) REFERENCES pictures(id)
) COMMENT = 'Каталог';

DROP TABLE IF EXISTS movies;
CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) COMMENT 'Название',
    movie_picture_id BIGINT UNSIGNED NOT NULL COMMENT 'Обложка фильма',
    video_id BIGINT UNSIGNED NOT NULL COMMENT 'Месторасположение видеофайла',
    description TEXT COMMENT 'Описание',
    price DECIMAL (11,2) COMMENT 'Цена',
    is_applies_to_subscription BIT DEFAULT 0 COMMENT 'Доступен ли фильм в подписках',
    what_subscription BIGINT UNSIGNED COMMENT 'К какой подписке относится фильм',
    catalog_id BIGINT UNSIGNED NOT NULL COMMENT 'К какому каталогу относится фильм',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX movies_name_idx(name),
    FOREIGN KEY (movie_picture_id) REFERENCES pictures(id),
    FOREIGN KEY (video_id) REFERENCES videos(id),
    FOREIGN KEY (catalog_id) REFERENCES catalogs(id),
    FOREIGN KEY (what_subscription) REFERENCES subscriptions(id)
) COMMENT = 'Фильмы (сериалы, мультфильмы, мультсериалы, документальное кино, концерты и другие единицы видеоконтента)';

DROP TABLE IF EXISTS novelties;
CREATE TABLE novelties (
    id SERIAL PRIMARY KEY,
    movie_id BIGINT UNSIGNED NOT NULL COMMENT 'Месторасположение фильма',
    FOREIGN KEY (movie_id) REFERENCES movies(id)
) COMMENT = 'Новинки';

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id SERIAL PRIMARY KEY COMMENT 'Он же номер покупки (заказа)',
    user_id BIGINT UNSIGNED NOT NULL COMMENT 'Пользователь, который совершил покупку (заказ)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX orders_user_id_idx(user_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT = 'Покупки контента (заказы)';

-- За раз можно приобрести только одну единицу контента, корзины нет.

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
    id SERIAL PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL COMMENT 'К какому заказу относится покупка',
    movie_order_id BIGINT UNSIGNED COMMENT 'К какому фильму относится покупка',
    subscription_order_id BIGINT UNSIGNED COMMENT 'К какой подписке относится покупка',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (movie_order_id) REFERENCES movies(id),
    FOREIGN KEY (subscription_order_id) REFERENCES subscriptions(id)
) COMMENT = 'Информация о покупке';

DROP TABLE IF EXISTS devices_types;
CREATE TABLE devices_types(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) COMMENT 'Название типа поддерживаемого устройства',
    created_at DATETIME DEFAULT NOW()
) COMMENT = 'Типы поддерживаемых устройств';

DROP TABLE IF EXISTS devices;
CREATE TABLE devices(
    id SERIAL PRIMARY KEY,
    device_type_id BIGINT UNSIGNED NOT NULL COMMENT 'К какому типу относится устройство',
    name VARCHAR(255) COMMENT 'Название поддерживаемого устройства',
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX devices_name_idx(name),
    FOREIGN KEY (device_type_id) REFERENCES devices_types(id)
) COMMENT = 'Поддерживаемые устройства';

DROP TABLE IF EXISTS users_content;
CREATE TABLE users_content(
    id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL COMMENT 'Какому пользователю принадлежит контент',
    order_id BIGINT UNSIGNED COMMENT 'Месторасположение заказа пользователя',
    is_active BIT COMMENT 'Активна ли подписка',
    renew BIT DEFAULT 1 COMMENT 'Подключено ли автопродление подписки',
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX users_content_user_id_idx(user_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (order_id) REFERENCES orders(id)
) COMMENT = 'Контент, который принадлежит пользователю';

DROP TABLE IF EXISTS users_devices;
CREATE TABLE users_devices(
    id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL COMMENT 'У какого пользователя привязано устройство',
    device_id BIGINT UNSIGNED COMMENT 'Какое именно устройство привязано у пользователя',
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX users_devices_user_id_idx(user_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (device_id) REFERENCES devices(id)
) COMMENT = 'Устройства, которые привязаны у пользователя';

DROP TABLE IF EXISTS promos;
CREATE TABLE promos (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) COMMENT 'Название промокода',
    code BIGINT UNSIGNED NOT NULL COMMENT 'Числовой код акции',
    user_id BIGINT UNSIGNED COMMENT 'Пользователь, который активировал промокод',
    movie_promo_id BIGINT UNSIGNED COMMENT 'Фильм, на который распространяется промокод',
    subscription_promo_id BIGINT UNSIGNED COMMENT 'Подписка, на которую распространяется промокод',
    discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
    days_free TINYINT UNSIGNED COMMENT 'Количество дней доступа к подписке',
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Начало срока активации промокода',
    finished_at DATETIME COMMENT 'Конец срока активации промокода',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX promos_name_idx(name),
    INDEX promos_user_id_idx(user_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (movie_promo_id) REFERENCES movies(id),
    FOREIGN KEY (subscription_promo_id) REFERENCES subscriptions(id)
) COMMENT = 'Промокоды';
