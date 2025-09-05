BEGIN; -- Inicia la transacción

-- Crea el esquema si no existe
CREATE SCHEMA IF NOT EXISTS ejer2aticlase4;

-- Asigna permisos totales sobre este esquema al usuario
GRANT ALL ON SCHEMA ejer2aticlase4 TO acelerati;

-- Establece el orden de búsqueda de esquemas para la sesión actual.
-- Esto hace que no tengas que escribir 'ejer2aticlase4.' en cada objeto.
SET search_path TO ejer2aticlase4, public;

-- ===== A PARTIR DE AQUÍ VA TU CÓDIGO EXISTENTE =====



COMMIT; -- Confirma la transacción SOLO si todo fue exitoso

