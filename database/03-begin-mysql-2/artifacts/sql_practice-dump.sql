/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.4.14-MariaDB, for linux-systemd (x86_64)
--
-- Host: localhost    Database: sql_practice
-- ------------------------------------------------------
-- Server version	11.4.14-MariaDB-log
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `city` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES
(1,'Иван Иванов','ivan@example.com','Москва','2026-11-21 19:44:17'),
(2,'Пётр Петров','petr@example.com','Санкт-Петербург','2026-11-21 19:44:17'),
(3,'Мария Сидорова','maria@example.com','Москва','2026-11-21 19:44:17'),
(4,'Алексей Смирнов','alex@example.com','Екатеринбург','2026-11-21 19:44:17'),
(5,'Ольга Кузнецова','olga@example.com','Новосибирск','2026-11-21 19:44:17');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `my_actions`
--

DROP TABLE IF EXISTS `my_actions`;
/*!50001 DROP VIEW IF EXISTS `my_actions`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `my_actions` AS SELECT
 NULL AS `event_time`,
 NULL AS `command_type`,
 NULL AS `argument` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `order_date` date NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` varchar(20) DEFAULT 'new',
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES
(1,1,'2026-10-01',1500.00,'paid'),
(2,1,'2026-10-05',2300.50,'paid'),
(3,2,'2026-10-03',800.00,'paid'),
(4,3,'2026-10-07',4200.00,'paid'),
(5,3,'2026-10-10',1100.00,'cancelled');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `my_actions`
--

/*!50001 DROP VIEW IF EXISTS `my_actions`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `my_actions` AS select `mysql`.`general_log`.`event_time` AS `event_time`,`mysql`.`general_log`.`command_type` AS `command_type`,convert(`mysql`.`general_log`.`argument` using utf8mb4) AS `argument` from `mysql`.`general_log` where `mysql`.`general_log`.`user_host` like '%root%' and `mysql`.`general_log`.`command_type` = 'Query' and `mysql`.`general_log`.`argument`  not like 'SET %' and `mysql`.`general_log`.`argument`  not like 'SHOW %' and `mysql`.`general_log`.`argument`  not like 'SELECT @@%' and `mysql`.`general_log`.`argument`  not like 'SELECT DATABASE()%' and `mysql`.`general_log`.`argument`  not like 'SELECT * FROM my_actions%' and `mysql`.`general_log`.`argument`  not like 'TRUNCATE TABLE mysql.general_log%' and `mysql`.`general_log`.`argument`  not like 'CREATE OR REPLACE VIEW my_actions%' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-11-21 22:44:18
