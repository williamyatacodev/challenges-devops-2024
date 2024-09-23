# Challenge 05

 En este desafío se centra analizar, identificar y corregir el proyecto, logrando desplegar el aplicativo.

 Se descargo el proyecto:
    
    git clone -b devops-docker-warning https://github.com/roxsross/devops-static-web.git


## Problemas

1. En el docker compose se ha asociado un network pero no esta creado.
2. En el Dockerfile del app la version 15 de node tiene errores al obtener la imagen.
3. En el Dockerfile del app, no se instala las dependencias.
4. En el Dockerfile del app no se expone las variables de la base de datos adecuadamente.
5. En el docker compose, en el servicio nginx se quiere utilizar la imagen de un repositorio privado javielrezende/nginx.
6. En el Dockerfile del nginx no tiene configuracion del archivo ngnix.conf

## Solucion

1. En el docker compose, se crea un network llamado node-network
2. En el Dockerfile del app, se actualizo a node version 16
3. En el Dockerfile del app, se agrego la instalacion de las dependencias
4. En el Dockerfile del app, se expuso la variable del nombre de la base de datos DATABASE, las demas credenciales no fue necesario.
5. En el docker compose, se remueve la imagen javielrezende/nginx
6. En el Dockefile de ngninx, se agrego la configuracion del archivo nginx.conf
