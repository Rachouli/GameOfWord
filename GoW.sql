-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Client: localhost
-- Généré le: Sam 28 Novembre 2015 à 13:41
-- Version du serveur: 5.5.46-MariaDB-1ubuntu0.14.04.2-log
-- Version de PHP: 5.5.9-1ubuntu4.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `GoW`
--

-- --------------------------------------------------------

--
-- Structure de la table `arbitrage`
--

CREATE TABLE IF NOT EXISTS `arbitrage` (
  `arbitrageID` int(11) NOT NULL AUTO_INCREMENT,
  `enregistrementID` int(11) NOT NULL,
  `idDruide` int(11) NOT NULL,
  `tpsArbitrage` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `validation` enum('valid','invalid') CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`arbitrageID`),
  KEY `validation` (`validation`),
  KEY `enregistrementID` (`enregistrementID`),
  KEY `idDruide` (`idDruide`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `cartes`
--

CREATE TABLE IF NOT EXISTS `cartes` (
  `idCarte` int(16) unsigned NOT NULL AUTO_INCREMENT COMMENT 'identifiant',
  `langue` varchar(3) NOT NULL COMMENT 'la langue de la carte (ISO 639)',
  `extLangue` varchar(16) DEFAULT NULL COMMENT 'extension de langue (IETF)',
  `niveau` enum('A1','A1.1','A1.2','A2','B1','B2','C1','C2') NOT NULL COMMENT 'Niveau CECRL',
  `categorie` enum('nom','nom propre','pronom','adjectif','adverbe','verbe','expression idiomatique') DEFAULT NULL COMMENT 'Une catégorie qui pourra être une aide',
  `idDruide` int(16) unsigned NOT NULL COMMENT 'auteur',
  `mot` varchar(128) NOT NULL,
  `dateCreation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dateSuppression` timestamp NULL DEFAULT NULL,
  `idEraser` int(16) DEFAULT NULL COMMENT 'Id de la personne qui a supprimé la carte',
  PRIMARY KEY (`idCarte`),
  KEY `idDruide` (`idDruide`),
  KEY `langue` (`langue`),
  KEY `idEraser` (`idEraser`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Les cartes, attention nécessitent jointures' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `coeff_niveau_langue`
--

CREATE TABLE IF NOT EXISTS `coeff_niveau_langue` (
  `niveau_langue` enum('Débutant','Intermédiaire','Avancé','Natif') CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `coeff` float NOT NULL,
  UNIQUE KEY `niveau_langue_2` (`niveau_langue`),
  KEY `niveau_langue` (`niveau_langue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `coeff_niveau_langue`
--

INSERT INTO `coeff_niveau_langue` (`niveau_langue`, `coeff`) VALUES
('Débutant', 1.5),
('Intermédiaire', 1.2),
('Avancé', 1),
('Natif', 0.5);

-- --------------------------------------------------------

--
-- Structure de la table `coeff_statut`
--

CREATE TABLE IF NOT EXISTS `coeff_statut` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coeff` float NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Contenu de la table `coeff_statut`
--

INSERT INTO `coeff_statut` (`id`, `coeff`) VALUES
(1, 1),
(2, 1.25),
(3, 1.5);

-- --------------------------------------------------------

--
-- Structure de la table `enregistrement`
--

CREATE TABLE IF NOT EXISTS `enregistrement` (
  `enregistrementID` int(11) NOT NULL AUTO_INCREMENT,
  `cheminEnregistrement` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `idOracle` int(30) NOT NULL,
  `OracleLang` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `nivpartie` enum('easy','medium','hard') NOT NULL DEFAULT 'easy' COMMENT 'niveau de la partie oracle',
  `tpsEnregistrement` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `carteID` int(11) NOT NULL,
  `nivcarte` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `validation` enum('valid','invalid','limbo') CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'limbo',
  `duration` tinyint(3) unsigned NOT NULL COMMENT 'the length in seconds of the recording (max 255 sec)',
  PRIMARY KEY (`enregistrementID`),
  UNIQUE KEY `cheminEnregistrement` (`cheminEnregistrement`),
  KEY `idOracle` (`idOracle`),
  KEY `carteID` (`carteID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `game_lvl`
--

CREATE TABLE IF NOT EXISTS `game_lvl` (
  `userlvl` enum('easy','medium','hard') CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'easy',
  `time` int(8) NOT NULL DEFAULT '0',
  `points` int(8) NOT NULL DEFAULT '0',
  `pointsSanction` int(8) NOT NULL DEFAULT '0',
  PRIMARY KEY (`userlvl`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `game_lvl`
--

INSERT INTO `game_lvl` (`userlvl`, `time`, `points`, `pointsSanction`) VALUES
('easy', 90, 10, 0),
('medium', 60, 20, 0),
('hard', 45, 40, 0);

-- --------------------------------------------------------

--
-- Structure de la table `mots_interdits`
--

CREATE TABLE IF NOT EXISTS `mots_interdits` (
  `idCarte` int(16) NOT NULL COMMENT 'le mot auquel il se rapporte',
  `mot` varchar(48) NOT NULL COMMENT 'le mot interdit',
  `ordre` int(4) NOT NULL COMMENT 'l''ordre du mot interdit',
  UNIQUE KEY `idCarte` (`idCarte`,`mot`),
  UNIQUE KEY `idCarte_2` (`idCarte`,`ordre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Liste des mots tabous pour un mot';

-- --------------------------------------------------------

--
-- Structure de la table `notif`
--

CREATE TABLE IF NOT EXISTS `notif` (
  `userid` int(11) NOT NULL,
  `message` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `emetteur` int(11) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` int(11) NOT NULL,
  `game` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `time` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `parties`
--

CREATE TABLE IF NOT EXISTS `parties` (
  `partieID` int(11) NOT NULL AUTO_INCREMENT,
  `enregistrementID` int(11) NOT NULL,
  `tpsDevin` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `idDevin` int(11) NOT NULL,
  `tpsdejeu` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `reussie` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`partieID`),
  KEY `enregistrementID` (`enregistrementID`),
  KEY `idDevin` (`idDevin`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `sanctionCarte`
--

CREATE TABLE IF NOT EXISTS `sanctionCarte` (
  `idDevin` int(11) NOT NULL,
  `enregistrementID` int(11) NOT NULL,
  UNIQUE KEY `idDevin` (`idDevin`,`enregistrementID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `score`
--

CREATE TABLE IF NOT EXISTS `score` (
  `scoreID` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(100) NOT NULL,
  `scoreGlobal` int(100) NOT NULL,
  `scoreOracle` int(100) NOT NULL,
  `scoreDruide` int(100) NOT NULL,
  `scoreDevin` int(100) NOT NULL,
  `langue` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `first_game_time` text NOT NULL,
  PRIMARY KEY (`scoreID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `themes`
--

CREATE TABLE IF NOT EXISTS `themes` (
  `idTheme` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `themeFR` varchar(64) NOT NULL COMMENT 'la traductions ce sera pour plus tard',
  PRIMARY KEY (`idTheme`),
  UNIQUE KEY `themeFR` (`themeFR`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='liste des thèmes' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `themes_cartes`
--

CREATE TABLE IF NOT EXISTS `themes_cartes` (
  `idCarte` int(16) NOT NULL,
  `idTheme` int(8) NOT NULL,
  UNIQUE KEY `idCarte` (`idCarte`,`idTheme`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Table de jointure';

-- --------------------------------------------------------

--
-- Structure de la table `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `userid` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(32) NOT NULL,
  `useremail` varchar(100) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `userpass` varchar(32) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `userlang` varchar(32) NOT NULL,
  `valkey` varchar(100) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `userlang_game` varchar(100) NOT NULL,
  `photo` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `userlvl` varchar(40) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`userid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;

-- --------------------------------------------------------

--
-- Structure de la table `user_niveau`
--

CREATE TABLE IF NOT EXISTS `user_niveau` (
  `id` int(50) NOT NULL AUTO_INCREMENT,
  `userid` int(50) NOT NULL,
  `spoken_lang` varchar(100) NOT NULL,
  `niveau` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;


-- --------------------------------------------------------
-- --------------------------------------------------------
-- --------------------------------------------------------
-- créer admin:admin pour les cartes existantes

INSERT INTO `user` (`userid`, `username`, `useremail`, `userpass`, `userlang`, `valkey`, `userlang_game`, `photo`, `userlvl`) VALUES
(1, 'admin', 'your.email@mail.you', '21232f297a57a5a743894a0e4a801fc3', 'fr', '', 'fr', '', 'easy');
INSERT INTO `user_niveau` (`id`, `userid`, `spoken_lang`, `niveau`) VALUES
(1, 1, 'Français;', 'Natif;');
INSERT INTO `score` (`scoreID`, `userid`, `scoreGlobal`, `scoreOracle`, `scoreDruide`, `scoreDevin`, `langue`, `first_game_time`) VALUES
(1, 1, 0, 0, 0, 0, 'Français', '');

-- --------------------------------------------------------

--
-- Structure de la table `langues`
--

CREATE TABLE IF NOT EXISTS `langues` (
  `iso_code` varchar(3) CHARACTER SET utf8 NOT NULL COMMENT 'iso language code',
  `french` varchar(16) CHARACTER SET utf8 NOT NULL COMMENT 'nom de la langue en FR',
  `english` varchar(16) CHARACTER SET utf8 DEFAULT NULL COMMENT 'language name in English',
  PRIMARY KEY (`iso_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `langues`
--

INSERT INTO `langues` (`iso_code`, `french`, `english`) VALUES
('aa', 'Afar', NULL),
('ab', 'Abkhaze', NULL),
('ae', 'Avestique', NULL),
('af', 'Afrikaans', NULL),
('ak', 'Akan', NULL),
('am', 'Amharique', NULL),
('an', 'Aragonais', NULL),
('ar', 'Arabe', NULL),
('as', 'Assamais', NULL),
('av', 'Avar', NULL),
('ay', 'Aymara', NULL),
('az', 'Azéri', NULL),
('ba', 'Bachkir', NULL),
('be', 'Biélorusse', NULL),
('bg', 'Bulgare', NULL),
('bh', 'Bihari', NULL),
('bi', 'Bichelamar', NULL),
('bm', 'Bambara', NULL),
('bn', 'Bengali', NULL),
('bo', 'Tibétain', NULL),
('br', 'Breton', NULL),
('bs', 'Bosnien', NULL),
('ca', 'Catalan', NULL),
('ce', 'Tchétchène', NULL),
('ch', 'Chamorro', NULL),
('co', 'Corse', NULL),
('cr', 'Cri', NULL),
('cs', 'Tchèque', NULL),
('cu', 'Vieux-slave', NULL),
('cv', 'Tchouvache', NULL),
('cy', 'Gallois', NULL),
('da', 'Danois', NULL),
('de', 'Allemand', NULL),
('dv', 'Maldivien', NULL),
('dz', 'Dzongkha', NULL),
('ee', 'Ewe', NULL),
('el', 'Grec moderne', NULL),
('en', 'Anglais', 'English'),
('eo', 'Espéranto', NULL),
('es', 'Espagnol', NULL),
('et', 'Estonien', NULL),
('eu', 'Basque', NULL),
('fa', 'Persan', NULL),
('ff', 'Peul', NULL),
('fi', 'Finnois', NULL),
('fj', 'Fidjien', NULL),
('fo', 'Féroïen', NULL),
('fr', 'Français', NULL),
('fy', 'Frison', NULL),
('ga', 'Irlandais', NULL),
('gd', 'Écossais', NULL),
('gl', 'Galicien', NULL),
('gn', 'Guarani', NULL),
('gu', 'Gujarati', NULL),
('gv', 'Mannois', NULL),
('ha', 'Haoussa', NULL),
('he', 'Hébreu', NULL),
('hi', 'Hindi', NULL),
('ho', 'Hiri motu', NULL),
('hr', 'Croate', NULL),
('ht', 'Créole haïtien', NULL),
('hu', 'Hongrois', NULL),
('hy', 'Arménien', NULL),
('hz', 'Héréro', NULL),
('ia', 'Interlingua', NULL),
('id', 'Indonésien', NULL),
('ie', 'Occidental', NULL),
('ig', 'Igbo', NULL),
('ii', 'Yi', NULL),
('ik', 'Inupiak', NULL),
('io', 'Ido', NULL),
('is', 'Islandais', NULL),
('it', 'Italien', NULL),
('iu', 'Inuktitut', NULL),
('ja', 'Japonais', NULL),
('jv', 'Javanais', NULL),
('ka', 'Géorgien', NULL),
('kg', 'Kikongo', NULL),
('ki', 'Kikuyu', NULL),
('kj', 'Kuanyama', NULL),
('kk', 'Kazakh', NULL),
('kl', 'Groenlandais', NULL),
('km', 'Khmer', NULL),
('kn', 'Kannada', NULL),
('ko', 'Coréen', NULL),
('kr', 'Kanouri', NULL),
('ks', 'Cachemiri', NULL),
('ku', 'Kurde', NULL),
('kv', 'Komi', NULL),
('kw', 'Cornique', NULL),
('ky', 'Kirghiz', NULL),
('la', 'Latin', NULL),
('lb', 'Luxembourgeois', NULL),
('lg', 'Ganda', NULL),
('li', 'Limbourgeois', NULL),
('ln', 'Lingala', NULL),
('lo', 'Lao', NULL),
('lt', 'Lituanien', NULL),
('lu', 'Luba-katanga', NULL),
('lv', 'Letton', NULL),
('mg', 'Malgache', NULL),
('mh', 'Marshallais', NULL),
('mi', 'Maori de Nouvell', NULL),
('mk', 'Macédonien', NULL),
('ml', 'Malayalam', NULL),
('mn', 'Mongol', NULL),
('mo', 'Moldave', NULL),
('mr', 'Marathi', NULL),
('ms', 'Malais', NULL),
('mt', 'Maltais', NULL),
('my', 'Birman', NULL),
('na', 'Nauruan', NULL),
('nb', 'Norvégien Bokmål', NULL),
('nd', 'Sindebele', NULL),
('ne', 'Népalais', NULL),
('ng', 'Ndonga', NULL),
('nl', 'Néerlandais', NULL),
('nn', 'Norvégien Nynors', NULL),
('no', 'Norvégien', NULL),
('nr', 'Nrebele', NULL),
('nv', 'Navajo', NULL),
('ny', 'Chichewa', NULL),
('oc', 'Occitan', NULL),
('oj', 'Ojibwé', NULL),
('om', 'Oromo', NULL),
('or', 'Oriya', NULL),
('os', 'Ossète', NULL),
('pa', 'Pendjabi', NULL),
('pi', 'Pali', NULL),
('pl', 'Polonais', NULL),
('ps', 'Pachto', NULL),
('pt', 'Portugais', NULL),
('qu', 'Quechua', NULL),
('rm', 'Romanche', NULL),
('rn', 'Kirundi', NULL),
('ro', 'Roumain', NULL),
('ru', 'Russe', NULL),
('rw', 'Kinyarwanda', NULL),
('sa', 'Sanskrit', NULL),
('sc', 'Sarde', NULL),
('sd', 'Sindhi', NULL),
('se', 'Same du Nord', NULL),
('sg', 'Sango', NULL),
('si', 'Cingalais', NULL),
('sk', 'Slovaque', NULL),
('sl', 'Slovène', NULL),
('sm', 'Samoan', NULL),
('sn', 'Shona', NULL),
('so', 'Somali', NULL),
('sq', 'Albanais', NULL),
('sr', 'Serbe', NULL),
('ss', 'Swati', NULL),
('st', 'Sotho du Sud', NULL),
('su', 'Soundanais', NULL),
('sv', 'Suédois', NULL),
('sw', 'Swahili', NULL),
('ta', 'Tamoul', NULL),
('te', 'Télougou', NULL),
('tg', 'Tadjik', NULL),
('th', 'Thaï', NULL),
('ti', 'Tigrigna', NULL),
('tk', 'Turkmène', NULL),
('tl', 'Tagalog', NULL),
('tn', 'Tswana', NULL),
('to', 'Tongien', NULL),
('tr', 'Turc', NULL),
('ts', 'Tsonga', NULL),
('tt', 'Tatar', NULL),
('tw', 'Twi', NULL),
('ty', 'Tahitien', NULL),
('ug', 'Ouïghour', NULL),
('uk', 'Ukrainien', NULL),
('ur', 'Ourdou', NULL),
('uz', 'Ouzbek', NULL),
('ve', 'Venda', NULL),
('vi', 'Vietnamien', NULL),
('vo', 'Volapük', NULL),
('wa', 'Wallon', NULL),
('wo', 'Wolof', NULL),
('xh', 'Xhosa', NULL),
('yi', 'Yiddish', NULL),
('yo', 'Yoruba', NULL),
('za', 'Zhuang', NULL),
('zh', 'Chinois', NULL),
('zu', 'Zoulou', NULL);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
