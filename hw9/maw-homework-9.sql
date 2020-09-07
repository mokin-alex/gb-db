-- ЗАДАНИЕ 1 1.	В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
select * from shop.users;
/*
1	Геннадий	1990-10-05	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
2	Наталья	1984-11-12	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
3	Александр	1985-05-20	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
4	Сергей	1988-02-14	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
5	Иван	1998-01-12	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
6	Мария	1992-08-29	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
 */
select * from sample.users;

SET AUTOCOMMIT=0; -- отключим автозавершение транзакций в качяестве упражнения.
start transaction;
set @id = 1; -- применим переменную для красоты
insert into sample.users (id, name, birthday_at, created_at, updated_at)
	select id, name, birthday_at, created_at, updated_at 
	from shop.users 
	where id = @id;
delete from shop.users where id = @id;
commit; -- завершим транзакцию.

select * from shop.users;
/* Есть изменения!
2	Наталья	1984-11-12	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
3	Александр	1985-05-20	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
4	Сергей	1988-02-14	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
5	Иван	1998-01-12	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
6	Мария	1992-08-29	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
 */
select * from sample.users;
/*
1	Геннадий	1990-10-05	2020-09-04 13:53:09.0	2020-09-04 13:53:09.0
 */
start transaction;
set @id = 2; -- применим переменную
insert into sample.users (id, name, birthday_at, created_at, updated_at)
	select id, name, birthday_at, created_at, updated_at 
	from shop.users 
	where id = @id;
delete from shop.users where id =@id;
rollback; -- отменим транзакцию
-- всё осталось без изменений.

-- ЗАДАНИЕ 2 Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.
create or replace view products_of_catalog (product, catalog) as 
	select p.name, c.name from products p 
	left join catalogs c
		on p.catalog_id = c.id
	order by c.id;
-- Отобразим вьюшку:
select * from products_of_catalog;
/*
Intel Core i3-8100	Процессоры
Intel Core i5-7400	Процессоры
AMD FX-8320E	Процессоры
AMD FX-8320	Процессоры
ASUS ROG MAXIMUS X HERO	Материнские платы
Gigabyte H310M S2H	Материнские платы
MSI B250M GAMING PRO	Материнские платы
*/

-- ХРАНИМЫЕ ПРОЦЕДУРЫ и ФУНКЦИИ --

/* ЗАДАНИЕ 1.	Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
*/
drop function if exists hello;
delimiter //
create function hello()
returns text reads sql data
begin
	declare what_hour int;
	set what_hour = hour(now());
	if ( what_hour > 6 and what_hour < 12 )  then 
		return 'Good morning!';
	elseif ( what_hour > 12 and what_hour < 18 ) then 
		return 'Have a good day!!';
	elseif ( what_hour > 18 and what_hour < 24 ) then 
		return 'Good evening!';
	else 
		return 'Good night!';
	end if;	
end;//
delimiter ;
-- Вызов созданной функции:
select hello();
/*
 * Заметил такую проблему:
 * если использовать вместо drop конструкцию create or replace function hello()
 * и выпонить код начиная с delimiter // по Alt-X
 * то выдается ошибка:
 * Error occurred during SQL script execution
Причина:
 SQL Error [1064] [42000]: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'function hello()
returns text reads sql data
begin
	declare what_hour int;
	' at line 1
 * Из-за чего ДОЛГО не мог понять почему у меня не работает.
 */

/*
 * ЗАДАНИЕ 2.	В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
 * Допустимо присутствие обоих полей или одно из них. 
 * Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
 * Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
 * При попытке присвоить полям NULL-значение необходимо отменить операцию
 */
-- Создадим триггер на добавление записи:
drop trigger if exists check_products_on_insert;
delimiter //
CREATE TRIGGER check_products_on_insert BEFORE INSERT ON products
       FOR EACH ROW
       BEGIN
           if ( NEW.name is null and new.description is null ) then 
           -- Отменим операцию:
           	SIGNAL SQLSTATE '45000'
		   	SET MESSAGE_TEXT = 'Добавление: поля name и description не могут быть пустыми!';
		   elseif NEW.name is null then 
			set new.name = 'Товар. (исправьте наименование!)';
           elseif NEW.description is null then 
			set new.description = 'исправьте описание товара!';
           end if;
       END;//
delimiter ;
-- Проверим:
INSERT INTO products (name,description,price,catalog_id)
	VALUES (NULL,NULL,111 ,1);
-- SQL Error [1644] [45000]: Добавление: поля name и description не могут быть пустыми!
-- Добавим name, но без описания
INSERT INTO products (name,description,price,catalog_id)
	VALUES ('Core2-Due MM',NULL,111 ,1);
/* Updated Rows	1
id	name	description	price	catalog_id	created_at	updated_at
10	Core2-Due MM	исправьте описание товара!	111	1	2020-09-07 15:32:26.0	2020-09-07 15:32:26.0
*/

-- Создадим триггер на обновление записи:
drop trigger if exists check_products_on_update;
delimiter //
CREATE TRIGGER check_products_on_update BEFORE UPDATE ON products
       FOR EACH ROW
       BEGIN
           if ( NEW.name is null and new.description is null ) then 
           -- Отменим операцию:
           	SIGNAL SQLSTATE '45001'
		   	SET MESSAGE_TEXT = 'Обновление: поля name и description не могут быть пустыми!';
           end if;
       END;//
delimiter ;
-- Проверим:
UPDATE products
	SET name=null,description=null
	WHERE id=2;
-- SQL Error [1644] [45000]: Поля name и description не могут быть пустыми!
-- Проверим:
UPDATE products
	SET name=null,description='Процессор'
	WHERE id=2;
-- Updated Rows	1
UPDATE products
	SET description=null
	WHERE id=2;
-- SQL Error [1644] [45000]: Поля name и description не могут быть пустыми!


