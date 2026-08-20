-- =====================================================================
-- 056 - Job de pg_cron: publicar/enviar lo programado que ya toque
-- =====================================================================
-- Cada 5 minutos, mueve de las tablas "...Programad{a,o}s" (055) a las tablas reales
-- ("TClientePublicaciones"/"TClienteAvisos") todo lo que ya haya llegado a su
-- "FechaProgramada". Al insertarse en la tabla real, se disparan solos el trigger de avisos
-- push (024/031) y cualquier otro mecanismo que ya reaccione a un alta normal -esta función no
-- necesita saber nada de eso, ni tocarlo-.
-- Requiere que 055 ya esté aplicado y las extensiones "pg_cron"/"pg_net" activadas.

CREATE OR REPLACE FUNCTION "FSistemaPublicarProgramadas"()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO "TClientePublicaciones" (
        "IdClienteSede", "NombreFallecido", "FechaFallecimiento", "Edad",
        "FechaFuneral", "HoraFuneral", "Iglesia", "Lugar", "CapillaArdiente",
        "Sala", "Observaciones"
    )
    SELECT
        "IdClienteSede", "NombreFallecido", "FechaFallecimiento", "Edad",
        "FechaFuneral", "HoraFuneral", "Iglesia", "Lugar", "CapillaArdiente",
        "Sala", "Observaciones"
    FROM "TClientePublicacionesProgramadas"
    WHERE "FechaProgramada" <= now();

    DELETE FROM "TClientePublicacionesProgramadas" WHERE "FechaProgramada" <= now();

    INSERT INTO "TClienteAvisos" ("IdClienteSede", "Titulo", "Texto")
    SELECT "IdClienteSede", "Titulo", "Texto"
    FROM "TClienteAvisosProgramados"
    WHERE "FechaProgramada" <= now();

    DELETE FROM "TClienteAvisosProgramados" WHERE "FechaProgramada" <= now();
END;
$$;

-- Sin GRANT a "authenticated": esta función solo la llama el propio job de cron (que corre
-- como el propietario/postgres), nadie más necesita ni debe poder invocarla directamente.

SELECT cron.schedule(
    'publicar-programadas',
    '*/5 * * * *',
    $$SELECT "FSistemaPublicarProgramadas"();$$
);
