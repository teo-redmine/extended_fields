class AddCustomFieldsSignificantAndHint < ActiveRecord::Migration

    def self.up
        add_column :custom_fields, :significant, :boolean, :default => true, :null => false
        add_column :custom_fields, :hint,       :string
    end

    def self.down
        remove_column :custom_fields, :significant
        remove_column :custom_fields, :hint
    end

end
