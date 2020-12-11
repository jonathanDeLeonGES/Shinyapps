CREATE TABLE covid.time_series_covid19_confirmed_global (
id INT NOT NULL AUTO_INCREMENT,
province varchar(255),
country varchar(255),
lat decimal(10,8),
longitud decimal(11,8),
fecha DATE,
valor INT DEFAULT 0,
PRIMARY KEY (id)
);


CREATE TABLE covid.time_series_covid19_deaths_global (
id INT NOT NULL AUTO_INCREMENT,
province varchar(255),
country varchar(255),
lat decimal(10,8),
longitud decimal(11,8),
fecha DATE,
valor INT DEFAULT 0,
PRIMARY KEY (id)
);


CREATE TABLE covid.time_series_covid19_recovered_global (
id INT NOT NULL AUTO_INCREMENT,
province varchar(255),
country varchar(255),
lat decimal(10,8),
longitud decimal(11,8),
fecha DATE,
valor INT DEFAULT 0,
PRIMARY KEY (id)
);
