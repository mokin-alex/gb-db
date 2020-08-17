create table likes_photo (
	user_id bigint unsigned not null,
	liked_photo_id bigint unsigned not null,
	create_at datetime default current_timestamp,
	primary key(user_id, liked_photo_id),
	foreign key (user_id) references profiles(user_id),
	foreign key (liked_photo_id) references photos(id)
);

drop table if exists reposts;

create table reposts (
	id serial primary key,
	post_id bigint unsigned not null,
	reposted_from bigint unsigned not null,
	reposted_to bigint unsigned not null,
	reposted_at datetime default current_timestamp,
	foreign key (post_id) references posts(id),
	foreign key (reposted_to) references profiles(user_id),
	foreign key (reposted_from) references profiles(user_id)
);

INSERT INTO users (email,phone,pass,created_at,visible_for,can_comment,can_message,invite_to_community) VALUES 
('dcolquita@ucla.edu','974-490-6651','1487c1cf7c24df739fc97460a2c791a2432df062','2020-08-08 01:09:59.0','all',1,'frends_of_friends','friends')
,('rthomazinb@ox.ac.uk','815-155-7164','32afa0b02c8399d1960509c3fbd4cc75ab4dcce2','2020-08-08 01:09:59.0','all',0,'friends','all')
,('gambridgec@sakura.ne.jp','290-726-6453','afd3e457d3b9f6f880623163ea8f72889777a58b','2020-08-08 01:09:59.0','all',1,'all','all')
,('mantosikd@tinypic.com','594-909-1863','9154186410a62369bdf4fd2bd632ca3511b270a7','2020-08-08 01:09:59.0','all',0,'frends_of_friends','frends_of_friends')
,('rtabere@admin.ch','696-647-1579','9bc443a6e52541784d52b69acc39343526886b11','2020-08-08 01:09:59.0','all',0,'all','friends')
,('ckendellf@bloglines.com','107-890-2682','229aedb0a417bccab3ee0cbd89a4b1afaa080c51','2020-08-08 01:09:59.0','all',0,'friends','all')
,('amckeandg@behance.net','964-292-2963','584b9241b06cfe87131bfdba7b53e877ec3bd940','2020-08-08 01:09:59.0','all',0,'all','all')
,('csantryh@mit.edu','311-847-3791','129797dcb95127ce0541faa8d91d8f1969da0f45','2020-08-08 01:09:59.0','all',0,'all','all')
,('dharcasei@dailymotion.com','456-819-8247','ea63b484704b7a8316da4025260b864453adb948','2020-08-08 01:09:59.0','all',0,'all','all')
,('drouthamj@senate.gov','925-942-8337','9b1f31426e9caf75d46b9b4a7c58c1941daa33f0','2020-08-08 01:09:59.0','all',0,'all','all')
;

delete from users where id>=105;
delete from users where email = 'mantosikd@tinypic.com';

update users 
set phone = concat('+7',' ',phone)
where id>100;

select distinct name from profiles;
select count(distinct name) from profiles; -- 99
select count(name) from profiles; -- 100
select name from profiles where name like 'An%';

select body from posts order by created_at limit 5 offset 3;
select id, user_id, body, created_at from posts where created_at >= '2020-01-01' and created_at <= '2020-06-30';

select user_id, count(*) as posts_total from posts group by user_id order by posts_total DESC;

-- и другие запросы...

