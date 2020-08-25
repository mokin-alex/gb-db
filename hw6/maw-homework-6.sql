-- 1.	Проанализировать запросы, которые выполнялись на занятии,
-- Без отключения режима ONLY_FULL_GROUP_BY некоторые запросы не выполнялись.
-- Отключил 
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
-- (и переподключился к базе) проверил:
select @@sql_mode;

/*
 * 2.	Пусть задан некоторый пользователь. 
	Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
 */
select name, max(total_msg) as maxtotalmsg from ( 
	select    --  подсчитаем ВСЕ сообщения от друзей:
		(select concat(name,' ',lastname) from profiles where user_id = from_user_id) as 'name', 
		count(*) as 'total_msg'
	from messages 
		where to_user_id = 1 
		and from_user_id in ( -- друзья:
			select target_user_id from friend_requests fr where initiator_user_id = to_user_id and status = 'approved'
			union 
			select initiator_user_id from friend_requests fr where target_user_id = to_user_id  and status = 'approved')
	group by from_user_id
) as the_most_sociable;

/*
 * 3.	Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
 */
-- Вначале найдем 10 самых молодых
select user_id , concat(name,' ',lastname) as name, timestampdiff(year, birthday, now()) as 'age', birthday from profiles 
order by birthday desc
limit 10;
-- сформируем список всех лайкнутых постов найденных пользователей:
select user_id, post_id from posts p2 
join likes_posts lp
	on p2.id = lp.post_id 
where user_id in ( -- 10 самых молодых:
	select user_id from profiles order by birthday desc limit 10
	);
-- SQL Error [1235] [42000]: This version of MySQL doesn't yet support 'LIMIT & IN/ALL/ANY/SOME subquery'

-- Придется 10 самых молодых поместить во временную таблицу и использовать ее в дальнейшем
CREATE TEMPORARY table youngest select user_id from profiles order by birthday desc limit 10;
-- select * from youngest;
-- Итак, сформируем список всех лайкнутых постов найденной 10-ки
select user_id, post_id from posts p2 
join likes_posts lp
	on p2.id = lp.post_id 
where user_id in (select user_id from youngest);
-- Общее количество лайков всех 10 самых молодых будет равно:
select count(*) as totallikes from posts p2 
join likes_posts lp
	on p2.id = lp.post_id 
where user_id in (select user_id from youngest);
-- totallikes = 982
-- Если подсчет будет осуществляться не только по таблице posts, то можно организовать запрос как в реализовано в Задании 5.


/*
 * 4.	Определить кто больше поставил лайков (всего) - мужчины или женщины?
 */
select gender , count(*) as total_likes from likes_posts lp 
join profiles p2 
	on lp.profile_id = p2.user_id 
group by gender
order by total_likes desc;
/*
gender	total_likes
f		10 046
m		7 388
*/

/*
 * 5.	Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
 */
select user_id as userid, count(*) as activity from posts group by userid order by activity;

-- Повторим для всех таблиц содержащих активность пользователя и запишем во временную таблицу:
CREATE TEMPORARY table activities
	select user_id as userid, count(*) as activity from posts group by userid order by activity; 
-- union
insert into activities (userid, activity) 
	select to_user_id as userid, count(*) as activity from reposts group by userid order by activity; 
-- union
insert into activities (userid, activity) 
	select from_user_id as userid, count(*) as activity from messages group by userid order by activity; 
-- union
insert into activities (userid, activity) 
	select user_id as userid, count(*) as activity from comments group by userid order by activity; 
-- union
insert into activities (userid, activity) 
	select profile_id as userid, count(*) as activity from likes_posts group by userid order by activity; 
-- union
insert into activities (userid, activity) 
	select initiator_user_id as userid, count(*) as activity from friend_requests group by userid order by activity;
-- union
insert into activities (userid, activity) 
	select target_user_id as userid, count(*) as activity from friend_requests group by userid order by activity; 
-- union
insert into activities (userid, activity) 
	select user_id as userid, count(*) as activity from users_communities group by userid order by activity; 
-- ИТАК:
-- Теперь посчитаем всю активность по каждому пользователю и найдем 10 минимальных значений (ASC), это и будет ответ задачи: 
select userid , concat(name,' ',lastname) as name, sum(activity) as total from activities 
left join profiles p2 
	on activities.userid = p2.user_id 
group by userid
order by total asc limit 10 offset 0;

/* ОТВЕТ на Задачу 5:
5	Дмитрий Тимашов	64
2	Вера Клюквина	83
1	Сергей Сергеев	89
8	Артем Филипцов	90
6	Владислав Авраменко	92
12	Дарья Попова	92
11	Евгений Грачев	93
17	Станислав Светляков	96
207	Галина Стрельникова	96
7	Алексей Величко	97
 */

-- ВАЖНО! в базе snet0408 таблица comments содержит очень много user_id, которых больше, чем пользователей в таблице users и profiles
-- поэтому я удалил комментарии несуществующих пользователей.
-- в этом случае решение получилось с ФИО пользователей, а не с пустышкой.  
-- select count(*) from comments c2 where user_id >210;
-- delete from comments where user_id >210;
