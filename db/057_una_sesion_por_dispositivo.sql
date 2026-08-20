-- =====================================================================
-- 057 - Como mucho una sesión "ABIERTA" por dispositivo
-- =====================================================================
-- Hasta ahora cada dispositivo solo "recordaba" en local (SharedPreferences) el id de su
-- última sesión, sin que la fila de "TSistemaSesiones" guardase ningún dato que identificase
-- al dispositivo físico. Si ese puntero local se perdía (caché borrada, otro usuario probando
-- en el mismo navegador, distinto puerto en desarrollo web...), el siguiente login explícito
-- creaba una fila nueva sin cerrar la anterior, que quedaba "ABIERTA" para siempre aunque ya
-- nadie la estuviese usando (esto es justo lo que se veía como sesiones "Abertas"/"En curso"
-- fantasma en el panel de admin).
--
-- Esta migración añade "IdDispositivo" (un UUID generado una vez por dispositivo y persistido
-- en local, ver DeviceSesionStore en el cliente) y una función para cerrar de golpe cualquier
-- otra sesión abierta de ese mismo dispositivo -sea del mismo usuario o de otro- justo antes de
-- crear o reutilizar una sesión: así solo puede haber una sesión "ABIERTA" por dispositivo en
-- todo momento.
--
-- Requiere que 048 ya esté aplicado.

ALTER TABLE "TSistemaSesiones"
    ADD COLUMN "IdDispositivo" uuid NULL;

-- Para cerrar rápido "las otras sesiones abiertas de este dispositivo" en cada login.
CREATE INDEX "IX_TSistemaSesiones_Dispositivo_Abiertas"
    ON "TSistemaSesiones" ("IdDispositivo")
    WHERE "Estado" = 'ABIERTA';

-- SECURITY DEFINER porque puede hacer falta cerrar la sesión de OTRO usuario (mismo
-- dispositivo, cuenta distinta a la que inició sesión antes): la policy de UPDATE de
-- "TSistemaSesiones" solo deja tocar las sesiones propias o, si eres ADMIN, cualquiera. Riesgo
-- acotado: "IdDispositivo" es un UUID v4 opaco que solo conoce el propio dispositivo, y lo
-- único que permite esta función es cerrar sesiones (no leer ni modificar ningún otro dato).
CREATE OR REPLACE FUNCTION "FSistemaCerrarSesionesDispositivo"(
    id_dispositivo uuid,
    id_sistema_sesion_excluir uuid
)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    UPDATE "TSistemaSesiones"
    SET "Estado" = 'CERRADA', "FechaFin" = now()
    WHERE "IdDispositivo" = id_dispositivo
      AND "IdSistemaSesion" <> id_sistema_sesion_excluir
      AND "Estado" = 'ABIERTA';
$$;

GRANT EXECUTE ON FUNCTION "FSistemaCerrarSesionesDispositivo"(uuid, uuid) TO authenticated;
