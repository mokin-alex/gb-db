/*
 * Создание триггеров.
 * В триггере №1 использовали значение OLD.tbl_name и исключения signal sqlstate для блокировки операции удаления.
 * В триггере №2 использовали значение NEW.tbl_name для логирования новых важных значений в позиции товара (price).
 * В триггере №3 использовали внутреннюю переменную txt, в которую соединяли (concat) названия "изменившихся" значений колонок перед операцией update.
 *   Так же используется оператор Null-безопасное сравнение, так как поля могут измениться с/на значение null.  
 * Все три триггера логировали инфо в таблицу архивного типа price_history, в колонке info - информации о произошедшем событии и наименованиях колонок подвергшиеся изменениям. 
 * (в этой таблце колонка changed_filds не используется совсем, но удалить ее уже не получается)  
 */

-- Триггер 1 запрещающий удаление записи ценовой позиции.
drop trigger if exists price_delete_block;
delimiter //
create trigger price_delete_block before delete on price
for each row
begin
	-- Триггер запрещающий удаление записи ценовой позиции.
	-- Записывает сообщение в историю и выдает пользователькое исключение.
		INSERT INTO price_history (price_id,info)
		VALUES (old.id, 'Attention! Attempt to delete!');
 		signal sqlstate '45000' set message_text = 'Delete Canceled.';
end;//
delimiter ;
-- Проверим:
delete from price 
where id=3000;
-- SQL Error [1644] [45000]: Delete Canceled.
select * from price_history;
/*
 * id	created_at				price_id	changed_filds	price	price_frame	limit_current	limit_min	info
 *  1	2020-09-22 09:49:06.0	3000		other															Attention! Attempt to delete!
*/

-- Триггер 2 логируем появление новой записи
drop trigger if exists price_insert_log;
delimiter //
create trigger price_insert_log after insert on price
for each row
begin
		-- Триггер 2 логируем появление новой записи в прайсе.
		INSERT INTO price_history (price_id, price, price_frame, limit_current, limit_min, info)
		VALUES (new.id, new.price, new.price_frame, new.limit_current, new.limit_min, 'new');
end;//
delimiter ;
--  Проверим:
INSERT INTO mawmagnum22.price (coll_id,variant,price,limit_current,limit_min)
	VALUES (818,'Size: 18 x 24 in (45.7 x 61 cm)',6390.0,15,8);
/* price_history:
 * id	created_at				price_id	changed_filds	price	price_frame	limit_current	limit_min	info
 * 1	2020-09-22 09:49:06.0	3000		other															Attention! Attempt to delete!
 * 2	2020-09-22 13:55:05.0	3000		other															Attention! Attempt to delete!
 * 3	2020-09-22 14:09:29.0	3001		other			6390.00					15				8		new
 */

-- Триггер 3 логируем обновление записи
drop trigger if exists price_update_log;
delimiter //
create trigger price_update_log before update on price
for each row
begin
		-- Триггер 3 логируем обновление записи
		-- причем записываем изменившиеся поля
		declare txt varchar(100) default 'upd: ';
		if not new.price<=>old.price then 
			set txt= concat(txt,'price ');
		end if;
		if not new.price_frame<=>old.price_frame then 
			set txt= concat(txt,'price_frame ');
		end if;
		if not new.limit_current<=>old.limit_current then 
			set txt= concat(txt,'limit_current ');
		end if;
		if not new.limit_min<=>old.limit_min then 
			set txt= concat(txt,'limit_min ');
		end if;
		if not new.variant<=>old.variant then 
			set txt= concat(txt,'variant ');
		end if;
		if not new.coll_id<=>old.coll_id then 
			set txt= concat(txt,'coll_id ');
		end if;
		-- логируем
		INSERT INTO price_history (price_id, price, price_frame, limit_current, limit_min, info)
		VALUES (new.id, new.price, new.price_frame, new.limit_current, new.limit_min, txt);
end;//
delimiter ;
-- Проверим:
UPDATE price SET price=6199.00 WHERE id=2998;
UPDATE price SET limit_current=14 WHERE id=2998;
UPDATE price SET price=5100,limit_min=5,limit_current=10 WHERE id=2998;
UPDATE price SET price=5100,limit_min=null,limit_current=10 WHERE id=2998;
--
select * from price_history;
/*
1	2020-09-22 09:49:06.0	3000	other					Attention! Attempt to delete!
2	2020-09-22 13:55:05.0	3000	other					Attention! Attempt to delete!
3	2020-09-22 14:09:29.0	3001	other	6390.00		15	8	new
4	2020-09-22 16:21:53.0	2998	other	6199.00		15	8	upd: price 
5	2020-09-22 16:23:20.0	2998	other	6199.00		14	6	upd: limit_current 
6	2020-09-22 16:30:32.0	2998	other	5100.00		10	5	upd: price limit_current limit_min 
7	2020-09-22 16:49:00.0	2998	other	5100.00		10		upd: limit_min 
 */
