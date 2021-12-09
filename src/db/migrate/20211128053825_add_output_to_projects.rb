class AddOutputToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :output, :text
  end
end
