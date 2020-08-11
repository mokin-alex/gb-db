1. По реализованной сруктуре вроде все понятно.
Единственный вопрос, как будет организована работа с медифайлами?
В json будут записаны id медифайлов? в отдельной таблице будет путь до этого файла или будут в базе храниться?
(можно тогда добавить еще одну таблицу mediafiles)
и еще пришлось расширить поля для телефона:
ALTER TABLE snet0408.users MODIFY COLUMN phone varchar(17) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL;

2. Лайки. Создал еще три простых таблицы :
(как будем лайкать отдельныен медифайлы? по аналогии создать likes_media?)

```
create table likes_post (
	user_id bigint unsigned not null,
	liked_post_id bigint unsigned not null,
	primary key(user_id, liked_post_id),
	foreign key (user_id) references profiles(user_id),
	foreign key (liked_post_id) references posts(id)
);

create table likes_comment (
	user_id bigint unsigned not null,
	liked_comment_id bigint unsigned not null,
	primary key(user_id, liked_comment_id),
	foreign key (user_id) references profiles(user_id),
	foreign key (liked_comment_id) references comments(id)
);

create table likes_profile (
	user_id bigint unsigned not null,
	liked_profile_id bigint unsigned not null,
	primary key(user_id, liked_profile_id),
	foreign key (user_id) references profiles(user_id),
	foreign key (liked_profile_id) references profiles(id)
);
```

3) Генерация и загрузка тестовых данных. 
Ресурс filldb.info так и не позволил мне сгенерировать данные более чем для двух таблиц (users и comunities).
Пишет - Sucsesfull! Но данных не показывает!

Поэтому для генерации данных использовал mockaroo.com

Что бы поле created_at в ряде таблиц была всегда больше поля updated_at использовал конпку "формула" содержащая такой текст:
```
if this < created_at then created_at else this end
```
Для полей типа:	from_user_id и to_user_id использовал формулу random(1,100) или random(1,30) (для большей "кучности").
Очень удобно.

Сгенерировал SQL-запрос на добавление данных для каждой таблицы.

Дамп базы находится в maw_snet0408_dump.sql



