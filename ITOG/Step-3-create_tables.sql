CREATE database mawmagnum;
USE mawmagnum;

drop table if EXISTS `photographers`;
CREATE TABLE `photographers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `birthday` date NOT NULL,
  `native` varchar(30) NOT NULL COMMENT 'Происхождение/национальность',
  `based_in` varchar(100) NOT NULL COMMENT 'Где проживает сейчас',
  `bio` text NOT NULL COMMENT 'Биография фотографа',
  `quote` text COMMENT 'Цитата/высказывание',
  `status` enum('Found member','Member','Contributer') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'Member' COMMENT 'позиция в клубе',
  `works` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Доступен для работы по заказу',
  `died_at` date DEFAULT NULL,
  `userpic` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'URL user picture',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `id` (`id`),
  KEY `photographers_name_IDX` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='профиль фотографа';

drop table if EXISTS `photos`;
CREATE TABLE `photos` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `profile_id` bigint unsigned NOT NULL,
  `url` varchar(255) NOT NULL COMMENT 'URL размещения фотографии',
  `filename` varchar(50) DEFAULT NULL COMMENT 'имя файла загруженного ',
  `title` varchar(255) NOT NULL COMMENT 'Название фотографии',
  `place` varchar(50) NOT NULL COMMENT 'Страна, где была сделана фото',
  `year` date DEFAULT NULL COMMENT 'Год создания фотографии',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `photos_FK` (`profile_id`),
  CONSTRAINT `photos_FK` FOREIGN KEY (`profile_id`) REFERENCES `photographers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='фотографии фотографов';

drop table if EXISTS `social_channels`;
CREATE TABLE `social_channels` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `profile_id` bigint unsigned NOT NULL,
  `type` enum('instagram','twitter','fb') NOT NULL COMMENT 'поддерживаемые соц.сети',
  `url` varchar(255) NOT NULL COMMENT 'ссылка на соц.сеть',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `social_channels_FK` (`profile_id`),
  CONSTRAINT `social_channels_FK` FOREIGN KEY (`profile_id`) REFERENCES `photographers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='социальные сети фотографа';

drop table if EXISTS `collections`;
CREATE TABLE `collections` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `type` enum('Books','Contact Sheet Prints','Fine Prints','Posters','Objects') NOT NULL COMMENT 'Вид продукции',
  `tags` varchar(50) DEFAULT NULL COMMENT 'подтип, например винтажный или современный постер',
  `name` varchar(255) NOT NULL COMMENT 'Наименование работы',
  `author` bigint unsigned NOT NULL COMMENT 'ссылка на профиль фотографа',
  `description` text NOT NULL COMMENT 'Описание процукции',
  `special` text COMMENT 'Уточнения, пояснения от продавца',
  `edition` enum('Limited edition','Open edition') DEFAULT NULL COMMENT 'Неограниченная либо ограниченная серия',
  `magnum_edition` tinyint(1) DEFAULT '0' COMMENT 'Специальная магнум-редакция',
  `signed` enum('Signed','Estate Stamped') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'Неподписан, подписан лично, принт подписи, штамп владельца',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `collections_FK` (`author`),
  KEY `collections_type_IDX` (`type`) USING BTREE,
  KEY `collections_edition_IDX` (`edition`) USING BTREE,
  KEY `collections_signed_IDX` (`signed`) USING BTREE,
  CONSTRAINT `collections_FK` FOREIGN KEY (`author`) REFERENCES `photographers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='коллекция продукции магазина';
-- ALTER TABLE collections ADD CONSTRAINT collections_FK FOREIGN KEY (author) REFERENCES photographers(id) ON DELETE CASCADE ON UPDATE CASCADE;

drop table if EXISTS `coll_specification`;
CREATE TABLE `coll_specification` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `coll_id` bigint unsigned NOT NULL COMMENT 'ссылка на продукцию',
  `content` text NOT NULL COMMENT 'Произвольня спецификация (может быть несколько у одной и того и того же продукта)',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `coll_specification_FK` (`coll_id`),
  CONSTRAINT `coll_specification_FK` FOREIGN KEY (`coll_id`) REFERENCES `collections` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Спецификация к конкретной продукции коллекции, как правило несколько строк (позиций)';

drop table if EXISTS `coll_photos`;
CREATE TABLE `coll_photos` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `coll_id` bigint unsigned NOT NULL COMMENT 'ссылка на продукцию',
  `filename` varchar(50) DEFAULT NULL COMMENT 'имя файла загруженного ',
  `url` varchar(255) NOT NULL COMMENT 'URL размещения фотографии',
  `main` tinyint(1) DEFAULT '0' COMMENT 'основное изображение',
  `optional` enum('black','white','other') DEFAULT NULL COMMENT 'опция: для пометки фотографии в рамке черной или белой',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `coll_photos_FK` (`coll_id`),
  CONSTRAINT `coll_photos_FK` FOREIGN KEY (`coll_id`) REFERENCES `collections` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Фотографии (может быть несколько) конкретной продукции';

drop table if EXISTS `price`;
CREATE TABLE `price` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `coll_id` bigint unsigned NOT NULL COMMENT 'ссылка на продукцию',
  `variant` varchar(100) DEFAULT NULL COMMENT 'возможные варианты продукта-цена, например разный размер отпечатка',
  `price` decimal(10,2) NOT NULL COMMENT 'цена обычная',
  `price_frame` decimal(10,2) DEFAULT NULL COMMENT 'цена той же продукции, но в специальной рамке',
  `limit_current` int unsigned DEFAULT NULL COMMENT 'ограничение по количеству, 0 - не продается, null - без ограничения, значение может уменьшаться до 0',
  `limit_min` int unsigned DEFAULT NULL COMMENT 'минимальное значение текущего лемита, ниже которого может быть автоматически изменена цена',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `price_FK` (`coll_id`),
  CONSTRAINT `price_FK` FOREIGN KEY (`coll_id`) REFERENCES `collections` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Цена';

drop table if exists `planned_price`;
CREATE TABLE `planned_price` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `price_id` bigint unsigned NOT NULL COMMENT 'ссылка на ценовую позицию',
  `change_at` date NOT NULL COMMENT 'изменения на дату',
  `price` decimal(10,2) NOT NULL COMMENT 'новая цена обычная',
  `price_frame` decimal(10,2) DEFAULT NULL COMMENT 'новая цена той же продукции, но в специальной рамке',
  `done` tinyint(1) DEFAULT '0' COMMENT 'состояние выполения',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `planned_price_price_id_IDX` (`price_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Запланированное изменение ценовой позиции';

drop table if exists `planned_limit`;
CREATE TABLE `planned_limit` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `price_id` bigint unsigned NOT NULL COMMENT 'ссылка на ценовую позицию',
  `change_at` date NOT NULL COMMENT 'изменения на дату',
  `limit_current` int unsigned DEFAULT NULL COMMENT 'новая текущий лимит',
  `limit_min` int unsigned DEFAULT '0' COMMENT 'новый мин.лимит при котором может произойти автоизменение цены',
  `done` tinyint(1) DEFAULT '0' COMMENT 'состояние выполения',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `planned_limit_price_id_IDX` (`price_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Запланированное изменение лимитов ценовой позиции';

CREATE TABLE `price_history` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `price_id` bigint unsigned NOT NULL,
  `changed_filds` enum('prices','limits','other') DEFAULT 'other' COMMENT 'что меняли',
  `price` decimal(10,2) DEFAULT NULL COMMENT 'новое значение',
  `price_frame` decimal(10,2) DEFAULT NULL COMMENT 'новое значение',
  `limit_current` int unsigned DEFAULT NULL COMMENT 'новое значение',
  `limit_min` int unsigned DEFAULT NULL COMMENT 'новое значение',
  UNIQUE KEY `id` (`id`)
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='АРХИВНАЯ ТАБЛИЦА: история изменений в таблице price';


drop table if exists users; 
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `first_name` varchar(25) DEFAULT NULL,
  `last_name` varchar(25) DEFAULT NULL,
  `isAdm` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='покупатели, оформляющие заказ';


drop table if exists orders;
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `order_number` varchar(10) NOT NULL DEFAULT 'ord0000000',
  `status` enum('new','cancelled','paid','delivered') DEFAULT 'new',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `orders_user_id_IDX` (`user_id`) USING BTREE,
  KEY `orders_status_IDX` (`status`) USING BTREE,
  CONSTRAINT `orders_FK` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Заказ: его состояние, покупатель';

drop table if exists order_products;
CREATE TABLE `order_products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL COMMENT 'ссылка на Заказ',
  `product_id` bigint unsigned NOT NULL COMMENT 'ссылка на текущий продукт - price',
  `cost` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Стоимость на момент покупки',
  `quantity` int unsigned NOT NULL DEFAULT '1' COMMENT 'Количество',
  `total` decimal(10,2) as (`cost`*`quantity`) COMMENT 'суммарная стоимость по данной продукции',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_products_order_id_IDX` (`order_id`) USING BTREE,
  KEY `order_products_product_id_IDX` (`product_id`) USING BTREE,
  CONSTRAINT `order_products_FK` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `order_products_FK_1` FOREIGN KEY (`product_id`) REFERENCES `price` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Продукция в заказе: стоимость, количество и итог по данной позиции';
