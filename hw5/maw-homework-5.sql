create database homework;
use homework;
/*
 * ������ 1.	����� � ������� users ���� created_at � updated_at ��������� ��������������. ��������� �� �������� ����� � ��������.
 */
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT '��� ����������',
  birthday_at DATE COMMENT '���� ��������',
  created_at DATETIME,  
  updated_at DATETIME 
) COMMENT = '����������';

INSERT INTO users (name, birthday_at) VALUES
  ('��������', '1990-10-05'),
  ('�������', '1984-11-12'),
  ('���������', '1985-05-20'),
  ('������', '1988-02-14'),
  ('����', '1998-01-12'),
  ('�����', '1992-08-29');
 
-- ��������� �� �������� ����� � ��������:
select * from users where created_at is null and updated_at is null;
 
update users 
 set created_at = Now(),
     updated_at = now() 
 where created_at is null and updated_at is null;
 -- =======================================================================
 

/*
 * ������ 2.	������� users ���� �������� ��������������. 
 * ������ created_at � updated_at ���� ������ ����� VARCHAR 
 * � � ��� ������ ����� ���������� �������� � ������� 20.10.2017 8:10. 
 * ���������� ������������� ���� � ���� DATETIME, �������� �������� ����� ��������.
 */
DROP TABLE IF EXISTS users_bad;
CREATE TABLE users_bad (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT '��� ����������',
  birthday_at DATE COMMENT '���� ��������',
  created_at VARCHAR(30),  
  updated_at VARCHAR(30) 
) COMMENT = '����� ���������������� �������: ����������';

 INSERT INTO users_bad (name, birthday_at) VALUES
  ('��������', '1990-10-05'),
  ('�������', '1984-11-12'),
  ('���������', '1985-05-20'), 
  ('������', '1988-02-14'),
  ('����', '1998-01-12'),
  ('�����', '1992-08-29');
 -- ���� created_at � updated_at �������� �������.
 
 -- ���� �� ����� �������� ������� ����������� ���� �������, �� ������� ������ �� ����������� ����� ������
 ALTER TABLE homework.users_bad MODIFY COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP; -- ������
  
-- ������� ������� ����� ������ ������������� � ������ "20.10.2017 8:10" ������� �� ������ ����-����� "2017-10-20 08:10:00.0"

-- ������� 1:
-- ������ ������� STR_TO_DATE:
 select
	STR_TO_DATE(created_at, '%d.%m.%Y %h:%i')
from
	users_bad;

-- ������� ���������� ���� � ������ ����-����� 
update users_bad 
set 
created_at = STR_TO_DATE(created_at, '%d.%m.%Y %h:%i'),
updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %h:%i');

-- ������� 2:
-- ���� ����������� � ������� substr � �������� �� ������ � ������� concat:
update users_bad 
set 
created_at = concat (substr(created_at, 7,4),'-', substr(created_at, 4,2), '-', substr(created_at, 1,2), substr(created_at, 11)),
updated_at = concat (substr(updated_at, 7,4),'-', substr(updated_at, 4,2), '-', substr(updated_at, 1,2), substr(updated_at, 11));

-- ������ �� ����������� ������������ ������ ������� VARCHAR � ���������� DATETIME.
ALTER TABLE homework.users_bad MODIFY COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE homework.users_bad MODIFY COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
RENAME TABLE homework.users_bad TO homework.users_good;
-- =============================================================

/*
 * ������ 3.	� ������� ��������� ������� storehouses_products � ���� value ����� ����������� ����� ������ �����: 
 * 0, ���� ����� ���������� � ���� ����, ���� �� ������ ������� ������. 
 * ���������� ������������� ������ ����� �������, ����� ��� ���������� � ������� ���������� �������� value. 
 * ������ ������� ������ ������ ���������� � �����, ����� ���� �������
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
		value when 0 then 9999999999 -- ������� ��� ������� �������� �������� ������� �������� ��� ���������� (������ ������ ������!)
		else value
	end asc;

/*
 * ������ 5.	(�� �������) �� ������� catalogs ����������� ������ ��� ������ �������. 
 * SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
 * ������������ ������ � �������, �������� � ������ IN.
 */
select * from storehouses_products where id in (3,7,1,5,2)
ORDER BY FIND_IN_SET(id,'3,7,1,5,2');
-- =======================================================================

-- ���� ���������� ������� 

-- ������ 1. ����������� ������� ������� ������������� � ������� users.
-- ������� ������� ������, ��� ���������� ������� � �����. (� ������ ���������� �����)
select *, floor((to_days(curdate()) - to_days(birthday_at))/365.25) as current_age from users;
-- ������ ������� �������:
select avg(floor((to_days(curdate()) - to_days(birthday_at))/365.25)) as avarage_age from users;
-- �����: 30

-- ������ 2. ����������� ���������� ���� ��������, ������� ���������� �� ������ �� ���� ������. 
-- ������� ������, ��� ���������� ��� ������ �������� ����, � �� ���� ��������.

-- �������:
-- ������, ��� �������, ������������ ���� ������ ��������������� � ���� ��������  
select name, birthday_at, WEEKDAY(birthday_at) as day_of_week, DAYNAME(birthday_at) as name_day_of_week from users;
-- ������ ������ �� �� ����� � ������� ���� � ���������� ���������� � ������ ��� ������ 
select
    weekday(concat(year (curdate()),'-' ,month (birthday_at),'-', day (birthday_at))) as day_of_week,
	dayname(concat(year (curdate()),'-', month (birthday_at),'-', day (birthday_at))) as name_day_of_week,
	count(*) as birthday_quantity 
from users -- ��� �� ���� ������ homework
group by day_of_week, name_day_of_week
order by day_of_week;
-- ��� ������� ����������� ������� ������� �� ������� profiles ���� ������ snet0408:
select
    weekday(concat(year (curdate()),'-' ,month (birthday),'-', day (birthday))) as day_of_week,
	dayname(concat(year (curdate()),'-', month (birthday),'-', day (birthday))) as name_day_of_week,
	count(*) as birthday_quantity 
from snet0408.profiles -- ��� �� ���� ������ snet0408
group by day_of_week, name_day_of_week
order by day_of_week;
