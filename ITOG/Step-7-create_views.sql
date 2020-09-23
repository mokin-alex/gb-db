-- Это файл создания Представлений
-- Представление на странице каталога для постеров: https://www.magnumphotos.com/shop/collections/posters/
drop view if exists catalog_posters;
CREATE VIEW catalog_posters AS 
select
	case when (select avg(limit_current) from price where c.id = price.coll_id)=0 then concat('Out of Stock – Poster: ', c.name) -- Если все подвиды продукции с лимитом 0, то нет в наличии!
		 when (magnum_edition=1 and (signed<>'Signed' or signed is null)) then concat('Magnum Collection Poster: ', c.name)
		 when (magnum_edition=1 and signed='Signed') then concat('Signed Magnum Collection Poster: ', c.name)
		 when (tags='Vintage Posters' and (signed<>'Signed' or signed is null)) then concat('Vintage Poster: ', c.name)
		 when (tags='Vintage Posters' and  signed='Signed') then concat('Singned Vintage Poster: ', c.name)
 		 when (tags='Contemporary Posters' and (signed<>'Signed' or signed is null)) then concat('Contemporary Poster: ', c.name)
 		 when (tags='Contemporary Posters' and  signed='Signed') then concat('Signed Contemporary Poster: ', c.name)
	end as title,
p2.name as author,
-- (select min(price) from price where c.id = price.coll_id and price.limit_current<>0) as price,
(select min(price) from price where c.id = price.coll_id) as price,
edition,
(select if(magnum_edition=1, 'Magnum Editions', '')) as isMagnum,
signed,
(select url from coll_photos cp where cp.coll_id = c.id order by main desc limit 1) as url,
c.id
from collections c
join photographers p2 on c.author = p2.id 
where `type`='Posters'
order by rand(); -- сортировку делаем случайную.

-- Представление на странице каталога (то же самое), но для, например, Книг: https://www.magnumphotos.com/shop/collections/books/
drop view if exists catalog_books;
CREATE VIEW catalog_books AS 
select
	case when (select avg(limit_current) from price where c.id = price.coll_id)=0 then concat('Out of Stock – Book: ', c.name) -- Если все подвиды продукции с лимитом 0, то нет в наличии!
		 when (magnum_edition=1 and (signed<>'Signed' or signed is null)) then concat('Magnum Editions Book: ', c.name)
		 when (magnum_edition=1 and signed='Signed') then concat('Signed Magnum Editions Book: ', c.name)
		 when (tags='Rare Books' and (signed<>'Signed' or signed is null)) then concat('Rare Book: ', c.name)
		 when (tags='Rare Books' and  signed='Signed') then concat('Singned Rare Book: ', c.name)
 		 when (signed<>'Signed' or signed is null) then concat('Book: ', c.name)
 		 when signed='Signed' then concat('Signed Book: ', c.name)
	end as title,
p2.name as author,
(select min(price) from price where c.id = price.coll_id) as price,
edition,
(select if(magnum_edition=1, 'Magnum Editions', '')) as isMagnum,
signed,
(select url from coll_photos cp where cp.coll_id = c.id order by main desc limit 1) as url,
c.id
from collections c
join photographers p2 on c.author = p2.id
where `type`='Books'
order by rand(); -- сортировку делаем случайную.

/* Это Представление уже самого продукта, например,из категории Fine Prints:
https://www.magnumphotos.com/shop/collections/magnum-editions/magnum-editions-elizabeth-taylor-on-the-set-of-suddenly-last-sunmmer-1959/
Особенность лишь в том что в колонке Спецификация использую group_concat для того что бы в одной колонке разместить несколько строк из другой таблицы coll_specification
Получится такая спецификация в одном поле:
Age: Printed 2008
Digital Fibre Print
Edition of 100
Estate Stamped on recto
*/
drop view if exists current_print;
CREATE VIEW current_print as 
select
	case when (select avg(limit_current) from price where c.id = price.coll_id)=0 then concat('Out of Stock – Print: ', c.name) -- Если все подвиды продукции с лимитом 0, то нет в наличии!
		 when (magnum_edition=1 and (signed<>'Signed' or signed is null)) then concat('Magnum Editions Print: ', c.name)
		 when (magnum_edition=1 and signed='Signed') then concat('Signed Magnum Editions Print: ', c.name)
 		 when (signed<>'Signed' or signed is null) then concat('Print: ', c.name)
 		 when signed='Signed' then concat('Signed Print: ', c.name)
	end as title,
p2.name as author,
(select min(price) from price where c.id = price.coll_id) as price,
c.description,
c.special,
edition,
(select if(magnum_edition=1, 'Magnum Editions', '')) as isMagnum,
signed,
group_concat(distinct cs.content separator '\n') as specification,
(select url from coll_photos cp where cp.coll_id = c.id order by main desc limit 1) as url,
c.id
from collections c
join photographers p2 on c.author = p2.id
join coll_specification cs on c.id = cs.coll_id 
where `type`='Fine Prints'
group by c.id
order by p2.name;
