select profile_id, count(*) from photos p
group by profile_id 
;
select profile_id, count(*) from social_channels sc 
group by profile_id 
;

select `type`, `tags`, edition,	magnum_edition,	signed from collections c2
where (tags = 'Vintage Posters' or tags = 'Contemporary Posters')
and `type` not like 'Posters';
-- исправим
update collections 
set tags = null
where (tags = 'Vintage Posters' or tags = 'Contemporary Posters')
and `type` not like 'Posters';
-- Updated Rows	122
select `type`, `tags`, edition,	magnum_edition,	signed from collections c2
where (tags = 'Rare Books' or tags = 'Books with Prints')
and `type` not like 'Books';
-- исправим
update collections 
set tags = null
where (tags = 'Rare Books' or tags = 'Books with Prints')
and `type` not like 'Books';
-- Updated Rows	118
select `type`, `tags`, edition,	magnum_edition,	signed from collections c2
where 
(tags = 'Rare Books' or tags = 'Books with Prints')
and `type` = 'Books';
-- 
update collections 
set tags='Rare Books'
where id in(select * from (select id from collections where tags = 'Books with Prints' and `type` = 'Books' limit 10) as books);
-- 
select id, `type`, `tags`, edition,	magnum_edition,	signed from collections c2
where `type` = 'Books';		
-- слишком много книг сгенерировано (193), а их не более 89, исправим:
update collections 
set `type` = 'Fine Prints',
	`tags` = null
where `type`='Books' 
and id>444;
-- Updated Rows 108
-- 
select id, `type`, `tags`, edition,	magnum_edition,	signed from collections c2
where `type` = 'Objects';	
--
update collections 
set `type` = 'Contact Sheet Prints',
	`tags` = null
where `type` = 'Objects'
and (signed = 'Estate Stamped' or signed = 'Signed Print' or edition = 'Open edition')
;
-- Updated Rows	112
-- всё равно слишком много осталось,
update collections 
set `type` = 'Fine Prints',
	`tags` = null
where `type` = 'Objects'
and id>333;
-- 
select id, `type`, `tags`, edition,	magnum_edition,	signed from collections c2
where `type` = 'Posters';	
-- маловато постеров, изменим:
update collections 
set `type`='Posters'
where id in(select * from (
			select id from collections c2
			where `type` = 'Fine Prints'
			and id>333
			order by rand()
			limit 248) as fprints);
-- Updated Rows	248
update collections 
set `tags` = 'Contemporary Posters'
where `type` = 'Posters'			
and `tags` is null;
-- Updated Rows	310
select tags, count(*) from collections c 
group by tags;
-- 
update collections 
set `type` = 'Contact Sheet Prints',
	`tags` = null
where id in(select * from (select id from collections where `tags` = 'Contemporary Posters' order by rand() limit 40) as posters);
-- Updated Rows	40
select `type`, count(*) from collections c 
group by `type` ;
--
update collections 
set `type` = 'Fine Prints',
	`tags` = null
where id in(select * from (select id from collections where `type` = 'Contact Sheet Prints' order by rand() limit 49) as sheetprints);
/*
Objects	31
Books	73
Fine Prints	540
Posters	282
Contact Sheet Prints	74
*/
select magnum_edition , count(*) from collections c2 
group by magnum_edition ;
-- попадется null, а он не нужен: 
update collections 
set magnum_edition = false 
where magnum_edition is null;
-- Updated Rows	663

--
select c2.id, `type`, `tags`, edition,	magnum_edition,	signed, p2.id, p2.coll_id, p2.variant, p2.price, p2.price_frame, p2.limit_current, p2.limit_min from collections c2 
left join price p2 
on c2.id = p2.coll_id 
-- where `type` = 'Posters';	
-- where `type` = 'Objects'
where `type` = 'Books'
-- and p2.id<1001;	
-- and p2.id>1001;
;
--
update price 
set variant = null,
price_frame = null,
price = if(price>1000, round(price/100, 0), round(price/10, 0))
where id in(select * from (
	select p2.id from collections c2 
	left join price p2  on c2.id = p2.coll_id 
	where `type` = 'Objects' and p2.id<1001) as pricetbl
);

update price 
set coll_id = (SELECT ELT(FLOOR(RAND() * 10) + 1, 7,8,11,13,15,17,20,21,22,33) AS random_value_from_listOfValues)
where id IN(2856, 1274, 1446, 2160, 1803, 2999, 2939, 1279, 2149, 2332, 2654, 2794, 1965, 1287, 1364, 1385, 1391, 1972, 2195, 2694, 1015, 1271, 2027, 2630, 2828, 1087, 1048, 2397, 2188, 2292, 2430, 2639, 2551, 2151, 1708, 2080, 2356, 2392, 2389, 1263, 1761, 2317, 1369, 1697, 2162, 1266, 2390, 2466, 2500, 2801, 2073, 2740, 1013, 1608, 2411, 1144, 2660, 2125, 2673, 1747, 2898)
-- where id = 2856
;

select id, `type`, `tags`, edition,	magnum_edition,	signed from collections c2
where (`type` = 'Fine Prints' or `type` = 'Posters')
order by rand()
limit 10;

update price 
set variant = null,
price_frame = null,
price = if(price>1000, round(price/100, 0), round(price/10, 0))
where id in(select * from (
	select p2.id from collections c2 
	left join price p2  on c2.id = p2.coll_id 
	where `type` = 'Books' and p2.id<1001) as pricetbl
);

update price 
set coll_id = (SELECT ELT(FLOOR(RAND() * 10) + 1, 101,102,104,106,112,115,116,123,21,22,33) AS random_value_from_listOfValues)
where id in(select * from (
	select p2.id from collections c2 
	left join price p2  on c2.id = p2.coll_id 
	where `type` = 'Books' and p2.id>1001) as pricetbl
);
-- Updated Rows	147

-- все where `type` = 'Contact Sheet Prints' - это магнум коллекция:
update collections 
set magnum_edition = true 
where `type` = 'Contact Sheet Prints';
-- Updated Rows	74

-- вся магнум коллекция имеет один вариант печати + в рамке, поправим прайс
select c2.id, `type`, `tags`, edition,	magnum_edition,	signed, p2.id, p2.coll_id, p2.variant, p2.price, p2.price_frame, p2.limit_current, p2.limit_min from collections c2 
left join price p2 
on c2.id = p2.coll_id 
where (`type` <> 'Books' and `type` <> 'Objects')
and p2.id<1001
and c2.magnum_edition = true
-- and p2.id>1000;
;
-- 'Print only - 8 x 10 in (20.32 x 25.4 cm)'
update price 
set variant = 'Print only - 8 x 10 in (20.32 x 25.4 cm)',
price_frame = price+148
where id in(select * from (
	select p2.id from collections c2 
	left join price p2  on c2.id = p2.coll_id 
	where (`type` <> 'Books' and `type` <> 'Objects')
	and p2.id<1001
	and c2.magnum_edition = true) as pricetbl
);
-- Updated Rows	215

select c2.id, `type`, `tags`, edition,	magnum_edition,	signed, p2.id, p2.coll_id, p2.variant, p2.price, p2.price_frame, p2.limit_current, p2.limit_min from collections c2 
left join price p2 
on c2.id = p2.coll_id 
where (`type` <> 'Books' and `type` <> 'Objects')
and c2.magnum_edition = true
and p2.id>1000;
--
select id, `type`, `tags`, edition,	magnum_edition,	signed from collections c2
where (`type` = 'Fine Prints' or `type` = 'Posters') and magnum_edition = false 
order by rand()
limit 11;
-- 
update price 
-- set coll_id = (SELECT ELT(FLOOR(RAND() * 10) + 1, 720,922,254,323,487,160,685,794,621,633,831) AS random_value_from_listOfValues)
-- set coll_id = (SELECT ELT(FLOOR(RAND() * 10) + 1, 292, 571, 143, 65, 607, 371, 100, 490, 554, 822, 344) AS random_value_from_listOfValues)
-- set coll_id = (SELECT ELT(FLOOR(RAND() * 10) + 1, 783,584,452,388,361,855,469,245,997,902,662) AS random_value_from_listOfValues)
set coll_id = (SELECT ELT(FLOOR(RAND() * 10) + 1, 101,126,775,26,853,703,163,284,371,374,816) AS random_value_from_listOfValues)
where id in(select * from (
select p2.id from collections c2 
left join price p2 
on c2.id = p2.coll_id 
where (`type` <> 'Books' and `type` <> 'Objects')
and c2.magnum_edition = true
and p2.id>1000 limit 100) as pricetbl);

update price 
set price_frame = null 
where id>1000;
-- 
update price 
set price_frame = null
where id<1000 and variant <> 'Print only - 8 x 10 in (20.32 x 25.4 cm)' and price_frame is not null;
-- Updated Rows	146
update price 
set variant = '20 x 24 in (50 x 60 cm)'
where id>1000 and variant = 'Print only - 8 x 10 in (20.32 x 25.4 cm)'; -- такое значение только у магнум-коллекции, уберм лишнее.
-- Updated Rows	115

update price 
set limit_current = 100, limit_min = 15
where id in(select * from (
	select p2.id from collections c2 
	left join price p2 
	on c2.id = p2.coll_id 
	where c2.edition = 'Limited edition'
	and p2.limit_current is null ) as pricetbl);
-- Updated Rows	533
update price 
set limit_current = null, limit_min = null
where id in(select * from (
	select p2.id from collections c2 
	left join price p2 
	on c2.id = p2.coll_id 
	where c2.edition = 'Open edition') as pricetbl);
-- Updated Rows	1166

-- стоимость продуктов в заказах не соответсвует текущему прайсу (это возможно если прайс изменился), но неудобно...
	select op.id, op.cost, p.id, price from order_products op 
	join price p 
	on p.id = op.product_id
	order by p.id;

-- приведем стоимость товара в соответсвие с его прайсом:
update order_products, (
	select p.id, p.price from order_products op 
	join price p 
	on p.id = op.product_id
	order by p.id) as coprice
set order_products.cost = coprice.price
where order_products.product_id=coprice.id;
-- Updated Rows	2500

select group_concat(id) from collections c where signed = 'Signed Print';
-- 7,9,20,25,31,35,36,49,50,53,55,66,76,77,79,84,87,88,91,93,97,100,101,103,118,123,134,135,138,156,164,169,172,185,191,192,206,209,211,217,219,225,229,233,239,246,247,257,260,275,283,295,301,306,308,312,314,317,320,322,330,336,343,348,352,356,358,390,398,403,412,416,420,425,428,431,451,453,454,455,475,476,488,489,499,500,503,513,515,518,521,533,538,546,549,551,558,573,590,595,600,602,613,627,631,644,664,676,678,682,687,690,694,717,718,735,737,742,746,760,761,762,776,783,789,791,793,818,819,820,821,823,824,827,833,837,844,846,859,870,876,882,883,900,901,903,904,917,918,936,944,959,963,969,971,979,998
update collections 
set signed = 'Signed'
where signed = 'Signed Print';
-- Updated Rows	157

--  Auto-generated SQL script #202009212306
UPDATE mawmagnum21.coll_photos
	SET url='https://www.magnumphotos.com/shop/wp-content/uploads/2020/05/MPRINT-GLB-NYC6465-FRAME-BL.jpg'
	WHERE id=315;
UPDATE mawmagnum21.coll_photos
	SET url='https://www.magnumphotos.com/shop/wp-content/uploads/2020/05/MPRINT-GLB-NYC6465-FRAME-WH.jpg',main=0
	WHERE id=540;
UPDATE mawmagnum21.coll_photos
	SET url='https://www.magnumphotos.com/shop/wp-content/uploads/2020/05/MPRINT-GLB-NYC6465.jpg',main=1
	WHERE id=1539;
UPDATE mawmagnum21.coll_photos
	SET url='https://www.magnumphotos.com/shop/wp-content/uploads/2020/05/MPRINT-GLB-NYC6465-FRAME-BL-Room.jpg'
	WHERE id=1747;



