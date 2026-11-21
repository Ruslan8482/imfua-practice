/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.4.14-MariaDB, for linux-systemd (x86_64)
--
-- Host: localhost    Database: shop
-- ------------------------------------------------------
-- Server version	11.4.14-MariaDB-log
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `products1`
--

DROP TABLE IF EXISTS `products1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `products1` (
  `name` varchar(100) NOT NULL,
  `price` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products1`
--

LOCK TABLES `products1` WRITE;
/*!40000 ALTER TABLE `products1` DISABLE KEYS */;
INSERT INTO `products1` VALUES
('Дыни',800),
('Клубника',150),
('Яблоки',120),
('Лимоны',200);
/*!40000 ALTER TABLE `products1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products2`
--

DROP TABLE IF EXISTS `products2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `products2` (
  `name` varchar(100) NOT NULL,
  `price` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products2`
--

LOCK TABLES `products2` WRITE;
/*!40000 ALTER TABLE `products2` DISABLE KEYS */;
INSERT INTO `products2` VALUES
('Дыни',800),
('Клубника',150),
('Каштаны',200),
('Хурма',350);
/*!40000 ALTER TABLE `products2` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-11-21 22:44:18
