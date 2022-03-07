class AddFileColumnsToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :standard, :string
    add_column :projects, :injection, :string
  end
end
