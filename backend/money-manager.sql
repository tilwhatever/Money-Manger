-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Erstellungszeit: 08. Jun 2019 um 14:34
-- Server-Version: 10.1.40-MariaDB
-- PHP-Version: 7.1.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `money-manager`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `actions`
--

CREATE TABLE `actions` (
  `id` int(10) NOT NULL,
  `description` varchar(2000) NOT NULL,
  `amount` int(10) NOT NULL,
  `category` int(11) NOT NULL,
  `action` tinyint(1) NOT NULL,
  `day` int(2) NOT NULL,
  `month` int(2) NOT NULL,
  `year` int(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `actions`
--

INSERT INTO `actions` (`id`, `description`, `amount`, `category`, `action`, `day`, `month`, `year`) VALUES
(1, 'das ist eine beschreibugn', 100, 1, 0, 7, 6, 2019),
(5, 'ddd', 0, 1, 0, 7, 6, 2019),
(6, 'dddww', 0, 1, 0, 7, 6, 2019),
(7, 'dddwww', 0, 1, 0, 7, 6, 2019),
(8, 'dddwww', 0, 1, 0, 7, 6, 2019),
(9, 'dddwww', 0, 1, 0, 7, 6, 2019),
(10, 'dddwww', 0, 1, 0, 7, 6, 2019),
(11, 'hallo', 0, 1, 0, 7, 6, 2019),
(12, 'hallo', 0, 1, 0, 7, 6, 2019),
(13, 'Das ist ein Test', 0, 1, 0, 7, 6, 2019),
(14, 'muha', 0, 1, 0, 7, 6, 2019),
(15, '', 0, 1, 0, 7, 6, 2019),
(16, '', 0, 1, 0, 7, 6, 2019),
(17, 'muahaha', 0, 1, 0, 7, 6, 2019),
(18, 'opqdpoqwod', 100, 1, 0, 8, 6, 2019),
(19, 'dwd', 100, 1, 1, 8, 6, 2019),
(20, 'dwd', 100, 1, 1, 8, 7, 2019);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `category` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `categories`
--

INSERT INTO `categories` (`id`, `category`) VALUES
(1, 'Keine');

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `actions`
--
ALTER TABLE `actions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category` (`category`);

--
-- Indizes für die Tabelle `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `actions`
--
ALTER TABLE `actions`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT für Tabelle `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `actions`
--
ALTER TABLE `actions`
  ADD CONSTRAINT `actions_ibfk_1` FOREIGN KEY (`category`) REFERENCES `categories` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
