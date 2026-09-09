-- =====================================================================
-- 070 - Recordatorios personales de una publicación (usuario ordinario o admin, nunca cliente)
-- =====================================================================
-- Un usuario ordinario (o un admin) puede pedir que se le avise en una fecha/hora concreta antes
-- de una esquela o acto, hasta un máximo de 2 por publicación y usuario. Un cliente no puede
-- configurar recordatorios con su cuenta de cliente (si tiene una cuenta personal vinculada de
-- usuario ordinario -067-, sí puede desde ahí, porque en ese momento su sesión ya no tiene el
-- rol CLIENTE); esa restricción de rol se aplica solo en Flutter (qué botón se ve), no aquí.
--
-- Cuando llega su hora, un job de pg_cron (mismo patrón que 056) los marca "Enviado"; ese UPDATE
-- dispara, vía un Database Webhook configurado a mano en Supabase Studio, la Edge Function
-- "enviar-push-recordatorio" (calcada de "enviar-push-aviso" de 024) que manda el push de
-- verdad. La app luego lee esta misma tabla filtrando "Enviado = true" para mostrarlos en la
-- pestaña "Avisos" — no hace falta duplicar nada en otra tabla.
--
-- "FechaHoraRecordatorio" es un instante real (timestamptz): el cliente Flutter lo manda ya
-- convertido a UTC, igual que ya hace "FechaProgramada" en 055, precisamente porque aquí sí hace
-- falta compararlo con now() sin ambigüedad. En cambio "FechaFuneral"/"HoraFuneral" (025) son un
-- date/time SIN zona horaria -hasta ahora solo se usaban para mostrarlos en pantalla, nunca para
-- comparar con now()-, así que aquí, la primera vez que hace falta compararlos de verdad, se
-- interpretan explícitamente como hora de Galicia con "AT TIME ZONE 'Europe/Madrid'" (así el
-- cambio de horario de verano/invierno se calcula solo, en vez de a mano).
--
-- Requiere que 025 (FechaFuneral/HoraFuneral), 024 (dispositivos push) y 056 (pg_cron/pg_net ya
-- activados) estén aplicados.

CREATE TABLE "TClientePublicacionesRecordatorios" (
    "IdClientePublicacionRecordatorio" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "IdClientePublicacion" uuid NOT NULL,
    "FechaHoraRecordatorio" timestamptz NOT NULL,
    "Enviado" boolean NOT NULL DEFAULT false,
    "FechaEnviado" timestamptz NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NULL
);

ALTER TABLE "TClientePublicacionesRecordatorios"
    ADD CONSTRAINT "FK_TClientePublicacionesRecordatorios_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TClientePublicacionesRecordatorios_IdClientePublicacion"
        FOREIGN KEY ("IdClientePublicacion")
        REFERENCES "TClientePublicaciones" ("IdClientePublicacion")
        ON DELETE CASCADE;

CREATE INDEX "IX_TClientePublicacionesRecordatorios_IdSistemaUsuario"
    ON "TClientePublicacionesRecordatorios" ("IdSistemaUsuario");
CREATE INDEX "IX_TClientePublicacionesRecordatorios_IdClientePublicacion"
    ON "TClientePublicacionesRecordatorios" ("IdClientePublicacion");

-- La consulta del cron solo mira los pendientes, así que le basta un índice parcial mucho más
-- pequeño que uno sobre toda la tabla.
CREATE INDEX "IX_TClientePublicacionesRecordatorios_Pendientes"
    ON "TClientePublicacionesRecordatorios" ("FechaHoraRecordatorio")
    WHERE NOT "Enviado";

ALTER TABLE "TClientePublicacionesRecordatorios" ENABLE ROW LEVEL SECURITY;

-- Mismo patrón "propio" que TClientePublicacionesArchivadas (021), sin excepción para ADMIN:
-- es una configuración estrictamente personal, ni siquiera un admin necesita ver la de otro.
CREATE POLICY "select_propio_TClientePublicacionesRecordatorios"
    ON "TClientePublicacionesRecordatorios"
    FOR SELECT TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "insert_propio_TClientePublicacionesRecordatorios"
    ON "TClientePublicacionesRecordatorios"
    FOR INSERT TO authenticated
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "update_propio_TClientePublicacionesRecordatorios"
    ON "TClientePublicacionesRecordatorios"
    FOR UPDATE TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    )
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "delete_propio_TClientePublicacionesRecordatorios"
    ON "TClientePublicacionesRecordatorios"
    FOR DELETE TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

-- Valida que la publicación ya tenga fecha/hora de evento, que el recordatorio sea futuro y
-- anterior a esa fecha/hora, y el máximo de 2 por publicación y usuario. Sin SECURITY DEFINER:
-- solo lee "TClientePublicaciones" (que quien inserta ya puede leer por su propia policy, 017) y
-- esta misma tabla (que ya puede leer por la policy de arriba).
CREATE OR REPLACE FUNCTION "FSistemaValidarRecordatorio"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_evento timestamptz;
    v_cantidad int;
BEGIN
    -- El cron (FSistemaMarcarRecordatoriosVencidos, más abajo) solo cambia "Enviado"/
    -- "FechaEnviado": si se revalidara aquí igual que una edición normal, la condición de "debe
    -- ser futuro" fallaría siempre, precisamente porque el cron actúa cuando ya ha llegado su
    -- hora. Se detecta ese caso (nada del contenido cambia) y se deja pasar sin más.
    IF TG_OP = 'UPDATE'
       AND NEW."FechaHoraRecordatorio" = OLD."FechaHoraRecordatorio"
       AND NEW."IdSistemaUsuario" = OLD."IdSistemaUsuario"
       AND NEW."IdClientePublicacion" = OLD."IdClientePublicacion" THEN
        RETURN NEW;
    END IF;

    SELECT ("FechaFuneral" + "HoraFuneral") AT TIME ZONE 'Europe/Madrid'
        INTO v_evento
        FROM "TClientePublicaciones"
        WHERE "IdClientePublicacion" = NEW."IdClientePublicacion";

    IF v_evento IS NULL THEN
        RAISE EXCEPTION 'Esta publicación todavía no tiene fecha y hora de evento';
    END IF;

    IF NEW."FechaHoraRecordatorio" >= v_evento THEN
        RAISE EXCEPTION 'El recordatorio debe ser antes de la fecha y hora del evento';
    END IF;

    IF NEW."FechaHoraRecordatorio" <= now() THEN
        RAISE EXCEPTION 'El recordatorio debe ser en el futuro';
    END IF;

    SELECT count(*) INTO v_cantidad
        FROM "TClientePublicacionesRecordatorios"
        WHERE "IdSistemaUsuario" = NEW."IdSistemaUsuario"
          AND "IdClientePublicacion" = NEW."IdClientePublicacion"
          AND "IdClientePublicacionRecordatorio" IS DISTINCT FROM NEW."IdClientePublicacionRecordatorio";
    IF v_cantidad >= 2 THEN
        RAISE EXCEPTION 'Ya tienes el máximo de 2 recordatorios para esta publicación';
    END IF;

    IF TG_OP = 'UPDATE' THEN
        NEW."FechaModificacion" := now();
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_FSistemaValidarRecordatorio"
    BEFORE INSERT OR UPDATE ON "TClientePublicacionesRecordatorios"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaValidarRecordatorio"();

-- Job de pg_cron (mismo patrón que 056, pero cada minuto en vez de cada 5: aquí la precisión
-- importa, el usuario eligió una hora concreta). Solo marca "Enviado"; el envío real del push lo
-- hace la Edge Function "enviar-push-recordatorio", disparada por un Database Webhook sobre
-- UPDATE de esta tabla (configurado a mano en Supabase Studio, ver el comentario de esa
-- función). Sin GRANT a "authenticated": solo la llama el propio job de cron.
CREATE OR REPLACE FUNCTION "FSistemaMarcarRecordatoriosVencidos"()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE "TClientePublicacionesRecordatorios"
        SET "Enviado" = true, "FechaEnviado" = now()
        WHERE NOT "Enviado" AND "FechaHoraRecordatorio" <= now();
END;
$$;

SELECT cron.schedule(
    'marcar-recordatorios-vencidos',
    '* * * * *',
    $$SELECT "FSistemaMarcarRecordatoriosVencidos"();$$
);
