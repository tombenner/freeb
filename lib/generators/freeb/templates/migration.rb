class <%= @migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :<%= @table_name %> do |t|
      t.string :freebase_id
      t.string :name
      <% @properties.each do |property| %>t.<%= property[:type] %> :<%= property[:key] %>
      <% end %>
      t.timestamps
    end

    add_index :<%= @table_name %>, :freebase_id
  end
end