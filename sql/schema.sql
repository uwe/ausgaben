-- phpMyAdmin SQL Dump
-- version 3.3.2deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Erstellungszeit: 12. September 2010 um 20:56
-- Server Version: 5.1.41
-- PHP-Version: 5.3.2-1ubuntu4.2

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Datenbank: `ausgaben`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `betrag`
--

DROP TABLE IF EXISTS `betrag`;
CREATE TABLE IF NOT EXISTS `betrag` (
  `buchung_id` int(10) unsigned NOT NULL,
  `konto_id` int(10) unsigned NOT NULL,
  `betrag` int(11) NOT NULL,
  PRIMARY KEY (`buchung_id`,`konto_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `buchung`
--

DROP TABLE IF EXISTS `buchung`;
CREATE TABLE IF NOT EXISTS `buchung` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `datum` date NOT NULL,
  `kategorie_id` int(10) unsigned DEFAULT NULL,
  `ignorieren` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `haendler_id` int(10) unsigned DEFAULT NULL,
  `bemerkung` varchar(255) DEFAULT NULL,
  `verteilung_id` int(10) unsigned NOT NULL,
  `jaehrlich` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `reihenfolge` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `haendler`
--

DROP TABLE IF EXISTS `haendler`;
CREATE TABLE IF NOT EXISTS `haendler` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `kategorie`
--

DROP TABLE IF EXISTS `kategorie`;
CREATE TABLE IF NOT EXISTS `kategorie` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `konto`
--

DROP TABLE IF EXISTS `konto`;
CREATE TABLE IF NOT EXISTS `konto` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `reihenfolge` tinyint(3) unsigned NOT NULL,
  `anfangsbestand` int(11) NOT NULL,
  `verteilung_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `monat_haendler`
--

DROP TABLE IF EXISTS `monat_haendler`;
CREATE TABLE IF NOT EXISTS `monat_haendler` (
  `datum` date NOT NULL,
  `haendler_id` int(10) unsigned NOT NULL,
  `gesamt` int(11) NOT NULL,
  `ignoriert` int(11) NOT NULL,
  `jaehrlich` int(11) NOT NULL,
  PRIMARY KEY (`datum`,`haendler_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `monat_kategorie`
--

DROP TABLE IF EXISTS `monat_kategorie`;
CREATE TABLE IF NOT EXISTS `monat_kategorie` (
  `datum` date NOT NULL,
  `kategorie_id` int(10) unsigned NOT NULL,
  `gesamt` int(11) NOT NULL,
  `ignoriert` int(11) NOT NULL,
  `jaehrlich` int(11) NOT NULL,
  PRIMARY KEY (`datum`,`kategorie_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `monat_konto`
--

DROP TABLE IF EXISTS `monat_konto`;
CREATE TABLE IF NOT EXISTS `monat_konto` (
  `datum` date NOT NULL,
  `konto_id` int(10) unsigned NOT NULL,
  `gesamt` int(11) NOT NULL,
  `ignoriert` int(11) NOT NULL,
  `jaehrlich` int(11) NOT NULL,
  PRIMARY KEY (`datum`,`konto_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `monat_person`
--

DROP TABLE IF EXISTS `monat_person`;
CREATE TABLE IF NOT EXISTS `monat_person` (
  `datum` datetime NOT NULL,
  `person_id` int(10) unsigned NOT NULL,
  `gesamt` int(11) NOT NULL,
  `ignoriert` int(11) NOT NULL,
  `jaehrlich` int(11) NOT NULL,
  `anteil_gesamt` int(11) NOT NULL,
  `anteil_ignoriert` int(11) NOT NULL,
  `anteil_jaehrlich` int(11) NOT NULL,
  PRIMARY KEY (`datum`,`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `person`
--

DROP TABLE IF EXISTS `person`;
CREATE TABLE IF NOT EXISTS `person` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `verteilung`
--

DROP TABLE IF EXISTS `verteilung`;
CREATE TABLE IF NOT EXISTS `verteilung` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `anteil_gesamt` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `verteilung_person`
--

DROP TABLE IF EXISTS `verteilung_person`;
CREATE TABLE IF NOT EXISTS `verteilung_person` (
  `verteilung_id` int(10) unsigned NOT NULL,
  `person_id` int(10) unsigned NOT NULL,
  `anteil` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`verteilung_id`,`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
