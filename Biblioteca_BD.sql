----------- Creacion de las tablas ----------------
-- Definición de la tabla Autores
CREATE TABLE autores(
    IdAutores SERIAL,
    NombreAutor VARCHAR(100) NOT NULL,
    Nacionalidad VARCHAR(50),
    FechaNacimiento DATE,
	CONSTRAINT Autores_id_autores_pk PRIMARY KEY(IdAutores));

-- Definición de la tabla Editoriales
CREATE TABLE editoriales(
    IdEditoriales SERIAL,
    NombreEditorial VARCHAR(100) NOT NULL,
    Direccion VARCHAR(255),
    SitioWeb VARCHAR(100),
	CONSTRAINT Editoriales_id_editoriales_pk PRIMARY KEY(IdEditoriales));

-- Definición de la tabla Libros
CREATE TABLE libros(
    IdLibros SERIAL,
    Titulo VARCHAR(255) NOT NULL,
    ISBN VARCHAR(13),
    AnioPublicacion INT,
    Categoria VARCHAR(50),
    CopiasDisponibles INT,
    IdEditorial INT,
    IdAutor INT,
	CONSTRAINT Libros_id_libros_pk PRIMARY KEY (IdLibros),
    CONSTRAINT Libros_id_editoriales_fk FOREIGN KEY (IdEditorial) REFERENCES editoriales (IdEditoriales),
    CONSTRAINT Libros_id_autores_fk FOREIGN KEY (IdAutor) REFERENCES autores (IdAutores));

-- Definición de la tabla Miembros
CREATE TABLE miembros (
    IdMiembros SERIAL,
    NombreMiembro VARCHAR(100) NOT NULL,
    Direccion VARCHAR(255),
    Email VARCHAR(100),
    FechaInscripcion DATE,
	CONSTRAINT Miembros_id_miembros_pk PRIMARY KEY (IdMiembros));

-- Definición de la tabla Prestamos
CREATE TABLE prestamos (
    IdPrestamos SERIAL,
    IdLibro INT,
    IdMiembro INT,
	IdEmpleado INT,
    FechaPrestamo DATE,
    FechaDevolucion DATE,
	CONSTRAINT Prestamos_id_prestamos_pk PRIMARY KEY (IdPrestamos),
    CONSTRAINT Prestamos_id_libros_fk FOREIGN KEY (IdLibro) REFERENCES libros(IdLibros),
    CONSTRAINT Prestamos_id_miembros_fk FOREIGN KEY (IdMiembro) REFERENCES miembros (IdMiembros),
	CONSTRAINT Prestamos_id_empleado_fk FOREIGN KEY(IdEmpleado) REFERENCES empleados(IdEmpleados));

-- Definición de la tabla Reservas
CREATE TABLE reservas(
    IdReservas SERIAL,
    IdLibro INT,
    IdMiembro INT,
    FechaReserva DATE,
	CONSTRAINT Reservas_id_reservas_pk PRIMARY KEY (IdReservas),
    CONSTRAINT Reservas_id_libro_fk FOREIGN KEY (IdLibro) REFERENCES libros (IdLibros),
    CONSTRAINT Reservas_id_miembro_fk FOREIGN KEY (IdMiembro) REFERENCES miembros (IdMiembros));

-- Definición de la tabla AutoresLibros
CREATE TABLE autoresLibros (
    IdLibro INT,
    IdAutor INT,
    PRIMARY KEY (IdLibro,IdAutor),
    CONSTRAINT autoresLibrros_id_libros_fk FOREIGN KEY (IdLibro) REFERENCES libros(IdLibros),
    CONSTRAINT autoresLibrros_id_autores_fk FOREIGN KEY (IdAutor) REFERENCES autores (IdAutores));

-- Definición de la tabla CategoriasLibros
CREATE TABLE categoriasLibros (
    IdCategoriasLibros SERIAL,
    NombreCategoria VARCHAR(50),
	CONSTRAINT CategoriasLibros_id_categoriaslibros_pk PRIMARY KEY(IdCategoriasLibros));

-- Definición de la tabla LibrosCategorias
CREATE TABLE librosCategorias (
    IdLibros SERIAL,
    IdCategorias SERIAL,
    PRIMARY KEY (IdLibros,IdCategorias),
    CONSTRAINT librosCategorias_id_libros_fk FOREIGN KEY (IdLibros) REFERENCES libros (IdLibros),
    CONSTRAINT librosCategorias_id_categorias_fk FOREIGN KEY (IdCategorias) REFERENCES categoriasLibros (IdCategoriasLibros));

-- Definición de la tabla Empleados
CREATE TABLE empleados (
    IdEmpleados SERIAL,
    NombreEmpleado VARCHAR(100) NOT NULL,
    Puesto VARCHAR(50),
    Salario DECIMAL(10, 2),
    FechaContratacion DATE,
	CONSTRAINT empleados_id_empleados PRIMARY KEY (idEmpleados));

-- Definición de la tabla HistorialPrestamos
CREATE TABLE historialPrestamos (
    IdHistorialPrestamos SERIAL,
    IdLibro INT,
    IdMiembro INT,
    FechaPrestamo DATE,
    FechaDevolucion DATE,
	CONSTRAINT historialPrestamos_id_historialPrestamos_pk PRIMARY KEY(IdHistorialPrestamos),
    CONSTRAINT historialPrestamos_id_libro_fk FOREIGN KEY (IdLibro) REFERENCES libros(IdLibros),
    CONSTRAINT historialPrestamos_id_miembro_fk FOREIGN KEY (IdMiembro) REFERENCES miembros(IdMiembros));

-- Definición de la tabla Eventos
CREATE TABLE eventos (
    IdEventos SERIAL,
    TituloEvento VARCHAR(255) NOT NULL,
    Descripcion TEXT,
    FechaEvento DATE,
    Lugar VARCHAR(100),
	CONSTRAINT eventos_id_eventos_pk PRIMARY KEY(IdEventos));

-- Definición de la tabla ParticipantesEvento
CREATE TABLE participantesEventos (
    IdEvento INT,
    IdMiembro INT,
    PRIMARY KEY (IdEvento,IdMiembro),
    CONSTRAINT participantesEventos_id_evento_fk FOREIGN KEY (IdEvento) REFERENCES eventos(IdEventos),
    CONSTRAINT participantesEventos_id_miembro_fk FOREIGN KEY (IdMiembro) REFERENCES miembros (IdMiembros));
		
------------------------------------------------------
---------------- JOINS ----------------
-- Los libros prestados actualmente junto con los nombres de los miembros que los tienen prestados.
SELECT prestamos.idlibro, libros.Titulo, miembros.NombreMiembro, prestamos.fechaprestamo, prestamos.fechadevolucion FROM libros 
JOIN prestamos ON (prestamos.IdLibro = libros.IdLibros)
JOIN miembros ON (miembros.IdMiembros = prestamos.idMiembro);

-- Lista de los libros que no han sido prestados desde hace más de 6 meses.
SELECT libros.Titulo, prestamos.FechaPrestamo 
FROM prestamos
JOIN libros ON (libros.IdLibros = prestamos.idLibro)
WHERE (prestamos.FechaPrestamo < '2023-04-30');

-- Cantidad total de libros escritos por cada autor.
SELECT autores.NombreAutor "Autor", COUNT(libros.IdLibros) "Total Libros Escritos"
FROM autores
JOIN libros ON (libros.IdAutor = autores.IdAutores)
GROUP BY autores.NombreAutor
ORDER BY COUNT(libros.IdLibros) DESC;

-- Libros que han sido escritos por autores de una nacionalidad específica.
SELECT libros.Titulo "Libro", autores.NombreAutor "Autor", autores.Nacionalidad 
FROM autores 
JOIN libros ON (libros.IdAutor = autores.IdAutores)
WHERE autores.Nacionalidad = 'China';

-- La editorial que ha publicado más libros
SELECT editoriales.NombreEditorial "Editorial", COUNT(libros.IdLibros) "Total_Libros_Publicados"
FROM editoriales
JOIN libros ON (libros.IdEditorial = editoriales.IdEditoriales)
GROUP BY editoriales.NombreEditorial
ORDER BY COUNT(libros.IdLibros) DESC LIMIT 1;

-- Listar los miembros que han realizado reservas de libros y los libros reservados.
SELECT reservas.Idlibro, reservas.IdMiembro,  miembros.NombreMiembro "Miembro", libros.Titulo "Titulo_Libro"
FROM miembros
JOIN reservas ON (reservas.IdMiembro = miembros.IdMiembros) 
JOIN libros ON (libros.IdLibros = reservas.IdLibro)
ORDER BY reservas.IdLibro DESC;

-- Los libros que comparten una misma categoría
SELECT categoriasLibros.NombreCategoria "Categoria", COUNT(libros.IdLibros) "Mismo_Libro"
FROM libros
JOIN categoriasLibros ON (categoriasLibros.IdCategoriasLibros = libros.IdLibros)
GROUP BY categoriasLibros.NombreCategoria
ORDER BY COUNT(libros.IdLibros) DESC;

-- Listar los autores y la cantidad de libros que han escrito en una categoría específica.
SELECT autores.NombreAutor "Autor", COUNT(libros.IdAutor) "Libros_Escritos"
FROM autores
JOIN libros ON (libros.IdAutor = autores.IdAutores)
WHERE libros.Categoria = 'Technology'
GROUP BY autores.NombreAutor;