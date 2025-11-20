DO $$

DECLARE
    
    nuevoIdMoneda INTEGER;       
    idUSD INTEGER;                
    idEUR INTEGER;                
    idCOP INTEGER;                
    idGBP INTEGER;                

   
    -- Variables para CambioMoneda
    
    nuevoIdCambio INTEGER;        
    v_fecha DATE;                 
    fecha_inicio DATE;            
    fecha_fin DATE;               

    -- Bases para simular tasas 
    v_base_usd NUMERIC := 1.000000;
    v_base_eur NUMERIC := 1.050000;
    v_base_cop NUMERIC := 0.000270;
    v_base_gbp NUMERIC := 1.200000;

    -- variables auxiliares para cálculo
    v_random_factor NUMERIC;
    v_rate NUMERIC;

    -- contadores informativos
    contador INTEGER := 0;
    total_tmp INTEGER := 0;

    -- auxiliares temporales usados en validaciones
    tmp_id INTEGER;
    tmp_count INTEGER;

BEGIN

   
    -- 1) Calcular rango  (últimos 2 meses)
    fecha_fin := CURRENT_DATE;
    fecha_inicio := (CURRENT_DATE - INTERVAL '2 months')::date;


    
    SELECT MAX(id) INTO nuevoIdMoneda FROM Moneda;
    -- Si la tabla Moneda está vacía, nuevoIdMoneda será NULL
    IF nuevoIdMoneda IS NULL THEN
        -- Tomamos la decisión de iniciar en 1 
        nuevoIdMoneda := 1;
    ELSE
        -- si trae un valor, incrementamos para el primer id disponible
        nuevoIdMoneda := nuevoIdMoneda + 1;
    END IF;

    

    -- USD
    SELECT id INTO idUSD FROM Moneda WHERE Sigla = 'USD';
    IF idUSD IS NULL THEN
        -- Insertar USD 
        INSERT INTO Moneda (Id, Moneda, Sigla)
        VALUES (nuevoIdMoneda, 'Dólar estadounidense', 'USD');
        idUSD := nuevoIdMoneda;
        

        
        SELECT MAX(id) INTO tmp_id FROM Moneda;
        IF tmp_id IS NULL THEN
            tmp_id := 1;
        ELSE
            tmp_id := tmp_id + 1;
        END IF;
        nuevoIdMoneda := tmp_id;
    ELSE
        RAISE NOTICE 'USD ya existe con id %', idUSD;
    END IF;

    -- EUR
    SELECT id INTO idEUR FROM Moneda WHERE Sigla = 'EUR';
    IF idEUR IS NULL THEN
        INSERT INTO Moneda (Id, Moneda, Sigla)
        VALUES (nuevoIdMoneda, 'Euro', 'EUR');
        idEUR := nuevoIdMoneda;
        RAISE NOTICE 'EUR insertada con id %', idEUR;

        SELECT MAX(id) INTO tmp_id FROM Moneda;
        IF tmp_id IS NULL THEN
            tmp_id := 1;
        ELSE
            tmp_id := tmp_id + 1;
        END IF;
        nuevoIdMoneda := tmp_id;
    ELSE
        RAISE NOTICE 'EUR ya existe con id %', idEUR;
    END IF;

    -- COP
    SELECT id INTO idCOP FROM Moneda WHERE Sigla = 'COP';
    IF idCOP IS NULL THEN
        INSERT INTO Moneda (Id, Moneda, Sigla)
        VALUES (nuevoIdMoneda, 'Peso colombiano', 'COP');
        idCOP := nuevoIdMoneda;
        RAISE NOTICE 'COP insertada con id %', idCOP;

        SELECT MAX(id) INTO tmp_id FROM Moneda;
        IF tmp_id IS NULL THEN
            tmp_id := 1;
        ELSE
            tmp_id := tmp_id + 1;
        END IF;
        nuevoIdMoneda := tmp_id;
    ELSE
        RAISE NOTICE 'COP ya existe con id %', idCOP;
    END IF;

    -- GBP
    SELECT id INTO idGBP FROM Moneda WHERE Sigla = 'GBP';
    IF idGBP IS NULL THEN
        INSERT INTO Moneda (Id, Moneda, Sigla)
        VALUES (nuevoIdMoneda, 'Libra esterlina', 'GBP');
        idGBP := nuevoIdMoneda;
        RAISE NOTICE 'GBP insertada con id %', idGBP;

        SELECT MAX(id) INTO tmp_id FROM Moneda;
        IF tmp_id IS NULL THEN
            tmp_id := 1;
        ELSE
            tmp_id := tmp_id + 1;
        END IF;
        nuevoIdMoneda := tmp_id;
    ELSE
        RAISE NOTICE 'GBP ya existe con id %', idGBP;
    END IF;

    
    -- 3) Preparar nuevoIdCambio 
    
    SELECT MAX(id) INTO nuevoIdCambio FROM CambioMoneda;
    IF nuevoIdCambio IS NULL THEN
        -- Si no hay registros, iniciamos en 1 
        nuevoIdCambio := 1;
    ELSE
        -- si hay registros, iniciar en siguiente
        nuevoIdCambio := nuevoIdCambio + 1;
    END IF;

    

    
    -- 4) Crear tabla temporal tmp_cambios
    
    DROP TABLE IF EXISTS tmp_cambios;
    CREATE TEMP TABLE tmp_cambios(
        id int,
        idmoneda int,
        fecha date,
        cambio numeric
    );

   
    -- 5) Llenar tmp_cambios con un bucle 
   
    
    v_fecha := fecha_inicio;
    contador := 0;

    WHILE v_fecha <= fecha_fin LOOP
        -- USD: calcular tasa 
        v_random_factor := (random() - 0.5) * 0.02; 
        v_rate := round((v_base_usd * (1 + v_random_factor))::numeric, 6);

        INSERT INTO tmp_cambios(id, idmoneda, fecha, cambio)
        VALUES (nuevoIdCambio, idUSD, v_fecha, v_rate);
        nuevoIdCambio := nuevoIdCambio + 1;
        contador := contador + 1;

        -- EUR
        v_random_factor := (random() - 0.5) * 0.02;
        v_rate := round((v_base_eur * (1 + v_random_factor))::numeric, 6);

        INSERT INTO tmp_cambios(id, idmoneda, fecha, cambio)
        VALUES (nuevoIdCambio, idEUR, v_fecha, v_rate);
        nuevoIdCambio := nuevoIdCambio + 1;
        contador := contador + 1;

        -- COP
        v_random_factor := (random() - 0.5) * 0.02;
        v_rate := round((v_base_cop * (1 + v_random_factor))::numeric, 6);

        INSERT INTO tmp_cambios(id, idmoneda, fecha, cambio)
        VALUES (nuevoIdCambio, idCOP, v_fecha, v_rate);
        nuevoIdCambio := nuevoIdCambio + 1;
        contador := contador + 1;

        -- GBP
        v_random_factor := (random() - 0.5) * 0.02;
        v_rate := round((v_base_gbp * (1 + v_random_factor))::numeric, 6);

        INSERT INTO tmp_cambios(id, idmoneda, fecha, cambio)
        VALUES (nuevoIdCambio, idGBP, v_fecha, v_rate);
        nuevoIdCambio := nuevoIdCambio + 1;
        contador := contador + 1;

        -- Avanzar fecha en 1 día
        v_fecha := v_fecha + INTERVAL '1 day';
    END LOOP;

    -- Contador informativo
    SELECT COUNT(*) INTO total_tmp FROM tmp_cambios;
   

    
    -- 6) Insertar 
   
    

    INSERT INTO CambioMoneda (Id, IdMoneda, Fecha, Cambio)
    SELECT id, idmoneda, fecha, cambio
    FROM tmp_cambios
    ON CONFLICT (IdMoneda, Fecha)
        DO UPDATE SET
            Cambio = EXCLUDED.Cambio;
    
    DROP TABLE IF EXISTS tmp_cambios;

   
END
$$ LANGUAGE plpgsql;
