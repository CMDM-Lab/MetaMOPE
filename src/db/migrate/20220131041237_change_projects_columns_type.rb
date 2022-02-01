class ChangeProjectsColumnsType < ActiveRecord::Migration[6.1]
  def change
    change_column :projects, :mcq_win_size, :float
    change_column :projects, :flat_fac, :float
    change_column :projects, :mcq_threshold, :float
    change_column :projects, :peak_int_threshold, :float
    change_column :projects, :std_blk, :float
    change_column :projects, :rsd_rt, :float
  end
end
