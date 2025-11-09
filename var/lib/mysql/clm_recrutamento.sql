/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.11-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: clm-recrutamento
-- ------------------------------------------------------
-- Server version	10.11.11-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `candidaturas`
--

DROP TABLE IF EXISTS `candidaturas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidaturas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome_completo` varchar(255) NOT NULL,
  `telemovel` varchar(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `caminho_cv` varchar(512) NOT NULL COMMENT 'Caminho relativo para o ficheiro do CV no servidor',
  `info_adicional` text DEFAULT NULL,
  `data_submissao` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidaturas`
--

LOCK TABLES `candidaturas` WRITE;
/*!40000 ALTER TABLE `candidaturas` DISABLE KEYS */;
INSERT INTO `candidaturas` VALUES
(1,'teste','123123123','teste@gmail.com','uploads/curriculos/6908dbecbebdf_5114-Ex6.pdf','123','2025-11-03 16:44:28'),
(2,'Constantino Das Bolas','1412414234','constantino@dasbolas.com','uploads/curriculos/6908e14f5ad68_5114-Ex6.pdf','q3et3e','2025-11-03 17:07:27'),
(3,'teste','123123123','teste@gmail.com','uploads/curriculos/6908ebc3f334f_GRSI0325-Horario-Nov25.pdf','123','2025-11-03 17:52:04'),
(4,'teste','12312312312','teste@gmail.com','uploads/curriculos/6908ef41cd3a4_GRSI0325-Horario-Nov25.pdf','123123123','2025-11-03 18:06:57'),
(5,'teste','123123213','teste@gmail.com','uploads/curriculos/6908fdbd4ef1f_WorksheetMOCKJOBINTERVIEWS.pdf','123','2025-11-03 19:08:45'),
(6,'teste','12312312312','godinmaj@gmail.com','uploads/curriculos/690928872d85f_ManualGuiadoTkinter.pdf','','2025-11-03 22:11:19'),
(7,'teste','123123123','teste@gmail.com','uploads/curriculos/6909e5ea23107_WorksheetMOCKJOBINTERVIEWS.pdf','123','2025-11-04 11:39:22');
/*!40000 ALTER TABLE `candidaturas` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-06 14:41:47
