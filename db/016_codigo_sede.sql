-- =====================================================================
-- 016 - Código identificativo de cada sede de cliente. Obligatorio al dar de
--        alta una sede; la sede principal creada automáticamente al aprobar
--        una solicitud lleva "Sede001" por defecto.
-- =====================================================================
-- Requiere que 015 ya esté aplicado.

ALTER TABLE "TClienteSedes" ADD COLUMN "Codigo" varchar(50) NULL;

UPDATE "TClienteSedes" SET "Codigo" = 'Sede001' WHERE "Nombre" = 'Sede principal' AND "Codigo" IS NULL;

-- Cualquier otra sede ya existente que se quedara sin código (dada de alta antes de este
-- cambio) recibe uno correlativo por cliente, para poder dejar la columna NOT NULL.
WITH numeradas AS (
    SELECT "IdClienteSede",
           ROW_NUMBER() OVER (PARTITION BY "IdSistemaUsuario" ORDER BY "FechaAlta") AS n
    FROM "TClienteSedes"
    WHERE "Codigo" IS NULL
)
UPDATE "TClienteSedes" s
SET "Codigo" = 'Sede' || LPAD(numeradas.n::text, 3, '0')
FROM numeradas
WHERE s."IdClienteSede" = numeradas."IdClienteSede";

ALTER TABLE "TClienteSedes" ALTER COLUMN "Codigo" SET NOT NULL;
