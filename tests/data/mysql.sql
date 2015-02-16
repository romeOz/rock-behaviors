/**
 * This is the database schema for testing MySQL support of Rock DAO and Active Record.
 * The database setup in config.php is required to perform then relevant tests:
 */

DROP TABLE IF EXISTS `composite_fk` CASCADE;
DROP TABLE IF EXISTS `order_item` CASCADE;
DROP TABLE IF EXISTS `order_item_with_null_fk` CASCADE;
DROP TABLE IF EXISTS `item` CASCADE;
DROP TABLE IF EXISTS `order` CASCADE;
DROP TABLE IF EXISTS `order_with_null_fk` CASCADE;
DROP TABLE IF EXISTS `category` CASCADE;
DROP TABLE IF EXISTS `customer` CASCADE;
DROP TABLE IF EXISTS `profile` CASCADE;


CREATE TABLE `profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `customer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(128) NOT NULL,
  `name` varchar(128),
  `address` text,
  `status` int (11) DEFAULT 0,
  `profile_id` int(11),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_item_category_id` (`category_id`),
  CONSTRAINT `FK_item_category_id` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `order` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `created_at` int(11) NOT NULL,
  `total` decimal(10,0) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `FK_order_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `order_with_null_fk` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11),
  `created_at` int(11) NOT NULL,
  `total` decimal(10,0) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `order_item` (
  `order_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `subtotal` decimal(10,0) NOT NULL,
  PRIMARY KEY (`order_id`,`item_id`),
  KEY `FK_order_item_item_id` (`item_id`),
  CONSTRAINT `FK_order_item_order_id` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_order_item_item_id` FOREIGN KEY (`item_id`) REFERENCES `item` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `order_item_with_null_fk` (
  `order_id` int(11),
  `item_id` int(11),
  `quantity` int(11) NOT NULL,
  `subtotal` decimal(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `composite_fk` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `FK_composite_fk_order_item` FOREIGN KEY (`order_id`,`item_id`) REFERENCES `order_item` (`order_id`,`item_id`) ON DELETE CASCADE
);

INSERT INTO `profile` (description) VALUES ('profile customer 1');
INSERT INTO `profile` (description) VALUES ('profile customer 3');

INSERT INTO `customer` (email, name, address, status, profile_id) VALUES ('user1@example.com', 'user1', 'address1', 1, 1);
INSERT INTO `customer` (email, name, address, status) VALUES ('user2@example.com', 'user2', 'address2', 1);
INSERT INTO `customer` (email, name, address, status, profile_id) VALUES ('user3@example.com', 'user3', 'address3', 2, 2);

INSERT INTO `category` (name) VALUES ('Books');
INSERT INTO `category` (name) VALUES ('Movies');

INSERT INTO `item` (name, category_id) VALUES ('Monkey Island', 1);
INSERT INTO `item` (name, category_id) VALUES ('Full Throttle', 1);
INSERT INTO `item` (name, category_id) VALUES ('Ice Age', 2);
INSERT INTO `item` (name, category_id) VALUES ('Toy Story', 2);
INSERT INTO `item` (name, category_id) VALUES ('Cars', 2);

INSERT INTO `order` (customer_id, created_at, total) VALUES (1, 1325282384, 110.0);
INSERT INTO `order` (customer_id, created_at, total) VALUES (2, 1325334482, 33.0);
INSERT INTO `order` (customer_id, created_at, total) VALUES (2, 1325502201, 40.0);

INSERT INTO `order_with_null_fk` (customer_id, created_at, total) VALUES (1, 1325282384, 110.0);
INSERT INTO `order_with_null_fk` (customer_id, created_at, total) VALUES (2, 1325334482, 33.0);
INSERT INTO `order_with_null_fk` (customer_id, created_at, total) VALUES (2, 1325502201, 40.0);

INSERT INTO `order_item` (order_id, item_id, quantity, subtotal) VALUES (1, 1, 1, 30.0);
INSERT INTO `order_item` (order_id, item_id, quantity, subtotal) VALUES (1, 2, 2, 40.0);
INSERT INTO `order_item` (order_id, item_id, quantity, subtotal) VALUES (2, 4, 1, 10.0);
INSERT INTO `order_item` (order_id, item_id, quantity, subtotal) VALUES (2, 5, 1, 15.0);
INSERT INTO `order_item` (order_id, item_id, quantity, subtotal) VALUES (2, 3, 1, 8.0);
INSERT INTO `order_item` (order_id, item_id, quantity, subtotal) VALUES (3, 2, 1, 40.0);

INSERT INTO `order_item_with_null_fk` (order_id, item_id, quantity, subtotal) VALUES (1, 1, 1, 30.0);
INSERT INTO `order_item_with_null_fk` (order_id, item_id, quantity, subtotal) VALUES (1, 2, 2, 40.0);
INSERT INTO `order_item_with_null_fk` (order_id, item_id, quantity, subtotal) VALUES (2, 4, 1, 10.0);
INSERT INTO `order_item_with_null_fk` (order_id, item_id, quantity, subtotal) VALUES (2, 5, 1, 15.0);
INSERT INTO `order_item_with_null_fk` (order_id, item_id, quantity, subtotal) VALUES (2, 3, 1, 8.0);
INSERT INTO `order_item_with_null_fk` (order_id, item_id, quantity, subtotal) VALUES (3, 2, 1, 40.0);
