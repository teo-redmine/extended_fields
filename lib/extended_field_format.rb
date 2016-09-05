module Redmine
    module FieldFormat

        # Clase para personalizar el Formato del campo personalizado tipo Proyecto.
        # Hereda de RecordList y se sobreescriben los metodos necesarios.
        class ProjectFormat < RecordList
            add 'project'
            self.customized_class_names = nil
            self.form_partial = 'custom_fields/formats/project'

            def cast_single_value(custom_field, value, customized = nil)
                unless value.blank?
                    Project.find_by_id(value)
                else
                    nil
                end
            end
            
            def possible_values_options(custom_field, object = nil)
                if object.is_a?(User)
                    projects = Project.visible(object).all
                else
                    projects = Project.visible.all
                end
                projects.collect{ |project| [ project.name, project.id.to_s ] }
            end

            # Se sobreescribe este metodo en caso de que sea un field_format de 
            # tipo Proyecto, ya que si no lo hacemos y no devolvemos este valor,
            # da un error 500 al "agrupor por" en la busqueda avanzada de peticiones.
            def order_statement(custom_field)
                "COALESCE(#{join_alias custom_field}.value, '')"
            end
        end
    end
end
