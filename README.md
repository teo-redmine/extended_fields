# teo_extended_fields

TEO Extended Fields es un plugin de redmine que permite añadir campos personalizados  con el formato "Proyecto", permitiendo por ejemplo vincular tickets de diferentes contenedores entre sí de una forma más natural y directa.

## Instalación

Copiar o realizar un checkout de este repositorio en el directorio de plugins de
redmine: 
	
	redmine/plugins/teo_extended_fields

Una vez copiado debemos asegurarnos que el propietario y el grupo del plugin son correctos. También debemos asegurarnos de que los permisos son los adecuados, ejecutando la siguiente orden para restablecer los permisos por defectos en ficheros y carpetas:
```
chmod -R a+rX teo_extended_fields/
```
El plugin requiere la ejecución de migraciones, para ello dentro del directorio de redmine habría que ejecutar:
```	
bundle exec rake redmine:plugins:migrate NAME=teo_extended_fields RAILS_ENV=production
```

Por último sólo queda reiniciar Redmine.

## Desinstalación

Para desinstalar el plugin en primer lugar habría que deshacer las migraciones realizadas en la instalación del mismo, para ello nos situamos en el directorio de redmine y ejecutamos:
```
bundle exec rake redmine:plugins:migrate NAME=teo_extended_fields VERSION=0 RAILS_ENV=production
```

posteriormente  eliminamos la carpeta del plugin y reiniciamos Redmine.


## Cómo usar el plugin

En primer lugar debemos acceder a RedMine con un usuario administrador y dar de alta un campo personalizado.
```
	-> Administración -> Campos Personalizados -> Nuevo campo personalizado
```
Seleccionamos el tipo de objeto Peticiones y le damos a "Siguiente". El campo "Formato" seleccionamos "Proyecto", rellenar los campos como se desee y pulsamos el botón "Guardar"

Dos peculiaridades a tener en cuenta: 

- El campo "Perfil" sirve para filtrar los contenedores que saldrán en el seleccionable por los perfiles seleccionados.
- El campo "Estado por defecto" muestra una lista con los proyectos que son públicos.

Una vez se ha creado el campo personalizado vamos a un proyecto sobre el que tengamos permisos y visibilidad sobre el campo creado y pulsamos sobre "Nueva Petición" la damos de alta rellenando los campos necesarios. En la lista que nos muestra el nuevo campo que hemos creado deben salir los contenedores con estas características:

- La ordenación debe ser en árbol.
- Si el usuario logado es administrador, deben salir todos los contenedores, sino solo en los que se tienen visibilidad.
- En caso de no ser administrador y que se hayan definido en el campo personalizado perfiles por los que filtrar, se hará un filtrado por dichos perfiles. De manera que los contenedores resultantes deben ser aquellos en los que el usuario logado tiene los perfiles definidos en el campo personalizado.

Creado el ticket, vamos dentro del proyecto al listado de las peticiones pulsando en la pestaña "Peticiones" hacemos el filtro de dos maneras:

- En el campo "Añadir el filtro", seleccionamos el campo que hemos creado, seleccionamos un valor y pulsamos sobre el botón "Aceptar". Repetimos con varios valores.
- Abrimos el campo "Opciones" añadimos la columna del campo personalizado que hemos creado y agrupamos por el mismo. Pulsamos "Aceptar" para que se muestren los resultados.

## License

Author: Junta de Andalucía

License: GPLv2
