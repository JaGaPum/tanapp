-- =====================================================================
-- 066 - Registrar/reasignar el token push vía función, en vez de un upsert directo
-- =====================================================================
-- 065 añadió la policy de UPDATE que faltaba, pero no basta: en un INSERT ... ON CONFLICT DO
-- UPDATE, Postgres necesita poder "ver" la fila en conflicto para saber que hay que actualizarla
-- en vez de insertar una nueva, y esa visibilidad la determina la policy de SELECT -aquí,
-- "select_propio_TSistemaDispositivosPush"-, que solo deja ver las filas del propio usuario. Si
-- el token ya pertenece a OTRA cuenta (el caso que se quiere arreglar: el mismo dispositivo pasó
-- de una cuenta a otra), la fila no es "visible" para el usuario actual, así que el upsert nunca
-- llega siquiera a evaluar el WITH CHECK de la policy de UPDATE de 065.
--
-- En vez de complicar más las policies (abrir el SELECT a todo el mundo no es aceptable: cada
-- fila lleva un token de FCM, no debería poder leerlo cualquier usuario autenticado), se mueve la
-- reasignación a una función SECURITY DEFINER -mismo patrón que "FSistemaHandleNewAuthUser" o
-- "FSistemaCrearAvisosPublicacion"-, que resuelve el usuario llamante con auth.uid() y hace ella
-- misma el upsert saltándose RLS, sin exponer ninguna operación más amplia que "registra este
-- token para mí mismo".
-- Requiere que 065 ya esté aplicado.

CREATE OR REPLACE FUNCTION "FSistemaRegistrarTokenPush"(p_token text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_id_usuario uuid;
BEGIN
    SELECT "IdSistemaUsuario" INTO v_id_usuario
    FROM "TSistemaUsuarios"
    WHERE "IdAuthSupabase" = auth.uid();

    IF v_id_usuario IS NULL THEN
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    INSERT INTO "TSistemaDispositivosPush" ("IdSistemaUsuario", "Token")
    VALUES (v_id_usuario, p_token)
    ON CONFLICT ("Token") DO UPDATE SET "IdSistemaUsuario" = EXCLUDED."IdSistemaUsuario";
END;
$$;

GRANT EXECUTE ON FUNCTION "FSistemaRegistrarTokenPush"(text) TO authenticated;
