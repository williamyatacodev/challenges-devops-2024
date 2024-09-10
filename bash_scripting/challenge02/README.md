# Challenge 02

 En este reto se creará un script automtizado que desplegará una aplicación web desarrollada en Python con el framework Flask , utilizando Nginx como proxy inverso y Gunicorn como servidor WSGI.

## Ejecucion

Ejecutar el siguiente script [challenge02.sh](/bash_scripting/challenge02/challenge02.sh)  y se desplegara el proyecto.
Teniendo las siguientes consideraciones:

    $USER -> usuario de linux
    $HOME -> directorio principal

## Observaciones

El [proyecto](https://github.com/roxsross/devops-static-web.git) en la rama booklibrary, tiene una particularidad que no se puede desplegar por un problema con Flask-SQLAlchemy. Tomando en consideracion en un contexto donde se debe desplegar sin hacer cambios en el codigo, se instalará las dependencias en versiones que soporten, tal como se ha realizado en este challenge. Por el contrario, si se puede cambiar el codigo, no es necesario limitar las versiones de la dependencia, esto se resolvio de esa manera [aqui](/linux/challenge01/README.md)
