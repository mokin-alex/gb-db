/*
 * ЗАДАНИЕ 1.	Создайте таблицу logs типа Archive. 
 * Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs помещается время и дата создания записи, 
 * название таблицы, идентификатор первичного ключа и содержимое поля name.
 */

drop table if exists logs;
create table logs (
id SERIAL,
created_at datetime DEFAULT CURRENT_TIMESTAMP,
table_name varchar(50),
record_id bigint not null,
record_name varchar(255)
) ENGINE=Archive DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Создадим триггеры на срабатывание после вставки записи в таблицы
drop trigger if exists log_insert_into_users;
delimiter //
CREATE TRIGGER log_insert_into_users AFTER INSERT ON users
       FOR EACH ROW
       begin
			INSERT INTO logs (table_name,record_id,record_name)
			VALUES ('users', new.id, new.name);
       END;//
delimiter ;
drop trigger if exists log_insert_into_catalogs;
delimiter //
CREATE TRIGGER log_insert_into_catalogs AFTER INSERT ON catalogs
       FOR EACH ROW
       begin
	        INSERT INTO logs (table_name,record_id,record_name)
			VALUES ('catalogs', new.id, new.name);
       END;//
delimiter ;
drop trigger if exists log_insert_into_products;
delimiter //
CREATE TRIGGER log_insert_into_products AFTER INSERT ON products
       FOR EACH ROW
       begin
	        INSERT INTO logs (table_name,record_id,record_name)
			VALUES ('products', new.id, new.name);
       END;//
delimiter ;
-- Проверим:
INSERT INTO users (name,birthday_at)
	VALUES ('Светлана','1999-03-03');
INSERT INTO catalogs (name)
	VALUES ('Корпуса');
INSERT INTO users (name,birthday_at)
	VALUES ('Егор','1999-08-08');
INSERT INTO products (name,description,price,catalog_id)
	VALUES ('i5-9000','Процессор Intel 9-ого поколения',14999,1);
INSERT INTO users (name,birthday_at)
	VALUES ('Матвей','1999-11-11');
-- Логи:
select * from logs;
/*
 *
1	2020-09-11 10:35:42.0	users	10	Светлана
2	2020-09-11 10:35:46.0	catalogs	6	Корпуса
3	2020-09-11 10:36:06.0	users	11	Егор
4	2020-09-11 10:36:16.0	products	11	i5-9000
5	2020-09-11 10:37:03.0	users	12	Матвей
*/

