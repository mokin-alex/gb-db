create database homework;
use homework;
/*
 * ЗАДАЧА 1.	Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
 */
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME,  
  updated_at DATETIME 
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');
 
-- Заполните их текущими датой и временем:
select * from users where created_at is null and updated_at is null;
 
update users 
 set created_at = Now(),
     updated_at = now() 
 where created_at is null and updated_at is null;
 -- =======================================================================
 

/*
 * ЗАДАЧА 2.	Таблица users была неудачно спроектирована. 
 * Записи created_at и updated_at были заданы типом VARCHAR 
 * и в них долгое время помещались значения в формате 20.10.2017 8:10. 
 * Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.
 */
DROP TABLE IF EXISTS users_bad;
CREATE TABLE users_bad (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(30),  
  updated_at VARCHAR(30) 
) COMMENT = 'Плохо спроектированная таблица: Покупатели';

 INSERT INTO users_bad (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'), 
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');
 -- поля created_at и updated_at заполним вручную.
 
 -- Если мы сразу применим команду модификации типа столбца, то получим ошибку не соответсвия типов данных
 ALTER TABLE homework.users_bad MODIFY COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP; -- ОШИБКА
  
-- Поэтому вначале нужно строку преобразовать в строку "20.10.2017 8:10" похожую на формат дата-время "2017-10-20 08:10:00.0"

-- Вариант 1:
-- Пример функции STR_TO_DATE:
 select
	STR_TO_DATE(created_at, '%d.%m.%Y %h:%i')
from
	users_bad;

-- Обновим символьные поля в формат дата-время 
update users_bad 
set 
created_at = STR_TO_DATE(created_at, '%d.%m.%Y %h:%i'),
updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %h:%i');

-- Вариант 2:
-- либо преобразуем с помочью substr и соеденим ка кнужно с помощью concat:
update users_bad 
set 
created_at = concat (substr(created_at, 7,4),'-', substr(created_at, 4,2), '-', substr(created_at, 1,2), substr(created_at, 11)),
updated_at = concat (substr(updated_at, 7,4),'-', substr(updated_at, 4,2), '-', substr(updated_at, 1,2), substr(updated_at, 11));

-- Теперь же преобразуем неправильный формат колонки VARCHAR в правильный DATETIME.
ALTER TABLE homework.users_bad MODIFY COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE homework.users_bad MODIFY COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
RENAME TABLE homework.users_bad TO homework.users_good;
-- =============================================================

/*
 * ЗАДАЧА 3.	В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
 * 0, если товар закончился и выше нуля, если на складе имеются запасы. 
 * Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
 * Однако нулевые запасы должны выводиться в конце, после всех записей
 */
CREATE TABLE storehouses_products  (
  id SERIAL PRIMARY KEY,
  value bigint
  );
 
 INSERT INTO storehouses_products (value) VALUES
  (888),
  (456),
  (0),
  (7469),
  (123698),
  (7),
  (99),
  (0);
 
select 	* from 	storehouses_products
order by
	case
		value when 0 then 9999999999 -- добавим для нулевых значений заведомо большое значение для сортировки (всегда нижние строки!)
		else value
	end asc;

/*
 * ЗАДАЧА 5.	(по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. 
 * SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
 * Отсортируйте записи в порядке, заданном в списке IN.
 */
select * from storehouses_products where id in (3,7,1,5,2)
ORDER BY FIND_IN_SET(id,'3,7,1,5,2');
-- =======================================================================

-- теме «Агрегация данных» 

-- ЗАДАЧА 1. Подсчитайте средний возраст пользователей в таблице users.
-- вначале сделаем запрос, где подсчитаем возраст в годах. (с учетом весокосных годов)
select *, floor((to_days(curdate()) - to_days(birthday_at))/365.25) as current_age from users;
-- найдем средний возраст:
select avg(floor((to_days(curdate()) - to_days(birthday_at))/365.25)) as avarage_age from users;
-- ответ: 30

-- ЗАДАЧА 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.

-- Решение:
-- Найдем, для примера, наименование деня недели непосредственно в День рождения  
select name, birthday_at, WEEKDAY(birthday_at) as day_of_week, DAYNAME(birthday_at) as name_day_of_week from users;
-- Теперь найдем то же самое в текущем году и подсчитаем количество в каждом дне недели 
select
    weekday(concat(year (curdate()),'-' ,month (birthday_at),'-', day (birthday_at))) as day_of_week,
	dayname(concat(year (curdate()),'-', month (birthday_at),'-', day (birthday_at))) as name_day_of_week,
	count(*) as birthday_quantity 
from users -- это из базы данных homework
group by day_of_week, name_day_of_week
order by day_of_week;
-- Для большей наглядности сделаем выборку из таблицы profiles базы данных snet0408:
select
    weekday(concat(year (curdate()),'-' ,month (birthday),'-', day (birthday))) as day_of_week,
	dayname(concat(year (curdate()),'-', month (birthday),'-', day (birthday))) as name_day_of_week,
	count(*) as birthday_quantity 
from snet0408.profiles -- это из базы данных snet0408
group by day_of_week, name_day_of_week
order by day_of_week;
