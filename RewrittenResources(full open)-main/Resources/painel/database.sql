DROP TABLE IF EXISTS `panel`;
CREATE TABLE IF NOT EXISTS `panel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `bank` int(20) NOT NULL DEFAULT 0,
  `premium` int(20) NOT NULL DEFAULT 0,
  `buff` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `panel` (`id`, `name`, `bank`, `premium`) VALUES
(1, 'Admin', 0, 0),
(2, 'Premium', 0, 0),
(3, 'Policia', 0, 0),
(4, 'Paramedico', 0, 0),
(5, 'Mecanico', 0, 0),
(6, 'Burgershot', 0, 0),
(7, 'Ballas', 0, 0),
(8, 'Vagos', 0, 0),
(9, 'Families', 0, 0),
(10, 'Aztecas', 0, 0),
(11, 'Bloods', 0, 0);

DROP TABLE IF EXISTS `paneltransactions`;
CREATE TABLE IF NOT EXISTS `paneltransactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `Type` varchar(255) NOT NULL,
  `Value` int(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;