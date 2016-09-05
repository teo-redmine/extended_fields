class ExtendedFieldsHook  < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context = {})
    	# Incluye la CSS del plugin
    	# <link rel="stylesheet" media="screen" href="/plugin_assets/teo_extended_fields/stylesheets/extended_fields.css" />
        stylesheet_link_tag('extended_fields', :plugin => 'teo_extended_fields')
    end


    # Helper method to directly render a partial using the context.
    render_on :view_custom_fields_form_upper_box,            :partial => 'custom_fields/extended'
    render_on :view_custom_fields_form_user_custom_field,    :partial => 'custom_fields/options'
    render_on :view_custom_fields_form_version_custom_field, :partial => 'custom_fields/options'

end
