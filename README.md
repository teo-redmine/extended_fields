= teo_extended_fields

TEO Extended Fields es un plugin de redmine que permite añadir campos personalizados  con el formato "Proyecto", permitiendo por ejemplo vincular tickets de diferentes contenedores entre sí de una forma más natural y directa.

== Instalación

Copiar o realizar un checkout de este repositorio en el directorio de plugins de
redmine: 
	
	redmine/plugins/teo_extended_fields

Una vez copiado debemos asegurarnos que el propietario y el grupo del plugin son correctos. También debemos asegurarnos de que los permisos son los adecuados, ejecutando la siguiente orden para restablecer los permisos por defectos en ficheros y carpetas:

    chmod -R a+rX teo_extended_fields/

El plugin requiere la ejecución de migraciones, para ello dentro del directorio de redmine habría que ejecutar:
	
	bundle exec rake redmine:plugins:migrate NAME=teo_extended_fields RAILS_ENV=production

Por último sólo queda reiniciar Redmine.

== Desinstalación

Para desinstalar el plugin en primer lugar habría que deshacer las migraciones realizadas en la instalación del mismo, para ello nos situamos en el directorio de redmine y ejecutamos:

	bundle exec rake redmine:plugins:migrate NAME=teo_extended_fields VERSION=0 RAILS_ENV=production

posteriormente  eliminamos la carpeta del plugin y reiniciamos Redmine.

---
Author: Junta de Andalucía

License: GPLv2
