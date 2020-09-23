/*
 * Процедура выполняет обновление таблицы price в соответсвии с планом в таблице planned_price, если плановая дата равна текущей, и меняет статус в плане как выполненая,
 * обе операции - обновление прайса и обновление статуса в плане выполняются как одна транзакция, в случае ошибки - будет откат транзакции.
 */
drop procedure if exists price_scheduler;
delimiter //
create procedure price_scheduler()
comment 'Процедура выполняет обновление таблицы price в соответсвии с планом в таблице planned_price, если плановая дата равна текущей, и меняет статус в плане как выполненая(одна транзакция)'
begin
	declare isRollback bool default false; -- флаг отката

	DECLARE CONTINUE HANDLER FOR sqlexception
	begin
		SET isRollback = true; -- если произошло исключение
	end;

	/* Обновим цены из таблицы planned_price */
	start transaction;
	-- 'Обновляем <цены> в для продуктовых позиций из плана'
	update price, planned_price 
	set price.price=planned_price.price,
		price.price_frame=planned_price.price_frame 
	where price.id = planned_price.price_id and planned_price.change_at = CURRENT_DATE and planned_price.done = false;
	
	-- 'Установим статус <выполнено> в плане'
	update planned_price
	set planned_price.done = true 
	where planned_price.change_at = CURRENT_DATE and planned_price.done = false;
	
	if isRollback then
		rollback;
	else
		commit;
	end if;
	
	/* Обновим лимиты из таблицы planned_limit */
	SET isRollback = false;
	start transaction;
	-- 'Обновляем <лимиты> в для продуктовых позиций из плана'
	update price, planned_limit
	set price.limit_current=planned_limit.limit_current,
		price.limit_min=planned_limit.limit_min 
	where price.id = planned_limit.price_id and planned_limit.change_at = CURRENT_DATE and planned_limit.done = false;
	
	-- 'Установим статус <выполнено> в плане'
	update planned_limit
	set planned_limit.done = true
	where planned_limit.change_at = CURRENT_DATE and planned_limit.done = false;

	if isRollback then
		rollback;
	else
		commit;
	end if;

end;//
delimiter ;

-- Добавим в планы:
INSERT INTO planned_price (price_id,change_at,price) VALUES (1001,'2020-09-22',2060.0);
INSERT INTO planned_limit (price_id,change_at,limit_current,limit_min)  VALUES (833,'2020-09-22',32,5);
-- вызовем 
call price_scheduler();
-- проверим 
select * from price_history;
/*
13	2020-09-22 22:27:31.0	1001	other	2060.00				upd: price 
14	2020-09-22 22:27:31.0	833		other	6930.00		32	5	upd: limit_current 
 */

-- Добавим эту процедуру для запуска по Событию
-- см. файл Step-8-3-create_event.sql


