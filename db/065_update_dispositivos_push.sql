-- =====================================================================
-- 065 - Falta la policy de UPDATE en TSistemaDispositivosPush: un mismo dispositivo no podía
--        reasignar su token al cambiar de cuenta
-- =====================================================================
-- "TSistemaDispositivosPush" (024) tiene un único token por fila (UNIQUE en "Token") y
-- "DispositivosPushRepository.registrarToken" hace un upsert con "onConflict: 'Token'": si el
-- mismo dispositivo ya había registrado ese token con OTRA cuenta (p. ej. se probó primero como
-- cliente y luego se entra como usuario ordinario en el mismo móvil), el upsert necesita hacer
-- un UPDATE sobre esa fila para reasignarla al usuario actual. Sin policy de UPDATE, RLS lo
-- deniega por defecto (visible como "new row violates row-level security policy (USING
-- expression)"), y como el error se traga en el cliente (ver home_screen.dart, no es crítico
-- para no romper el arranque), no se notaba nada raro salvo que a ese usuario nunca le llegaba
-- ningún push.
--
-- USING(true) a propósito, no "propio" como el resto de policies de esta tabla: la fila que hay
-- que actualizar es justo la que NO es todavía del usuario actual (es la que hay que
-- reasignarle), así que una condición "propia" sobre la fila EXISTENTE nunca dejaría pasar el
-- caso que se quiere permitir. La seguridad la pone el WITH CHECK: pase lo que pase, la fila
-- resultante tiene que quedar asignada al propio usuario que hace la petición, igual que ya exige
-- "insert_propio_TSistemaDispositivosPush" para las filas nuevas.
-- Requiere que 024 ya esté aplicado.

CREATE POLICY "update_propio_TSistemaDispositivosPush" ON "TSistemaDispositivosPush"
    FOR UPDATE TO authenticated
    USING (true)
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );
