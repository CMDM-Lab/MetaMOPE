class AddParametersToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :mcq_win_size,       :integer
    add_column :projects, :sample_repeat,      :integer
    add_column :projects, :flat_fac,           :integer
    add_column :projects, :mcq_threshold,      :integer
    add_column :projects, :peak_int_threshold, :integer
    add_column :projects, :std_blk,            :integer
    add_column :projects, :rsd_rt,             :integer
    add_column :projects, :jagedness,          :integer
    add_column :projects, :assy_fac,           :integer
    add_column :projects, :fwhm,               :integer
    add_column :projects, :modality,           :integer
  end
end
