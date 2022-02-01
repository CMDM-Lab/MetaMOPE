class RemoveColumnsFromProjects < ActiveRecord::Migration[6.1]
  def change
    remove_column :projects, :upload
    remove_column :projects, :sample_repeat
    remove_column :projects, :jagedness
    remove_column :projects, :assy_fac
    remove_column :projects, :fwhm
    remove_column :projects, :modality
  end
end
