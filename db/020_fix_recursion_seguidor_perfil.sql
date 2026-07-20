-- =====================================================================
-- 020 - Arregla "infinite recursion detected in policy for relation TSistemaUsuarios": la
--        policy "select_seguidor_de_mi_sede_TSistemaUsuarios" de 019 hace
--        JOIN "TSistemaUsuarios" propietario dentro de una policy DE TSistemaUsuarios, así que
--        evaluar esa fila vuelve a disparar la RLS de TSistemaUsuarios, cerrando un ciclo.
--        Se soluciona igual que en 013: con una función SECURITY DEFINER, que evalúa el EXISTS
--        saltándose la RLS de las tablas que consulta.
-- =====================================================================
-- Requiere que 019 ya esté aplicado.

CREATE OR REPLACE FUNCTION "FSistemaEsSeguidorDeSedePropia"(id_sistema_usuario_seguidor uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM "TClienteSeguimientos" f
        JOIN "TClienteSedes" s ON s."IdClienteSede" = f."IdClienteSede"
        JOIN "TSistemaUsuarios" propietario ON propietario."IdSistemaUsuario" = s."IdSistemaUsuario"
        WHERE f."IdSistemaUsuario" = id_sistema_usuario_seguidor
          AND propietario."IdAuthSupabase" = auth.uid()
    );
$$;

GRANT EXECUTE ON FUNCTION "FSistemaEsSeguidorDeSedePropia"(uuid) TO authenticated;

DROP POLICY IF EXISTS "select_seguidor_de_mi_sede_TSistemaUsuarios" ON "TSistemaUsuarios";

CREATE POLICY "select_seguidor_de_mi_sede_TSistemaUsuarios" ON "TSistemaUsuarios"
    FOR SELECT TO authenticated
    USING ("FSistemaEsSeguidorDeSedePropia"("IdSistemaUsuario"));
