CREATE TABLE covid.time_series_covid19_confirmed_global (
id INT NOT NULL AUTO_INCREMENT,
province varchar(255),
country varchar(255),
lat varchar(255),
longitud varchar(255),
fecha varchar(255),
valor INT,
PRIMARY KEY (id)
);


CREATE TABLE covid.time_series_covid19_deaths_global (
id INT NOT NULL AUTO_INCREMENT,
province varchar(255),
country varchar(255),
lat varchar(255),
longitud varchar(255),
fecha varchar(255),
valor INT,
PRIMARY KEY (id)
);


CREATE TABLE covid.time_series_covid19_recovered_global (
id INT NOT NULL AUTO_INCREMENT,
province varchar(255),
country varchar(255),
lat varchar(255),
longitud varchar(255),
fecha varchar(255),
valor INT,
PRIMARY KEY (id)
);
