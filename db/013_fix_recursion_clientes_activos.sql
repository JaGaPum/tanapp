-- =====================================================================
-- 013 - Arregla "infinite recursion detected in policy for relation
--        TSistemaUsuarios": la policy select_clientes_activos_TSistemaUsuarios
--        de 012 consultaba TSistemaUsuariosRoles directamente, y la policy de
--        esa tabla vuelve a consultar TSistemaUsuarios para resolver
--        auth.uid(), cerrando un ciclo. Se soluciona igual que
--        FSistemaUsuarioTieneRol: con una función SECURITY DEFINER, que
--        evalúa el EXISTS saltándose la RLS de las tablas que consulta.
-- =====================================================================
-- Requiere que 012 ya esté aplicado.

CREATE OR REPLACE FUNCTION "FSistemaUsuarioEsClienteActivo"(id_sistema_usuario uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM "TSistemaUsuarios" u
        JOIN "TSistemaUsuariosRoles" ur ON ur."IdSistemaUsuario" = u."IdSistemaUsuario"
        JOIN "TSistemaRoles" r ON r."IdSistemaRol" = ur."IdSistemaRol"
        WHERE u."IdSistemaUsuario" = id_sistema_usuario
          AND u."Activo" = true
          AND r."Codigo" = 'CLIENTE'
    );
$$;

GRANT EXECUTE ON FUNCTION "FSistemaUsuarioEsClienteActivo"(uuid) TO authenticated;

DROP POLICY IF EXISTS "select_clientes_activos_TSistemaUsuarios" ON "TSistemaUsuarios";

CREATE POLICY "select_clientes_activos_TSistemaUsuarios" ON "TSistemaUsuarios"
    FOR SELECT TO authenticated
    USING ("FSistemaUsuarioEsClienteActivo"("IdSistemaUsuario"));
