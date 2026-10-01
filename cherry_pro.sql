-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 15-09-2026 a las 20:58:59
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `cherry_pro`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_categoria` (IN `p_id` INT, IN `p_nombre` VARCHAR(50))   BEGIN
UPDATE categorias
SET nombre=p_nombre
WHERE id_categoria=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_factura` (IN `p_id` INT, IN `p_total` DECIMAL(10,2))   BEGIN
UPDATE factura
SET total=p_total
WHERE id_factura=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_pedido` (IN `p_id` INT, IN `p_estado` ENUM('pendiente','enviado','entregado'))   BEGIN
UPDATE pedido
SET estado=p_estado
WHERE id_pedido=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_usuario` (IN `p_id` INT, IN `p_nombre` VARCHAR(50), IN `p_apellido` VARCHAR(50), IN `p_telefono` VARCHAR(20), IN `p_correo` VARCHAR(100))   BEGIN
UPDATE usuario
SET nombre=p_nombre,
apellido=p_apellido,
telefono=p_telefono,
correo=p_correo
WHERE id_usuario=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_categorias` ()   BEGIN
SELECT * FROM categorias;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_categoria_id` (IN `p_id` INT)   BEGIN
SELECT * FROM categorias
WHERE id_categoria=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_facturas` ()   BEGIN
SELECT * FROM factura;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_factura_id` (IN `p_id` INT)   BEGIN
SELECT * FROM factura
WHERE id_factura=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_pedidos` ()   BEGIN
SELECT * FROM pedido;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_pedido_id` (IN `p_id` INT)   BEGIN
SELECT * FROM pedido
WHERE id_pedido=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_usuarios` ()   BEGIN
SELECT * FROM usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_consultar_usuario_id` (IN `p_id` INT)   BEGIN
SELECT * FROM usuario
WHERE id_usuario=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_categoria` (IN `p_id` INT)   BEGIN
DELETE FROM categorias
WHERE id_categoria=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_factura` (IN `p_id` INT)   BEGIN
DELETE FROM factura
WHERE id_factura=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_pedido` (IN `p_id` INT)   BEGIN
DELETE FROM pedido
WHERE id_pedido=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_usuario` (IN `p_id` INT)   BEGIN
DELETE FROM usuario
WHERE id_usuario=p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_categoria` (IN `p_nombre` VARCHAR(50))   BEGIN
INSERT INTO categorias(nombre)
VALUES(p_nombre);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_factura` (IN `p_pedido` INT, IN `p_total` DECIMAL(10,2), IN `p_metodo` VARCHAR(20))   BEGIN
INSERT INTO factura(
id_pedido,
total,
metodo_pago
)
VALUES(
p_pedido,
p_total,
p_metodo
);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_pedido` (IN `p_usuario` INT, IN `p_direccion` VARCHAR(255))   BEGIN
INSERT INTO pedido(id_usuario,direccion)
VALUES(p_usuario,p_direccion);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_usuario` (IN `p_nombre` VARCHAR(50), IN `p_apellido` VARCHAR(50), IN `p_telefono` VARCHAR(20), IN `p_correo` VARCHAR(100), IN `p_password` VARCHAR(255))   BEGIN
INSERT INTO usuario(nombre,apellido,telefono,correo,password)
VALUES(p_nombre,p_apellido,p_telefono,p_correo,p_password);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre`) VALUES
(1, 'Tops, Camisas y Blusas'),
(2, 'Conjuntos'),
(3, 'Vestidos y Faldas'),
(4, 'Colección Masculina'),
(5, 'Pantalones'),
(6, 'Calzado'),
(7, 'Colección Femenina'),
(8, 'Ofertas Especiales');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_pedido`
--

CREATE TABLE `detalle_pedido` (
  `id_detalle` int(11) NOT NULL,
  `id_pedido` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio_unitario` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalle_pedido`
--

INSERT INTO `detalle_pedido` (`id_detalle`, `id_pedido`, `id_producto`, `cantidad`, `precio_unitario`) VALUES
(1, 1, 1, 2, 35000.00),
(2, 2, 2, 1, 40000.00),
(3, 3, 3, 1, 90000.00),
(4, 4, 4, 2, 95000.00),
(5, 5, 5, 1, 120000.00),
(6, 6, 6, 1, 150000.00),
(7, 7, 7, 2, 180000.00),
(8, 8, 8, 1, 200000.00),
(9, 9, 9, 3, 25000.00),
(10, 10, 10, 1, 85000.00);

--
-- Disparadores `detalle_pedido`
--
DELIMITER $$
CREATE TRIGGER `trg_validar_stock` BEFORE INSERT ON `detalle_pedido` FOR EACH ROW BEGIN

DECLARE stock_actual INT;

SELECT stock
INTO stock_actual
FROM productos
WHERE id_producto = NEW.id_producto;

IF NEW.cantidad > stock_actual THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Stock insuficiente';
END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--

CREATE TABLE `factura` (
  `id_factura` int(11) NOT NULL,
  `id_pedido` int(11) DEFAULT NULL,
  `total` decimal(10,2) DEFAULT NULL,
  `metodo_pago` enum('efectivo','tarjeta','transferencia') DEFAULT NULL,
  `fecha` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `factura`
--

INSERT INTO `factura` (`id_factura`, `id_pedido`, `total`, `metodo_pago`, `fecha`) VALUES
(1, 1, 70000.00, 'efectivo', '2026-04-09 17:59:46'),
(2, 2, 40000.00, 'tarjeta', '2026-04-09 17:59:46'),
(3, 3, 90000.00, 'transferencia', '2026-04-09 17:59:46'),
(4, 4, 190000.00, 'efectivo', '2026-04-09 17:59:46'),
(5, 5, 120000.00, 'tarjeta', '2026-04-09 17:59:46'),
(6, 6, 150000.00, 'transferencia', '2026-04-09 17:59:46'),
(7, 7, 360000.00, 'efectivo', '2026-04-09 17:59:46'),
(8, 8, 200000.00, 'tarjeta', '2026-04-09 17:59:46'),
(9, 9, 75000.00, 'transferencia', '2026-04-09 17:59:46'),
(10, 10, 85000.00, 'efectivo', '2026-04-09 17:59:46'),
(11, 11, 115000.00, 'efectivo', '2026-08-20 16:09:32'),
(12, 12, 115000.00, 'efectivo', '2026-08-20 16:10:28'),
(13, 13, 96000.00, 'efectivo', '2026-08-20 16:17:37'),
(14, 14, 50000.00, 'efectivo', '2026-09-15 13:25:59');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedido`
--

CREATE TABLE `pedido` (
  `id_pedido` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `fecha_pedido` datetime DEFAULT current_timestamp(),
  `estado` enum('pendiente','enviado','entregado') DEFAULT 'pendiente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pedido`
--

INSERT INTO `pedido` (`id_pedido`, `id_usuario`, `direccion`, `fecha_pedido`, `estado`) VALUES
(1, 1, 'Calle 1 #10-20', '2026-04-09 17:59:46', 'pendiente'),
(2, 2, 'Calle 2 #20-30', '2026-04-09 17:59:46', 'enviado'),
(3, 3, 'Calle 3 #30-40', '2026-04-09 17:59:46', 'entregado'),
(4, 4, 'Calle 4 #40-50', '2026-04-09 17:59:46', 'pendiente'),
(5, 5, 'Calle 5 #50-60', '2026-04-09 17:59:46', 'enviado'),
(6, 6, 'Calle 6 #60-70', '2026-04-09 17:59:46', 'entregado'),
(7, 7, 'Calle 7 #70-80', '2026-04-09 17:59:46', 'pendiente'),
(8, 8, 'Calle 8 #80-90', '2026-04-09 17:59:46', 'enviado'),
(9, 9, 'Calle 9 #90-100', '2026-04-09 17:59:46', 'entregado'),
(10, 10, 'Calle 10 #100-110', '2026-04-09 17:59:46', 'pendiente'),
(11, 1, 'Kr 32 g h56 n', '2026-08-20 16:09:32', 'pendiente'),
(12, 1, 'Bogota', '2026-08-20 16:10:28', 'pendiente'),
(13, 1, 'Conjunto Malpelo 1', '2026-08-20 16:17:37', 'pendiente'),
(14, 25, 'Conjunto Malpelo 1', '2026-09-15 13:25:59', 'pendiente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id_producto` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL,
  `precio_antiguo` decimal(10,2) DEFAULT NULL,
  `stock` int(11) DEFAULT 0,
  `imagen` varchar(255) DEFAULT NULL,
  `id_categoria` int(11) DEFAULT NULL,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `fecha_creacion` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id_producto`, `nombre`, `descripcion`, `precio`, `precio_antiguo`, `stock`, `imagen`, `id_categoria`, `estado`, `fecha_creacion`) VALUES
(2, 'Blusa Wrap V-Neck Crop Top', 'Confeccionada con telas seleccionadas para garantizar durabilidad y un ajuste perfecto.', 40000.00, NULL, 56, 'imagenes/camisa ombligera.PNG', 1, 'activo', '2026-08-11 15:47:55'),
(3, 'Camisa DREAM estilo Urbano', 'Confeccionada con telas seleccionadas para garantizar durabilidad y un ajuste perfecto.', 65000.00, NULL, 56, 'imagenes/camisa beish.png', 1, 'activo', '2026-08-11 15:47:55'),
(4, 'Elegance Black Camisa Manga Corta', 'Confeccionada con telas seleccionadas para garantizar durabilidad y un ajuste perfecto.', 30000.00, NULL, 56, 'imagenes/camisa con botones casual.webp', 1, 'activo', '2026-08-11 15:47:55'),
(5, 'Camiseta Gothic Edge', 'Confeccionada con telas seleccionadas para garantizar durabilidad y un ajuste perfecto.', 50000.00, NULL, 56, 'imagenes/camisa con diseño.webp', 1, 'activo', '2026-08-11 15:47:55'),
(6, 'Corset Floral Romantico', 'Confeccionada con telas seleccionadas para garantizar durabilidad y un ajuste perfecto.', 45000.00, NULL, 56, 'imagenes/camisa morado corset.PNG', 1, 'activo', '2026-08-11 15:47:55'),
(7, 'Camisa BLESSD', 'Confeccionada con telas seleccionadas para garantizar durabilidad y un ajuste perfecto.', 50000.00, NULL, 56, 'imagenes/camisa BLESSD.png', 1, 'activo', '2026-08-11 15:47:55'),
(8, 'Camisa LIVING LEGEND', 'Confeccionada con telas seleccionadas para garantizar durabilidad y un ajuste perfecto.', 45000.00, NULL, 56, 'imagenes/camisa sencilla.png', 1, 'activo', '2026-08-11 15:47:55'),
(9, 'Camiseta Lowkey Stretwear', 'Confeccionada con telas seleccionadas para garantizar durabilidad y un ajuste perfecto.', 36700.00, NULL, 56, 'imagenes/camisa blanca con diseño.png', 1, 'activo', '2026-08-11 15:47:55'),
(19, 'Blusa Blanca Manga Larga ', 'Blusa especial para tu outfit.', 42000.00, NULL, 56, 'imagenes/blusa mujer de fibra delgada.webp', 1, 'activo', '2026-08-11 15:47:55'),
(28, 'Conjunto Urbano White ', 'Un producto hecho para ti', 50000.00, NULL, 56, 'imagenes/conjunto camiseta y short.webp', 2, 'activo', '0000-00-00 00:00:00'),
(29, 'Conjunto Smiley Dripping Face', 'Un producto hecho para ti', 56000.00, NULL, 56, 'imagenes/conjunto pantalon y bermuda con diseño hombre.webp', 2, 'activo', '0000-00-00 00:00:00'),
(30, 'Conjunto Street Struggle', 'Un producto hecho para ti', 58000.00, NULL, 56, 'imagenes/conjunto sudadera con diseño.webp', 2, 'activo', '0000-00-00 00:00:00'),
(31, 'Conjunto High Hopes Vibes', 'Un producto hecho para ti', 65000.00, NULL, 56, 'imagenes/conjunto sudadera diseño.webp', 2, 'activo', '0000-00-00 00:00:00'),
(32, 'Conjunto Butterfly Rebel', 'Un producto hecho para ti', 65000.00, NULL, 150, 'imagenes/conjunto sudadera mariposa mujer.webp', 1, 'activo', '0000-00-00 00:00:00'),
(33, 'Conjunto Urbano LA Vibes', 'Hecho para ti', 60000.00, NULL, 56, 'imagenes/conjunto sudadera.webp', 2, 'activo', '0000-00-00 00:00:00'),
(34, 'Falda White Flate Sporty', 'Un producto hecho para ti', 50000.00, NULL, 56, 'imagenes/falda blanca sencilla.webp', 3, 'activo', '0000-00-00 00:00:00'),
(35, 'Falda Evasion Romantica', 'Un producto hecho para ti', 54000.00, NULL, 56, 'imagenes/Falda mini negra.webp', 3, 'activo', '0000-00-00 00:00:00'),
(36, 'Shorts de Jeans Negro con Efecto Vintage', 'Un producto hecho para ti', 81000.00, NULL, 56, 'imagenes/falda negra con bolsillo.webp', 3, 'activo', '0000-00-00 00:00:00'),
(37, 'Falda Brisa Dulce Volantes', 'Un producto hecho para ti', 59900.00, NULL, 56, 'imagenes/mini falda blanca con pliegues.webp', 3, 'activo', '0000-00-00 00:00:00'),
(38, 'Mini Falda Jeans Urban Twist', 'Un producto hecho para ti', 30000.00, NULL, 56, 'imagenes/mini falda jeans pegada al cuerpo.webp', 3, 'activo', '0000-00-00 00:00:00'),
(39, 'Vestido Midi Beige', 'Un producto hecho para ti', 67000.00, NULL, 56, 'imagenes/vestido-ajustado-con-tiras.webp', 3, 'activo', '0000-00-00 00:00:00'),
(40, 'Flores en el Aire Vestido Retro Floral', 'Un producto hecho para ti', 73000.00, NULL, 56, 'imagenes/vestido-con-estampado.webp', 3, 'activo', '0000-00-00 00:00:00'),
(41, 'Vestido Midi Negro con abertura', 'Un producto hecho para ti', 72000.00, NULL, 56, 'imagenes/vestido-largo-ajustado-con-abertura-en-la-pierna.webp', 3, 'activo', '0000-00-00 00:00:00'),
(43, 'Jeans de Corte Ancho azul', 'Un producto hecho para ti', 56000.00, NULL, 180, 'imagenes/jean azul bota recta.webp', 5, 'activo', '0000-00-00 00:00:00'),
(44, 'Jeans amplios Ski High', 'Un producto hecho para ti', 70000.00, NULL, 180, 'imagenes/jeans bota campana color blanco.webp', 5, 'activo', '0000-00-00 00:00:00'),
(45, 'Jeans Curva perfecta con Corset', 'Un producto hecho para ti', 82000.00, NULL, 170, 'imagenes/pantalones cintura alta.webp', 5, 'activo', '0000-00-00 00:00:00'),
(46, 'Jeans Alta Elasticidad', 'Un producto hecho para ti', 50000.00, NULL, 60, 'imagenes/geans claros.webp', 5, 'activo', '0000-00-00 00:00:00'),
(47, 'Pantalon Cargo Urban Tech', 'Un producto hecho para ti', 85000.00, NULL, 60, 'imagenes/pantalones negros para hombre.webp', 5, 'activo', '0000-00-00 00:00:00'),
(48, 'Jeans Rebel Edge Desgastados', 'Hecho para ti', 90000.00, NULL, 87, 'imagenes/pantalones negros para hombre.webp', 5, 'activo', '0000-00-00 00:00:00'),
(49, 'Jean Street con cruces', 'Hecho para ti', 82000.00, NULL, 95, 'imagenes/pantalones cruces.webp', 5, 'activo', '0000-00-00 00:00:00'),
(50, 'Jean Street Vibe Rotos', 'Hecho para ti', 63000.00, NULL, 82, 'imagenes/pantalon rallitas.webp', 5, 'activo', '0000-00-00 00:00:00'),
(51, 'Pantalones Cargo SZON Urban', 'Hecho para ti', 69900.00, NULL, 95, 'imagenes/sudadera negra.webp', 5, 'activo', '0000-00-00 00:00:00'),
(52, 'Jeans Street Ucon Wash & Wear', 'Hecho para ti', 96000.00, NULL, 95, 'imagenes/jeans con letras.webp', 5, 'activo', '0000-00-00 00:00:00'),
(53, 'Jean Urban Grunge Desgastados', 'Hecho para ti', 70000.00, NULL, 95, 'imagenes/pantalones con aberturas.webp', 5, 'activo', '0000-00-00 00:00:00'),
(54, 'Zapatillas Cloud White', 'Hecho para ti', 52000.00, NULL, 230, 'imagenes/Tenis casuales para mujer.webp', 6, 'activo', '0000-00-00 00:00:00'),
(55, 'Zapatos Urban Elite White', 'Hecho para ti', 50000.00, NULL, 82, 'imagenes/zapatos casuales blancas.webp', 6, 'activo', '0000-00-00 00:00:00'),
(56, 'Botas Urbanas Fuego Polar', 'Hecho para ti', 70900.00, NULL, 145, 'imagenes/sudadera negra.webp', 6, 'activo', '0000-00-00 00:00:00'),
(57, 'Zapatos deportivos Sweet Pink', 'Hecho para ti', 65000.00, NULL, 95, 'imagenes/Zapatos deportivos mujer.webp', 6, 'activo', '0000-00-00 00:00:00'),
(58, 'Zapatos Urban Comfort', 'Hecho para ti', 80000.00, NULL, 85, 'imagenes/Zapatos para entrenar mujer.webp', 6, 'activo', '0000-00-00 00:00:00'),
(59, 'Zapatos JUHONG Flame Runner', 'Hecho para ti', 90000.00, NULL, 320, 'imagenes/Zapatos para correr hombre.webp', 6, 'activo', '0000-00-00 00:00:00'),
(60, 'Vestido negro noche', 'Un producto destacado en oferta', 72900.00, 90900.00, 50, 'imagenes/mas vendido 2-vestido negro.webp', 8, 'activo', '0000-00-00 00:00:00'),
(61, 'Conjunto Twist Noir', 'Un producto destacado en oferta', 52900.00, 72900.00, 80, 'imagenes/oferta 1- conjunto falda y top de tiras.webp', 8, 'activo', '0000-00-00 00:00:00'),
(62, 'Sweet Blossom Set Blanco', 'Un producto destacado en oferta', 70000.00, 85900.00, 53, 'imagenes/oferta 2 conjunto falda y tiras blanco.webp', 8, 'activo', '0000-00-00 00:00:00'),
(63, 'Conjunto Bloom Vibes Azul Noche', 'Un producto destacado en oferta', 42000.00, 60900.00, 56, 'imagenes/oferta 3- conjunto casual adolescentes.webp', 8, 'activo', '0000-00-00 00:00:00'),
(64, 'Set New York Vibes', 'Un producto destacado en oferta', 45000.00, 90900.00, 35, 'imagenes/oferta-4-short-y-camisa-con-estampado.webp', 8, 'activo', '0000-00-00 00:00:00'),
(65, 'Sneakers Urban Vibe', 'Un producto destacado en oferta', 23000.00, 85000.00, 65, 'imagenes/oferta-5-zapatos-populares.webp', 8, 'activo', '0000-00-00 00:00:00'),
(66, 'Sudadera', 'Un producto destacado en oferta', 39000.00, 50000.00, 98, 'imagenes/oferta-6-sudadera.webp', 8, 'activo', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_categoria`
--

CREATE TABLE `producto_categoria` (
  `id_relacion` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `id_categoria` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto_categoria`
--

INSERT INTO `producto_categoria` (`id_relacion`, `id_producto`, `id_categoria`) VALUES
(1, 34, 7),
(2, 35, 7),
(3, 36, 7),
(4, 37, 7),
(5, 38, 7),
(6, 39, 7),
(7, 40, 7),
(8, 41, 7),
(16, 2, 1),
(17, 3, 1),
(18, 4, 1),
(19, 5, 1),
(20, 6, 1),
(21, 7, 1),
(22, 8, 1),
(23, 9, 1),
(24, 19, 1),
(25, 32, 1),
(26, 28, 2),
(27, 29, 2),
(28, 30, 2),
(29, 31, 2),
(30, 33, 2),
(31, 34, 3),
(32, 35, 3),
(33, 36, 3),
(34, 37, 3),
(35, 38, 3),
(36, 39, 3),
(37, 40, 3),
(38, 41, 3),
(39, 43, 5),
(40, 44, 5),
(41, 45, 5),
(42, 46, 5),
(43, 47, 5),
(44, 48, 5),
(45, 49, 5),
(46, 50, 5),
(47, 51, 5),
(48, 52, 5),
(49, 53, 5),
(50, 54, 6),
(51, 55, 6),
(52, 56, 6),
(53, 57, 6),
(54, 58, 6),
(55, 59, 6),
(79, 3, 4),
(80, 4, 4),
(81, 5, 4),
(82, 7, 4),
(83, 8, 4),
(84, 9, 4),
(85, 28, 4),
(86, 29, 4),
(87, 30, 4),
(88, 31, 4),
(89, 33, 4),
(90, 47, 4),
(91, 48, 4),
(92, 49, 4),
(93, 50, 4),
(94, 51, 4),
(95, 52, 4),
(99, 2, 7),
(100, 6, 7),
(101, 19, 7),
(102, 32, 7),
(103, 44, 7),
(104, 45, 7),
(105, 54, 7),
(106, 57, 7),
(107, 9, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `apellido` varchar(50) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `fecha_registro` datetime DEFAULT current_timestamp(),
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `rol` enum('admin','cliente') DEFAULT 'cliente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nombre`, `apellido`, `telefono`, `correo`, `password`, `fecha_registro`, `estado`, `rol`) VALUES
(1, 'Ana', 'Gomez', '3001234567', 'ana@gmail.com', '123456', '2026-04-09 17:59:46', 'activo', 'admin'),
(2, 'Luis', 'Perez', '3002345678', 'luis@gmail.com', '123456', '2026-04-09 17:59:46', 'activo', 'cliente'),
(3, 'Carlos', 'Rodriguez', '3003456789', 'carlos@gmail.com', 'scrypt:32768:8:1$GAMxrIvstd1oWKnF$b77c0f3fdd1c0dcaf10bc26bd0082190032385d830f6ba532edecdef2520d6d0ba9dac9942fe015e7a2a93deef444ca78e7b7a4be50756ad90e40bdebff8ab08', '2026-04-09 17:59:46', 'activo', 'cliente'),
(4, 'Maria', 'Lopez', '3004567890', 'maria@gmail.com', '123456', '2026-04-09 17:59:46', 'activo', 'cliente'),
(5, 'Sofia', 'Martinez', '3005678901', 'sofia@gmail.com', '123456', '2026-04-09 17:59:46', 'activo', 'cliente'),
(6, 'Jorge', 'Ramirez', '3006789012', 'jorge@gmail.com', '123456', '2026-04-09 17:59:46', 'activo', 'cliente'),
(7, 'Laura', 'Torres', '3007890123', 'laura@gmail.com', '123456', '2026-04-09 17:59:46', 'activo', 'cliente'),
(8, 'Andres', 'Vargas', '3008901234', 'andres@gmail.com', '123456', '2026-04-09 17:59:46', 'activo', 'cliente'),
(9, 'Valentina', 'Rojas', '3009012345', 'valentina@gmail.com', '123456', '2026-04-09 17:59:46', 'activo', 'cliente'),
(10, 'Daniel Alejandro', 'Castro', '3200000000', 'daniela@gmail.com', '123456', '2026-04-09 17:59:46', 'activo', 'cliente'),
(21, 'Camila', 'Herrera', '3214567890', 'camila@gmail.com', '123456', '2026-06-16 13:40:37', 'activo', 'cliente'),
(22, 'Sofia', 'Cruz', '3000000000', 'sof23@hotmail.com', 'scrypt:32768:8:1$UJSHlQj5PsIOI45S$747d2322546b2c53c763e964506cb3c7914a6edaf3f1f9e8589b59ff3eaba53299ff92ab11d64b0eb4c408779f3b93c2118c37a030b18202cd4c53c731706761', '2026-08-13 13:26:28', 'activo', 'cliente'),
(23, 'Maria', 'Salazar', '3000000000', 'maria1@gmail.com', 'scrypt:32768:8:1$5LLbZ85LKsoXU0x7$734ad0d892869214ba3f6af8b518530c035a325a5dd72b23eac2aae6e7a966f5c9064656709b5d1c22718ae5e91b07d6102d4848023f68cedfa70b9951999ae8', '2026-08-13 13:28:09', 'activo', 'cliente'),
(24, 'Karen', 'Suarez', '32115648', 'karensuarez@gmail.com', 'scrypt:32768:8:1$iOVMTvUzObk0PYs5$fcc5830616104795fb5d0076f65edb2611d43fbfb3d2c45eda6098dc64a72b983c6e83e93959e101ba875fdd1cd7d0d0811143d21362d17f176fedca72eca685', '2026-08-13 15:35:06', 'activo', 'cliente'),
(25, 'Angie', 'Natalia', '3000000000', 'angieriveramarroquin@gmail.com', 'scrypt:32768:8:1$rp5quezaMA1D6D4Q$27bfc6aba4a044e777c17210f07f41e0330d6bd199000c9d9f01e158a2cf1c500630bab29aa590a5c93dad2fd19f3cf3407ae1ed7eaa635f7e0c1d399bf44a06', '2026-09-08 14:33:41', 'activo', 'admin');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_detalle_ventas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_detalle_ventas` (
`id_pedido` int(11)
,`producto` varchar(100)
,`cantidad` int(11)
,`precio_unitario` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pedidos_factura`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pedidos_factura` (
`id_pedido` int(11)
,`nombre` varchar(50)
,`total` decimal(10,2)
,`metodo_pago` enum('efectivo','tarjeta','transferencia')
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_productos_categoria`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_productos_categoria` (
`nombre` varchar(100)
,`categoria` varchar(50)
,`precio` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_productos_vendidos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_productos_vendidos` (
`nombre` varchar(100)
,`vendidos` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_total_usuarios`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_total_usuarios` (
`nombre` varchar(50)
,`apellido` varchar(50)
,`total` decimal(42,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_usuarios_pedidos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_usuarios_pedidos` (
`nombre` varchar(50)
,`apellido` varchar(50)
,`id_pedido` int(11)
,`estado` enum('pendiente','enviado','entregado')
,`fecha_pedido` datetime
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_detalle_ventas`
--
DROP TABLE IF EXISTS `vista_detalle_ventas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_detalle_ventas`  AS SELECT `p`.`id_pedido` AS `id_pedido`, `pr`.`nombre` AS `producto`, `dp`.`cantidad` AS `cantidad`, `dp`.`precio_unitario` AS `precio_unitario` FROM ((`pedido` `p` join `detalle_pedido` `dp` on(`p`.`id_pedido` = `dp`.`id_pedido`)) join `productos` `pr` on(`dp`.`id_producto` = `pr`.`id_producto`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pedidos_factura`
--
DROP TABLE IF EXISTS `vista_pedidos_factura`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pedidos_factura`  AS SELECT `p`.`id_pedido` AS `id_pedido`, `u`.`nombre` AS `nombre`, `f`.`total` AS `total`, `f`.`metodo_pago` AS `metodo_pago` FROM ((`pedido` `p` join `usuario` `u` on(`p`.`id_usuario` = `u`.`id_usuario`)) join `factura` `f` on(`p`.`id_pedido` = `f`.`id_pedido`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_productos_categoria`
--
DROP TABLE IF EXISTS `vista_productos_categoria`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_productos_categoria`  AS SELECT `pr`.`nombre` AS `nombre`, `c`.`nombre` AS `categoria`, `pr`.`precio` AS `precio` FROM (`productos` `pr` join `categorias` `c` on(`pr`.`id_categoria` = `c`.`id_categoria`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_productos_vendidos`
--
DROP TABLE IF EXISTS `vista_productos_vendidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_productos_vendidos`  AS SELECT `pr`.`nombre` AS `nombre`, sum(`dp`.`cantidad`) AS `vendidos` FROM (`productos` `pr` join `detalle_pedido` `dp` on(`pr`.`id_producto` = `dp`.`id_producto`)) GROUP BY `pr`.`id_producto` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_total_usuarios`
--
DROP TABLE IF EXISTS `vista_total_usuarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_total_usuarios`  AS SELECT `u`.`nombre` AS `nombre`, `u`.`apellido` AS `apellido`, sum(`dp`.`cantidad` * `dp`.`precio_unitario`) AS `total` FROM ((`usuario` `u` join `pedido` `p` on(`u`.`id_usuario` = `p`.`id_usuario`)) join `detalle_pedido` `dp` on(`p`.`id_pedido` = `dp`.`id_pedido`)) GROUP BY `u`.`id_usuario` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_usuarios_pedidos`
--
DROP TABLE IF EXISTS `vista_usuarios_pedidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_usuarios_pedidos`  AS SELECT `u`.`nombre` AS `nombre`, `u`.`apellido` AS `apellido`, `p`.`id_pedido` AS `id_pedido`, `p`.`estado` AS `estado`, `p`.`fecha_pedido` AS `fecha_pedido` FROM (`usuario` `u` join `pedido` `p` on(`u`.`id_usuario` = `p`.`id_usuario`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `detalle_pedido`
--
ALTER TABLE `detalle_pedido`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_pedido` (`id_pedido`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`id_factura`),
  ADD KEY `id_pedido` (`id_pedido`);

--
-- Indices de la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD PRIMARY KEY (`id_pedido`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id_producto`),
  ADD KEY `id_categoria` (`id_categoria`);

--
-- Indices de la tabla `producto_categoria`
--
ALTER TABLE `producto_categoria`
  ADD PRIMARY KEY (`id_relacion`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_categoria` (`id_categoria`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `detalle_pedido`
--
ALTER TABLE `detalle_pedido`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `factura`
--
ALTER TABLE `factura`
  MODIFY `id_factura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `pedido`
--
ALTER TABLE `pedido`
  MODIFY `id_pedido` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT de la tabla `producto_categoria`
--
ALTER TABLE `producto_categoria`
  MODIFY `id_relacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=108;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detalle_pedido`
--
ALTER TABLE `detalle_pedido`
  ADD CONSTRAINT `detalle_pedido_ibfk_1` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`),
  ADD CONSTRAINT `detalle_pedido_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `factura`
--
ALTER TABLE `factura`
  ADD CONSTRAINT `factura_ibfk_1` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`);

--
-- Filtros para la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD CONSTRAINT `pedido_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`);

--
-- Filtros para la tabla `producto_categoria`
--
ALTER TABLE `producto_categoria`
  ADD CONSTRAINT `producto_categoria_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE,
  ADD CONSTRAINT `producto_categoria_ibfk_2` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
