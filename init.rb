# encoding: utf-8
require 'redmine'

require_dependency 'extended_fields_hook'
require_dependency 'extended_field_format'

Rails.logger.info 'Starting Extended Fields plugin for Redmine'

Rails.configuration.to_prepare do
    
    unless ActionView::Base.included_modules.include?(ExtendedFieldsHelper)
        ActionView::Base.send(:include, ExtendedFieldsHelper)
    end

    unless CustomFieldsHelper.included_modules.include?(ExtendedFieldsHelperPatch)
        CustomFieldsHelper.send(:include, ExtendedFieldsHelperPatch)
    end

    unless AdminController.included_modules.include?(CustomFieldsHelper)
        AdminController.send(:helper, :custom_fields)
        AdminController.send(:include, CustomFieldsHelper)
    end
    
    unless WikiController.included_modules.include?(CustomFieldsHelper)
        WikiController.send(:helper, :custom_fields)
        WikiController.send(:include, CustomFieldsHelper)
    end

    if defined? ActionView::OptimizedFileSystemResolver
        unless ActionView::OptimizedFileSystemResolver.method_defined?(:[])
            ActionView::OptimizedFileSystemResolver.send(:include, ExtendedFileSystemResolverPatch)
        end
    end

    if defined? XlsExportController
        unless XlsExportController.included_modules.include?(ExtendedFieldsHelper)
            XlsExportController.send(:include, ExtendedFieldsHelper)
        end
    end
end

Redmine::Plugin.register :teo_extended_fields do
    name 'Teo Extended fields plugin'
    author 'Junta de Andalucía. Andriylesyuk. Mike Sweetman.'
    author_url "http://www.juntadeandalucia.es"  
    url 'https://github.com/teo-redmine/teo_extended_fields.git'
    description 'Habilita nuevos tipos de campos personalizados, mejora listados, etc.'
    version '0.0.1'
end
