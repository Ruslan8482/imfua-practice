/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.4.14-MariaDB, for linux-systemd (x86_64)
--
-- Host: localhost    Database: fulltext_practice
-- ------------------------------------------------------
-- Server version	11.4.14-MariaDB-log
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `articles`
--

DROP TABLE IF EXISTS `articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `body` text NOT NULL,
  `author` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  FULLTEXT KEY `ft_articles` (`title`,`body`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `articles`
--

LOCK TABLES `articles` WRITE;
/*!40000 ALTER TABLE `articles` DISABLE KEYS */;
INSERT INTO `articles` VALUES
(1,'MySQL FULLTEXT search','MySQL provides full-text search capabilities. You can search for words in text columns using MATCH AGAINST syntax. FULLTEXT indexes are fast.','Иван','2026-11-21 19:44:24'),
(2,'MySQL replication','MySQL replication allows you to replicate data from one server to another. It is useful for backup and scaling. FULLTEXT search works well with replication.','Мария','2026-11-21 19:44:24'),
(3,'Optimizing MySQL queries','Query optimization is important for performance. Use indexes, EXPLAIN, and FULLTEXT search to speed up slow queries.','Пётр','2026-11-21 19:44:24'),
(4,'InnoDB full-text search','InnoDB supports FULLTEXT indexes since MySQL 5.6. InnoDB full-text search is crash-safe and does not have the 50% threshold that MyISAM has.','Ольга','2026-11-21 19:44:24'),
(5,'Boolean mode in MySQL','Boolean mode allows you to use operators like + (required), - (excluded), * (wildcard), and \"...\" (phrase) in FULLTEXT searches.','Алексей','2026-11-21 19:44:24');
/*!40000 ALTER TABLE `articles` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-11-21 22:44:24
