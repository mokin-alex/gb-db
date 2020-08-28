-- 1.	Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
-- выведем всех пользователей:
select u.id, login , firstName from users u;
/*
id	login	firstName
1	admin	Alex
2	bibit	Leonid
4	ilya	Ilya
 */
-- теперь выведем лишь тех, кто делал заказ:
select u.id, login , firstName from users u
where exists (select 1 from orders o2 where u.id = o2.user_id);
/*
1	admin	Alex
2	bibit	Leonid
 */

-- 2.	Выведите список товаров products и разделов catalogs, который соответствует товару.
-- Вместо этого выведу все товары, которые были в заказах 
select order_id, product_id, quantity, name, description, price from order_products op
join products p2 
on op.product_id = p2.id;
/*
order_id	product_id	quantity	name	description	price
1			10			1	Henri Cartier Bresson	Henri Cartier Bresson 1934 hk	555.00
2			11			1	Henri Cartier Bresson	FRANCE. Brie. 1968.	777.00
2			12			1	Henri Cartier Bresson	FRANCE. The Var department. Hyères. 1932	140.00
3			12			2	Henri Cartier Bresson	FRANCE. The Var department. Hyères. 1932	140.00
3			8			1	Henri Cartier Bresson	To take a photograph is to align the head, the eye and the heart. It's a way of life	111.00
4			12			2	Henri Cartier Bresson	FRANCE. The Var department. Hyères. 1932	140.00
4			8			1	Henri Cartier Bresson	To take a photograph is to align the head, the eye and the heart. It's a way of life	111.00
5			12			2	Henri Cartier Bresson	FRANCE. The Var department. Hyères. 1932	140.00
5			8			1	Henri Cartier Bresson	To take a photograph is to align the head, the eye and the heart. It's a way of life	111.00
6			11			1	Henri Cartier Bresson	FRANCE. Brie. 1968.	777.00
6			10			3	Henri Cartier Bresson	Henri Cartier Bresson 1934 hk	555.00
7			8			1	Henri Cartier Bresson	To take a photograph is to align the head, the eye and the heart. It's a way of life	111.00
8			12			1	Henri Cartier Bresson	FRANCE. The Var department. Hyères. 1932	140.00
17			11			1	Henri Cartier Bresson	FRANCE. Brie. 1968.	777.00
18			11			1	Henri Cartier Bresson	FRANCE. Brie. 1968.	777.00
 */

-- 3.	(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. 
-- Выведите список рейсов flights с русскими названиями городов.
-- Создадим таблицы:
CREATE TABLE homework.flights (
	id SERIAL primary key,
	`from` varchar(100) NULL,
	`to` varchar(100) NULL
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;
-- Добавили данные:
/*
1	moscow	kurgan
3	omsk	moscow
2	moscow	ekaterinburg
 */
CREATE TABLE homework.cities (
	label varchar(100) primary key,
	name  varchar(100) NULL
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;
-- Добавили данные:
/*
moscow	Москва
ekaterinburg	Екатеринбург
kurgan	Курган
omsk	Омск
 */
-- СФОРМИРУЕМ ИТОГОВЫЙ запрос используя подзапрос:
select 
id,
(select name from cities where label = fl.from) as 'from',
(select name from cities where label = fl.to) as 'to'
from flights fl;
/* В результате названия будут на русском:
id	`from`	`to`
1	Москва	Курган
2	Москва	Екатеринбург
3	Омск	Москва
*/
