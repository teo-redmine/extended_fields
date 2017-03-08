# encoding: utf-8
module Redmine
    module FieldFormat


        # Clase para personalizar el Formato del campo personalizado tipo Proyecto.
        # Hereda de RecordList y se sobreescriben los metodos necesarios.
        class ProjectFormat < RecordList
            
            add 'project'
            self.customized_class_names = nil
            self.form_partial = 'custom_fields/formats/project'

            # Atributo que se guardara en la columna format_store de la tabla custom_field
            # ya que no existe un campo habilitado especificamente para ello. Se hace igual
            # que para los campos personalizados de tipo User.
            field_attributes :project_user_role

            def cast_single_value(custom_field, value, customized = nil)
                unless value.blank?
                    Project.find_by_id(value)
                else
                    nil
                end
            end
            

            # Lista de posibles valores que se pueden seleccionar a la hora
            # de utilizar el filtro avanzado. Posteriormente a la llamada
            # del metodo cuando se pinta el select te filtra los caracteres extraños
            # como el '&' lo que imposibilita poner un espacio en blanco del tipo '&nbsp;'
            def possible_values_options(custom_field, object = nil)
                projects = projects_filtered_with_current_user_and_selected_roles(nil, custom_field)
                s = []
                Project.project_tree(projects) do |project, level|
                    s << [((level > 0 ? '» ' * level : '') + project.name), project.id.to_s]
                end
                s
            end


            # Antes de guardar el campo, se eliminan los valores en blanco
            # del array, ya que siempre viene uno en la respuesta.
            def before_custom_field_save(custom_field)
                super
                if custom_field.project_user_role.is_a?(Array)
                    custom_field.project_user_role.map!(&:to_s).reject!(&:blank?)
                end
            end

            # Se sobreescribe este metodo en caso de que sea un field_format de 
            # tipo Proyecto, ya que si no lo hacemos y no devolvemos este valor,
            # da un error 500 al "agrupor por" en la busqueda avanzada de peticiones.
            def order_statement(custom_field)
                "COALESCE(#{join_alias custom_field}.value, '')"
            end


            # Renderiza el edit_tag como select_tag. Devuelve el select con las opciones
            # en caso de que el campo personalizable sea de este tipo select.
            def select_edit_tag(view, tag_id, tag_name, custom_value, options={})
                blank_option = ''.html_safe
                unless custom_value.custom_field.multiple?
                    if custom_value.custom_field.is_required?
                    unless custom_value.custom_field.default_value.present?
                        blank_option = view.content_tag('option', "--- #{l(:actionview_instancetag_blank_option)} ---", :value => '')
                    end
                    else
                        blank_option = view.content_tag('option', '&nbsp;'.html_safe, :value => '')
                    end
                end
                filtered_projects = projects_filtered_with_current_user_and_selected_roles(custom_value, custom_value.custom_field)
                project_selected = Project.find_by_id(custom_value.value)
                options_tags = blank_option + project_tree_options_for_select(filtered_projects, view, :selected => project_selected)
                s = view.select_tag(tag_name, options_tags, options.merge(:id => tag_id, :multiple => custom_value.custom_field.multiple?))
                if custom_value.custom_field.multiple?
                    s << view.hidden_field_tag(tag_name, '')
                end
                s
            end

            # Renderiza el edit_tag como check_box_tag o radio_tag. Devuelve el select 
            # con las opciones en caso de que el campo personalizable sea de este tipo select.
            def check_box_edit_tag(view, tag_id, tag_name, custom_value, options={})
                opts = []
                unless custom_value.custom_field.multiple? || custom_value.custom_field.is_required?
                    opts << ["(#{l(:label_none)})", '']
                end
                opts += possible_custom_value_options(custom_value)
                s = ''.html_safe
                tag_method = custom_value.custom_field.multiple? ? :check_box_tag : :radio_button_tag
                opts.each do |label, value|
                    value ||= label
                    checked = (custom_value.value.is_a?(Array) && custom_value.value.include?(value)) || custom_value.value.to_s == value
                    tag = view.send(tag_method, tag_name, value, checked, :id => tag_id)
                    # set the id on the first tag only
                    tag_id = nil
                    s << view.content_tag('label', tag + ' ' + label) 
                end
                if custom_value.custom_field.multiple?
                  s << view.hidden_field_tag(tag_name, '')
                end
                css = "#{options[:class]} check_box_group"
                view.content_tag('span', s, options.merge(:class => css))
            end            


            # Se redefine la funcion para organizar la lista como un arbol, es necesario
            # porque la funcion content_tag necesita que se le pase la vista, si se utiliza
            # la original no funciona. Cuando se filtra por proyectos también devuelve el
            # arbol correctamente.
            def project_tree_options_for_select(projects, view, options = {})
                s = ''.html_safe
                if blank_text = options[:include_blank]
                    if blank_text == true
                        blank_text = '&nbsp;'.html_safe
                    end
                    s << view.content_tag('option', blank_text, :value => '')
                end
                Project.project_tree(projects) do |project, level|
                    name_prefix = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
                    tag_options = {:value => project.id}
                    if project == options[:selected] || (options[:selected].respond_to?(:include?) && options[:selected].include?(project))
                        tag_options[:selected] = 'selected'
                    else
                        tag_options[:selected] = nil
                    end
                    tag_options.merge!(yield(project)) if block_given?
                    s << view.content_tag('option', name_prefix + h(project), tag_options)
                end
                s.html_safe
            end


            private


            # Metodo privado que devuelve el listado de proyectos a los que
            # pertenece el usuario actual segun los roles definidos en el 
            # campo personalizado. En caso de ser un usuario administrador
            # se devuelven todos. En caso de no tener permisos para el proyecto
            # que este guardado, debe cargarlo igualmente.
            def projects_filtered_with_current_user_and_selected_roles(custom_value, custom_field)
                filterProjects = Project.visible.order(:id)
                user = User.current
                if custom_field.project_user_role.is_a?(Array) && !user.admin
                    id_user = User.current.id
                    role_ids = custom_field.project_user_role.map(&:to_s).reject(&:blank?).map(&:to_i)
                    if role_ids.any?
                        if custom_value == nil
                            filterProjects = Project.joins(memberships: :user).where("users.id = ? and members.id IN (SELECT DISTINCT member_id FROM member_roles WHERE role_id IN (?))", id_user, role_ids)
                        else
                            filterProjects = Project.joins(memberships: :user).where("(users.id = ? and members.id IN (SELECT DISTINCT member_id FROM member_roles WHERE role_id IN (?))) or project_id = ?", id_user, role_ids, custom_value.value)
                        end
                    end
                end
                filterProjects
            end

        end
    end
end
