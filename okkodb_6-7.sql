-- Курсовой проект к курсу "Базы данных".

-- База данных онлайн-кинотеатра Okko.

-- Пункт 6. Представления (минимум 2).

USE okko;

-- Вывести название промокода и название подписки/фильма, для которого он предназначен.

CREATE OR REPLACE VIEW v_promos_content (p_name,  c_name) AS
    SELECT promos.name, subscriptions.name FROM promos JOIN subscriptions ON promos.subscription_promo_id = subscriptions.id
    UNION 
    SELECT promos.name, movies.name FROM promos JOIN movies ON promos.movie_promo_id = movies.id;
      
SELECT * FROM v_promos_content;

-- Вывести имя и фамилию пользователя (по алфавиту) и название контента, чтобы посмотреть, что именно принадлежит клиентам.

CREATE OR REPLACE VIEW v_content_owns_by_who (client_name, product_name) AS
    SELECT
    CONCAT(firstname, ' ', lastname) AS client_name,
    products.name AS product_name
    FROM orders o JOIN users u ON o.user_id = u.id
    JOIN
        (SELECT op.id, s.name FROM orders_products op JOIN subscriptions s ON op.subscription_order_id = s.id
        UNION
        SELECT op.id, m.name FROM orders_products op JOIN movies m ON op.movie_order_id = m.id) AS products ON o.id = products.id
    ORDER BY client_name;
      
SELECT * FROM v_content_owns_by_who;

-- Пункт 7. Хранимые процедуры / триггеры.

-- Продедура, создающая пользователей.

DROP PROCEDURE IF EXISTS sp_add_user;

DELIMITER //

CREATE PROCEDURE sp_add_user(firstname VARCHAR(50), lastname VARCHAR(50), email VARCHAR(120), phone BIGINT, OUT tr_result VARCHAR(255))
BEGIN
    DECLARE `__rollback` BIT DEFAULT 0;
    DECLARE code VARCHAR(120);
    DECLARE error_string VARCHAR(120);
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET `__rollback` = 1;
        GET stacked DIAGNOSTICS CONDITION 1
            code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		
        SET tr_result := CONCAT('Ошибка запроса. Код ошибки:', code, 'Подробнее: ', error_string);
	END;
    
    START TRANSACTION;
        INSERT INTO users (firstname, lastname, email, phone)
        VALUES (firstname, lastname, email, phone);
    
    IF `__rollback` THEN
        ROLLBACK;
	ELSE
        SET tr_result = 'commit';
        COMMIT;
	END IF;
END //

DELIMITER ;

CALL sp_add_user('New', 'User', 'gmail@gmail.com', 79991234567, @tr_result);

SELECT @tr_result;
