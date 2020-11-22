#Creamos la base de datos
Create database academatica_db;

USE academatica_db;

#Creamos la tabla que usaremos en nuestro dashboard
CREATE TABLE `videos` (
  `video_id` text DEFAULT NULL,
  `id` text DEFAULT NULL,
  `title` text DEFAULT NULL,
  `kind` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `etag` text DEFAULT NULL,
  `published_at` text DEFAULT NULL,
  `views` double DEFAULT NULL,
  `likes` double DEFAULT NULL,
  `dislikes` double DEFAULT NULL,
  `favorites` double DEFAULT NULL,
  `comments` double DEFAULT NULL,
  `iframe` text DEFAULT NULL,
  `link` text DEFAULT NULL
);
