-- Получилось 5 запросов, в которых использовались: вложенные запросы, join,  группировка, case и if, агрегирующие функции и сортировка

-- Запрос 1: Рейтинг авторов
-- сколько фото представлено на сайте в портфолио
-- сколько продукции (фото, постеры, книги) в магазине
-- сколько реально в штуках преобретено, и на какую общую сумму
-- explain
select ph.id, ph.name, ph.status, tbl_portfolio.portfolio, tbl_collection.shop_collections, tbl_sales.quantity_sales, tbl_sales.total_sales from photographers ph
left join
	-- сколько фото представлено на сайте в портфолио
	(select p.id, p.name, count(p2.id) as portfolio from photographers p 
	join photos p2 on p.id=p2.profile_id 
	group by p.id
	order by p.id) as tbl_portfolio
on ph.id = tbl_portfolio.id
left join
	-- сколько продукции (фото, постеры, книги) в магазине
	(select p.id, p.name, count(c.id) as shop_collections from photographers p 
	join collections c on p.id=c.author
	group by p.id
	order by p.id) as tbl_collection
on ph.id = tbl_collection.id
left join
	-- сколько реально в штуках преобретено, и на какую общую сумму
	(select p.id, p.name, sum(op.quantity) as quantity_sales, sum(op.total) as total_sales from photographers p 
	join collections c on p.id=c.author
	join price pr on pr.coll_id=c.id
	join order_products op on op.product_id = pr.id
	join orders o2 on o2.id = op.order_id 
	where o2.status = 'paid' or o2.status = 'delivered' -- только оплаченные и уже доставленные покупателю заказы.
	group by p.id
	order by p.id) as tbl_sales
on ph.id = tbl_sales.id
-- order by ph.id
order by tbl_sales.total_sales desc 
;
/* TOP 5 photographers
id	name					status			portfolio	shop_collections	quantity_sales	total_sales
35	Ferdinando Scianna		Member			11			18					45				215232.00
69	Olivia Arthur			Member			8			20					47				213069.00
67	Newsha Tavakolian		Member			19			16					47				202179.00
36	George Rodger			Found member	16			22					44				180713.00
58	Mark Power				Member			13			10					33				169657.00
70	Paolo Pellegrin			Member			6			9					32				159097.00
 */

-- Запрос 2: Рейтинг покупателей
-- сколько заказов в статусе оплачен и доставлен
-- сколько позиций и на какую сумму
-- дата последнего из заказов 
select us.id, concat(us.first_name, ' ', us.last_name) as name, count(o2.id) as orders_quantity, sum(op.quantity) as quantity_sales, sum(op.total) as total_sales, max(date(o2.created_at)) as last_active from users us 
left join orders o2 on o2.user_id = us.id 
join order_products op on o2.id = op.order_id
where o2.status = 'paid' or o2.status = 'delivered' -- только оплаченные и уже доставленные покупателю заказы.
group by us.id 
-- order by us.id 
-- order by last_active desc
order by total_sales desc
;
/* TOP 5 sales
id	name				orders_quantity	quantity_sales	total_sales	last_active
34	Herculie Collier	42				63				280678.00	2019-12-13
59	Carlene Yapp		29				44				233210.00	2019-07-03
86	Gloriane Dinkin		26				39				206830.00	2020-05-10
55	Bea Thieme			37				50				205157.00	2019-08-31
24	Galven Fuke			28				41				199352.00	2015-07-25
 */

-- Запрос 3: Анти Рейтинг покупателей, которые отказались от заказов 
select us.id, concat(us.first_name, ' ', us.last_name) as name, count(o2.id) as canceled_orders_quantity from users us 
left join orders o2 on o2.user_id = us.id 
where o2.status = 'cancelled'
group by us.id 
order by canceled_orders_quantity desc
;
/*
52	Elka Streetley	4
78	Ulberto Aizic	4
59	Carlene Yapp	4
40	Nevsa Bugby		3
88	Leland Cappell	3
 */

-- Запрос 4: Информация о заказах
-- отсортированных по дате, с общей суммой и количеством позиций в заказе, статус заказа.
select date(o2.created_at) as order_date, o2.order_number, concat(u2.first_name,' ', u2.last_name) as shopper, o2.status, sum(op.quantity) as order_quantity, sum(op.total) as order_total from orders o2
join order_products op on o2.id = op.order_id
join users u2 on o2.user_id=u2.id 
group by o2.id
order by order_date desc, o2.status, order_total desc
;
/*
order_date	order_number	shopper				status	order_quantity	order_total
2020-09-13	ZDN5237092	Nevsa Bugby				delivered	4	27780.00
2020-09-09	DKE4981808	Jasmin Stokoe			cancelled	4	20670.00
2020-09-05	WDY7887290	Hyatt Playle			paid		6	23747.00
2020-09-03	UER2198474	Allyce Foskin			delivered	5	35411.00
2020-09-03	YPD8819261	Nady McDermott			delivered	3	13623.00
2020-08-11	TDB9067793	Robinette Denny			delivered	4	8934.00
2020-08-07	VKM6220215	Gloriane Dinkin			cancelled	7	40308.00
2020-07-27	IOF3749842	Rosalinda Gozzard		new			10	45983.00
2020-07-27	FKH5074532	Geraldine Christensen	delivered	8	43277.00
*/

-- Запрос 5: Какая продукция более всего заказывалась
-- в разрезе Типа(фото, постер,книга,предмет), подтипа(раритетная книга или винтажный постер), колекция магнум, подписанли или штам владельца.
-- использовались: вложенный запрос, join,  группировка, case и if, агрегирующие функции.
select 
	c2.`type` , 
	if(c2.tags is null, '', c2.tags) as subtype, 
	case c2.magnum_edition
		when 0 then ''
		when 1 then 'Magnum Editions'
	end as isMagnum,
	if(c2.signed is null, 'Unsigned', c2.signed) as isSigned,
	sum(tbl_coll_total.quantity_sales) as quantity 
from collections c2 
join
	(select pr.coll_id as collection, sum(op.quantity) as quantity_sales from price pr
	join order_products op on pr.id = op.product_id
	join orders o2 on o2.id = op.order_id 
	where o2.status = 'paid' or o2.status = 'delivered'
	group by pr.coll_id) as tbl_coll_total
on c2.id = tbl_coll_total.collection
group by c2.`type`, c2.tags, c2.magnum_edition, c2.signed
-- order by c2.`type`
order by quantity desc
;
/*
|type                |subtype                                           |isMagnum       |isSigned      |quantity                                               
|--------------------|--------------------------------------------------|---------------|--------------|--------|
|Fine Prints         |                                                  |               |Unsigned      |601                                                   
|Fine Prints         |                                                  |               |Signed        |316                                                    
|Posters             |Contemporary Posters                              |               |Unsigned      |245                                                    
|Fine Prints         |                                                  |               |Estate Stamped|193                                                    
|Posters             |Contemporary Posters                              |               |Signed        |160                                                    
|Posters             |Contemporary Posters                              |               |Estate Stamped|98                                                     
|Fine Prints         |                                                  |Magnum Editions|Unsigned      |33                                                     
|Posters             |Contemporary Posters                              |Magnum Editions|Unsigned      |28                                                     
|Contact Sheet Prints|                                                  |Magnum Editions|Unsigned      |19                                                     
|Fine Prints         |                                                  |Magnum Editions|Signed        |17                                                     
|Contact Sheet Prints|                                                  |Magnum Editions|Signed        |17                                                     
|Books               |                                                  |               |Signed        |15                                                     
|Posters             |Contemporary Posters                              |Magnum Editions|Signed        |13                                                     
|Books               |                                                  |               |Unsigned      |12                                                     
|Contact Sheet Prints|                                                  |Magnum Editions|Estate Stamped|12                                                     
|Fine Prints         |                                                  |Magnum Editions|Estate Stamped|11                                                     
|Objects             |                                                  |               |Unsigned      |10                                                     
|Objects             |                                                  |Magnum Editions|Unsigned      |10                                                     
|Objects             |                                                  |               |Signed        |6                                                      
|Books               |                                                  |               |Estate Stamped|5                                                      
|Posters             |Vintage Posters                                   |               |Estate Stamped|5                                                      
|Books               |Rare Books                                        |               |Signed        |4                                                      
|Posters             |Contemporary Posters                              |Magnum Editions|Estate Stamped|3                                                      
|Books               |                                                  |Magnum Editions|Unsigned      |2                                                      
|Books               |Rare Books                                        |               |Estate Stamped|2                                                      
|Books               |                                                  |Magnum Editions|Signed        |2                                                      
|Books               |Books with Prints                                 |               |Unsigned      |2                                                      
|Books               |Rare Books                                        |               |Unsigned      |2                                                      
|Posters             |Vintage Posters                                   |               |Signed        |2                                                      
|Books               |Rare Books                                        |Magnum Editions|Unsigned      |1                                                      

*/
