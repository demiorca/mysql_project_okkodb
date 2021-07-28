-- Курсовой проект к курсу "Базы данных".

-- База данных онлайн-кинотеатра Okko.

-- Пункт 5. Скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы).

USE okko;

-- Показать самый популярный фильм среди клиентов (самый приобретаемый).

SELECT
    name,
    COUNT(*) AS cnt
FROM orders_products op
JOIN movies ON op.movie_order_id = movies.id
GROUP BY movie_order_id
ORDER BY cnt DESC
LIMIT 1;

-- Показать все доступные цены на фильмы и посчитать количество фильмов по каждой цене.

SELECT
    price,
    COUNT(*)
FROM movies WHERE price IS NOT NULL
GROUP BY price;

-- Показать, в какую подписку входит тот или иной фильм (из списка фильмов, которые входят в состав подписок), а также упорядочить по подпискам.

SELECT
    movies.name AS movies, subscriptions.name AS subscriptions
FROM movies
JOIN subscriptions ON movies.what_subscription = subscriptions.id WHERE is_applies_to_subscription = 1
ORDER BY subscriptions;

-- Показать, к какому каталогу относится тот или иной фильм, а также упорядочить по каталогам.

SELECT
    movies.name AS movies, catalogs.name AS catalogs
FROM movies
JOIN catalogs ON movies.catalog_id = catalogs.id
ORDER BY catalogs;

-- Показать топ-3 самых популярных среди пользователей типов устройств для просмотра на сервисе.

SELECT
    (SELECT name FROM devices_types WHERE id = devices.device_type_id) AS device_type,
    COUNT(*) AS cnt
FROM users_devices
JOIN devices ON users_devices.device_id = devices.id
GROUP BY device_type
ORDER BY cnt DESC
LIMIT 3;

-- Показать количество используемых устройств среди пользователей в порядке убывания.

SELECT
    name,
    COUNT(*) AS cnt 
FROM users_devices
JOIN devices ON users_devices.device_id = devices.id
GROUP BY devices.id 
ORDER BY cnt DESC;
