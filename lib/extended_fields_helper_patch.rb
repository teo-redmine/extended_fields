require_dependency 'custom_fields_helper'

module ExtendedFieldsHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        
        base.class_eval do
            unloadable

            alias_method       :show_value,                     :show_extended_value
            alias_method_chain :custom_field_tag,               :extended
            alias_method_chain :custom_field_tag_for_bulk_edit, :extended
        end
    end

    module InstanceMethods

        def show_extended_value(custom_value, html = true)
            if custom_value.value && !custom_value.value.empty? &&
               (template = find_custom_field_template(custom_value.custom_field))
                render(:partial => template,
                       :locals  => { :controller   => controller,
                                     :project      => @project,
                                     :request      => request,
                                     :custom_field => custom_value,
                                     :html         => html })
            else
                format_object(custom_value, html)
            end
        end

        def custom_field_tag_with_extended(prefix, custom_value)
            custom_field = custom_value.custom_field

            tag = custom_field_tag_without_extended(prefix, custom_value)

            unless custom_field.hint.blank?
                tag << tag(:br)
                tag << content_tag(:em, h(custom_field.hint))
            end

            if (template = find_custom_field_edit_template(custom_field))
                tag << render(:partial => template,
                              :locals  => { :controller   => controller,
                                            :project      => @project,
                                            :request      => request,
                                            :custom_field => custom_value,
                                            :name         => prefix,
                                            :field_name   => custom_field_tag_name(prefix, custom_field),
                                            :field_id     => custom_field_tag_id(prefix, custom_field) })
            end

            tag
        end

        def custom_field_tag_for_bulk_edit_with_extended(prefix, custom_field, objects = nil, value = '')
            tag = custom_field_tag_for_bulk_edit_without_extended(prefix, custom_field, objects, value)

            unless custom_field.hint.blank?
                tag << tag(:br)
                tag << content_tag(:em, h(custom_field.hint))
            end

            if (template = find_custom_field_edit_template(custom_field))
                tag << render(:partial => template,
                              :locals  => { :controller   => controller,
                                            :project      => @project,
                                            :request      => request,
                                            :custom_field => custom_value,
                                            :name         => prefix,
                                            :field_name   => custom_field_tag_name(prefix, custom_field),
                                            :field_id     => custom_field_tag_id(prefix, custom_field) })
            end

            tag
        end

    end
end
