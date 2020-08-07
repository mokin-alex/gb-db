-- 1) Внычале выполним команды ниже: создания баз и таблицы, внесем данные:
CREATE database if not exists example;
use example;
create table if not exists users(
id int auto_increment primary key,
name varchar(100)
);
INSERT INTO `example`.`users` (`name`) VALUES ('aaa');
INSERT INTO `example`.`users` (`name`) VALUES ('bbb');
INSERT INTO `example`.`users` (`name`) VALUES ('ccc');

CREATE database if not exists sample;

-- ========================================================
-- 2) Затем сделаем дамп базы example и загрузим в базу sample:
-- в командной строке наберем:
-- cd C:\Program Files\MySQL\MySQL Server 8.0\bin
-- mysqldump -u root -p example >c:\sql_dump\example.sql
-- mysql -u root -p sample <c:\sql_dump\example.sql



