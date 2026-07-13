-- =====================================================================
-- 005 - Catálogo de configuración: Provincias y Concellos de Galicia,
--        gestionable por el ADMIN desde Sistema > Configuración
-- =====================================================================
-- Requiere que 004 ya esté aplicado.

-- =====================================================================
-- 1. Tablas
-- =====================================================================
CREATE TABLE "TConfiguracionProvincias" (
    "IdConfiguracionProvincia" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "Nombre" varchar(100) NOT NULL,
    "PrefijoPostal" varchar(2) NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "UX_TConfiguracionProvincias_Nombre" ON "TConfiguracionProvincias" ("Nombre");

CREATE TABLE "TConfiguracionConcellos" (
    "IdConfiguracionConcello" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdConfiguracionProvincia" uuid NOT NULL,
    "Nombre" varchar(150) NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TConfiguracionConcellos"
    ADD CONSTRAINT "FK_TConfiguracionConcellos_IdConfiguracionProvincia"
        FOREIGN KEY ("IdConfiguracionProvincia")
        REFERENCES "TConfiguracionProvincias" ("IdConfiguracionProvincia")
        ON DELETE CASCADE;

CREATE INDEX "IX_TConfiguracionConcellos_IdConfiguracionProvincia"
    ON "TConfiguracionConcellos" ("IdConfiguracionProvincia");
CREATE UNIQUE INDEX "UX_TConfiguracionConcellos_Provincia_Nombre"
    ON "TConfiguracionConcellos" ("IdConfiguracionProvincia", "Nombre");

ALTER TABLE "TConfiguracionProvincias" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "TConfiguracionConcellos" ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER "trigger_FechaModificacion_TConfiguracionProvincias"
    BEFORE UPDATE ON "TConfiguracionProvincias"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

CREATE TRIGGER "trigger_FechaModificacion_TConfiguracionConcellos"
    BEFORE UPDATE ON "TConfiguracionConcellos"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

-- =====================================================================
-- 2. RLS: lectura pública (la usan también formularios sin autenticar,
--    como la solicitud de alta de cliente); mutación solo ADMIN
-- =====================================================================
CREATE POLICY "select_publico_TConfiguracionProvincias" ON "TConfiguracionProvincias"
    FOR SELECT TO anon, authenticated
    USING (true);

CREATE POLICY "mutacion_admin_TConfiguracionProvincias" ON "TConfiguracionProvincias"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

CREATE POLICY "select_publico_TConfiguracionConcellos" ON "TConfiguracionConcellos"
    FOR SELECT TO anon, authenticated
    USING (true);

CREATE POLICY "mutacion_admin_TConfiguracionConcellos" ON "TConfiguracionConcellos"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

-- =====================================================================
-- 3. Seed: las 4 provincias gallegas
-- =====================================================================
INSERT INTO "TConfiguracionProvincias" ("Nombre", "PrefijoPostal") VALUES
    ('A Coruña', '15'),
    ('Lugo', '27'),
    ('Ourense', '32'),
    ('Pontevedra', '36')
ON CONFLICT ("Nombre") DO NOTHING;

-- =====================================================================
-- 4. Seed: concellos por provincia (313 en total, listados oficiales INE)
-- =====================================================================
INSERT INTO "TConfiguracionConcellos" ("IdConfiguracionProvincia", "Nombre")
SELECT p."IdConfiguracionProvincia", c.nombre
FROM (VALUES
    ('A Coruña','Abegondo'), ('A Coruña','Ames'), ('A Coruña','Aranga'), ('A Coruña','Ares'),
    ('A Coruña','Arteixo'), ('A Coruña','Arzúa'), ('A Coruña','A Baña'), ('A Coruña','Bergondo'),
    ('A Coruña','Betanzos'), ('A Coruña','Boimorto'), ('A Coruña','Boiro'), ('A Coruña','Boqueixón'),
    ('A Coruña','Brión'), ('A Coruña','Cabana de Bergantiños'), ('A Coruña','Cabanas'),
    ('A Coruña','Camariñas'), ('A Coruña','Cambre'), ('A Coruña','A Capela'), ('A Coruña','Carballo'),
    ('A Coruña','Cariño'), ('A Coruña','Carnota'), ('A Coruña','Carral'), ('A Coruña','Cedeira'),
    ('A Coruña','Cee'), ('A Coruña','Cerceda'), ('A Coruña','Cerdido'), ('A Coruña','Coirós'),
    ('A Coruña','Corcubión'), ('A Coruña','Coristanco'), ('A Coruña','A Coruña'), ('A Coruña','Culleredo'),
    ('A Coruña','Curtis'), ('A Coruña','Dodro'), ('A Coruña','Dumbría'), ('A Coruña','Fene'),
    ('A Coruña','Ferrol'), ('A Coruña','Fisterra'), ('A Coruña','Frades'), ('A Coruña','Irixoa'),
    ('A Coruña','A Laracha'), ('A Coruña','Laxe'), ('A Coruña','Lousame'),
    ('A Coruña','Malpica de Bergantiños'), ('A Coruña','Mañón'), ('A Coruña','Mazaricos'),
    ('A Coruña','Melide'), ('A Coruña','Mesía'), ('A Coruña','Miño'), ('A Coruña','Moeche'),
    ('A Coruña','Monfero'), ('A Coruña','Mugardos'), ('A Coruña','Muros'), ('A Coruña','Muxía'),
    ('A Coruña','Narón'), ('A Coruña','Neda'), ('A Coruña','Negreira'), ('A Coruña','Noia'),
    ('A Coruña','Oleiros'), ('A Coruña','Ordes'), ('A Coruña','Oroso'), ('A Coruña','Ortigueira'),
    ('A Coruña','Outes'), ('A Coruña','Oza-Cesuras'), ('A Coruña','Paderne'), ('A Coruña','Padrón'),
    ('A Coruña','O Pino'), ('A Coruña','A Pobra do Caramiñal'), ('A Coruña','Ponteceso'),
    ('A Coruña','Pontedeume'), ('A Coruña','As Pontes de García Rodríguez'), ('A Coruña','Porto do Son'),
    ('A Coruña','Rianxo'), ('A Coruña','Ribeira'), ('A Coruña','Rois'), ('A Coruña','Sada'),
    ('A Coruña','San Sadurniño'), ('A Coruña','Santa Comba'), ('A Coruña','Santiago de Compostela'),
    ('A Coruña','Santiso'), ('A Coruña','Sobrado'), ('A Coruña','As Somozas'), ('A Coruña','Teo'),
    ('A Coruña','Toques'), ('A Coruña','Tordoia'), ('A Coruña','Touro'), ('A Coruña','Trazo'),
    ('A Coruña','Val do Dubra'), ('A Coruña','Valdoviño'), ('A Coruña','Vedra'),
    ('A Coruña','Vilarmaior'), ('A Coruña','Vilasantar'), ('A Coruña','Vimianzo'), ('A Coruña','Zas'),

    ('Lugo','Abadín'), ('Lugo','Alfoz'), ('Lugo','Antas de Ulla'), ('Lugo','Baleira'),
    ('Lugo','Baralla'), ('Lugo','Barreiros'), ('Lugo','Becerreá'), ('Lugo','Begonte'),
    ('Lugo','Bóveda'), ('Lugo','Burela'), ('Lugo','Carballedo'), ('Lugo','Castro de Rei'),
    ('Lugo','Castroverde'), ('Lugo','Cervantes'), ('Lugo','Cervo'), ('Lugo','Chantada'),
    ('Lugo','O Corgo'), ('Lugo','Cospeito'), ('Lugo','Folgoso do Courel'), ('Lugo','A Fonsagrada'),
    ('Lugo','Foz'), ('Lugo','Friol'), ('Lugo','Guitiriz'), ('Lugo','Guntín'), ('Lugo','O Incio'),
    ('Lugo','Láncara'), ('Lugo','Lourenzá'), ('Lugo','Lugo'), ('Lugo','Meira'), ('Lugo','Mondoñedo'),
    ('Lugo','Monforte de Lemos'), ('Lugo','Monterroso'), ('Lugo','Muras'), ('Lugo','Navia de Suarna'),
    ('Lugo','Negueira de Muñiz'), ('Lugo','As Nogais'), ('Lugo','Ourol'), ('Lugo','Outeiro de Rei'),
    ('Lugo','Palas de Rei'), ('Lugo','Pantón'), ('Lugo','Paradela'), ('Lugo','O Páramo'),
    ('Lugo','A Pastoriza'), ('Lugo','Pedrafita do Cebreiro'), ('Lugo','Pol'),
    ('Lugo','A Pobra do Brollón'), ('Lugo','A Pontenova'), ('Lugo','Portomarín'), ('Lugo','Quiroga'),
    ('Lugo','Rábade'), ('Lugo','Ribadeo'), ('Lugo','Ribas de Sil'), ('Lugo','A Ribeira de Piquín'),
    ('Lugo','Riotorto'), ('Lugo','Samos'), ('Lugo','Sarria'), ('Lugo','O Saviñao'), ('Lugo','Sober'),
    ('Lugo','Taboada'), ('Lugo','Trabada'), ('Lugo','Triacastela'), ('Lugo','O Valadouro'),
    ('Lugo','O Vicedo'), ('Lugo','Vilalba'), ('Lugo','Viveiro'), ('Lugo','Xermade'), ('Lugo','Xove'),

    ('Ourense','Allariz'), ('Ourense','Amoeiro'), ('Ourense','Arnoia'), ('Ourense','Avión'),
    ('Ourense','Baltar'), ('Ourense','Bande'), ('Ourense','Baños de Molgas'), ('Ourense','Barbadás'),
    ('Ourense','O Barco de Valdeorras'), ('Ourense','Beade'), ('Ourense','Beariz'),
    ('Ourense','Os Blancos'), ('Ourense','Boborás'), ('Ourense','A Bola'), ('Ourense','O Bolo'),
    ('Ourense','Calvos de Randín'), ('Ourense','Carballeda de Avia'),
    ('Ourense','Carballeda de Valdeorras'), ('Ourense','O Carballiño'), ('Ourense','Cartelle'),
    ('Ourense','Castrelo de Miño'), ('Ourense','Castrelo do Val'), ('Ourense','O Castro de Caldelas'),
    ('Ourense','Celanova'), ('Ourense','Cenlle'), ('Ourense','Chandrexa de Queixa'), ('Ourense','Coles'),
    ('Ourense','Cortegada'), ('Ourense','Cualedro'), ('Ourense','Entrimo'), ('Ourense','Esgos'),
    ('Ourense','Gomesende'), ('Ourense','A Gudiña'), ('Ourense','O Irixo'), ('Ourense','Larouco'),
    ('Ourense','Laza'), ('Ourense','Leiro'), ('Ourense','Lobeira'), ('Ourense','Lobios'),
    ('Ourense','Maceda'), ('Ourense','Manzaneda'), ('Ourense','Maside'), ('Ourense','Melón'),
    ('Ourense','A Merca'), ('Ourense','A Mezquita'), ('Ourense','Montederramo'), ('Ourense','Monterrei'),
    ('Ourense','Muíños'), ('Ourense','Nogueira de Ramuín'), ('Ourense','Oímbra'), ('Ourense','Ourense'),
    ('Ourense','Paderne de Allariz'), ('Ourense','Padrenda'), ('Ourense','Parada de Sil'),
    ('Ourense','O Pereiro de Aguiar'), ('Ourense','A Peroxa'), ('Ourense','Petín'), ('Ourense','Piñor'),
    ('Ourense','Porqueira'), ('Ourense','A Pobra de Trives'), ('Ourense','Pontedeva'),
    ('Ourense','Punxín'), ('Ourense','Quintela de Leirado'), ('Ourense','Rairiz de Veiga'),
    ('Ourense','Ramirás'), ('Ourense','Ribadavia'), ('Ourense','O Riós'), ('Ourense','A Rúa'),
    ('Ourense','Rubiá'), ('Ourense','San Amaro'), ('Ourense','San Cibrao das Viñas'),
    ('Ourense','San Cristovo de Cea'), ('Ourense','San Xoán de Río'), ('Ourense','Sandiás'),
    ('Ourense','Sarreaus'), ('Ourense','Taboadela'), ('Ourense','A Teixeira'), ('Ourense','Toén'),
    ('Ourense','Trasmiras'), ('Ourense','A Veiga'), ('Ourense','Verea'), ('Ourense','Verín'),
    ('Ourense','Viana do Bolo'), ('Ourense','Vilamarín'), ('Ourense','Vilamartín de Valdeorras'),
    ('Ourense','Vilar de Barrio'), ('Ourense','Vilar de Santos'), ('Ourense','Vilardevós'),
    ('Ourense','Vilariño de Conso'), ('Ourense','Xinzo de Limia'), ('Ourense','Xunqueira de Ambía'),
    ('Ourense','Xunqueira de Espadañedo'),

    ('Pontevedra','Agolada'), ('Pontevedra','Arbo'), ('Pontevedra','Baiona'), ('Pontevedra','Barro'),
    ('Pontevedra','Bueu'), ('Pontevedra','Caldas de Reis'), ('Pontevedra','Cambados'),
    ('Pontevedra','O Campo Lameiro'), ('Pontevedra','Cangas'), ('Pontevedra','A Caniza'),
    ('Pontevedra','Catoira'), ('Pontevedra','Cerdedo-Cotobade'), ('Pontevedra','Covelo'),
    ('Pontevedra','Crecente'), ('Pontevedra','Cuntis'), ('Pontevedra','Dozón'),
    ('Pontevedra','A Estrada'), ('Pontevedra','Forcarei'), ('Pontevedra','Fornelos de Montes'),
    ('Pontevedra','Gondomar'), ('Pontevedra','O Grove'), ('Pontevedra','A Guarda'),
    ('Pontevedra','A Illa de Arousa'), ('Pontevedra','Lalín'), ('Pontevedra','A Lama'),
    ('Pontevedra','Marín'), ('Pontevedra','Meaño'), ('Pontevedra','Meis'), ('Pontevedra','Moaña'),
    ('Pontevedra','Mondariz'), ('Pontevedra','Mondariz-Balneario'), ('Pontevedra','Moraña'),
    ('Pontevedra','Mos'), ('Pontevedra','As Neves'), ('Pontevedra','Nigrán'), ('Pontevedra','Oia'),
    ('Pontevedra','Pazos de Borbén'), ('Pontevedra','Poio'), ('Pontevedra','Ponte Caldelas'),
    ('Pontevedra','Ponteareas'), ('Pontevedra','Pontecesures'), ('Pontevedra','Pontevedra'),
    ('Pontevedra','O Porriño'), ('Pontevedra','Portas'), ('Pontevedra','Redondela'),
    ('Pontevedra','Ribadumia'), ('Pontevedra','Rodeiro'), ('Pontevedra','O Rosal'),
    ('Pontevedra','Salceda de Caselas'), ('Pontevedra','Salvaterra de Miño'), ('Pontevedra','Sanxenxo'),
    ('Pontevedra','Silleda'), ('Pontevedra','Soutomaior'), ('Pontevedra','Tomiño'), ('Pontevedra','Tui'),
    ('Pontevedra','Valga'), ('Pontevedra','Vigo'), ('Pontevedra','Vila de Cruces'),
    ('Pontevedra','Vilaboa'), ('Pontevedra','Vilagarcía de Arousa'), ('Pontevedra','Vilanova de Arousa')
) AS c(provincia, nombre)
JOIN "TConfiguracionProvincias" p ON p."Nombre" = c.provincia
ON CONFLICT ("IdConfiguracionProvincia", "Nombre") DO NOTHING;
