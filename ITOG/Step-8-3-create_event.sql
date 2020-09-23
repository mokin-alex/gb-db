-- Добавим эту процедуру для запуска по Событию

show global variables like 'event_scheduler';
SET GLOBAL event_scheduler = ON; -- должно быть обязательно включено
-- 
drop event if exists run_price_scheduler;
--
CREATE EVENT run_price_scheduler
  ON SCHEDULE
    EVERY 1 DAY
    STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 11 minute)
  COMMENT 'запуск по расписанию процедуры обновления прайсов и лимитов из плановых таблиц'
  DO call price_scheduler();
  
 -- Добавим в планы на завтра:
INSERT INTO planned_price (price_id,change_at,price) VALUES (1001,'2020-09-23',2000.0);
INSERT INTO planned_limit (price_id,change_at,limit_current,limit_min)  VALUES (833,'2020-09-23',30,5);
-- проверим 
select * from price_history;
/*
id	created_at				price_id	changed_filds	price	price_frame	limit_current	limit_min	info
15	2020-09-23 00:11:00.0	1 001		other			2 000	[NULL]		[NULL]			[NULL]		upd: price 
16	2020-09-23 00:11:00.0	833			other			6 930	[NULL]		30				5			upd: limit_current 
*/
