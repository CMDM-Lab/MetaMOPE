class RunPeakEvaluationJob < ApplicationJob
  queue_as :default

  def perform(project_id, upload_id)
    @project = Project.find(project_id)
    #@project.status = Project::RUNNING
    @project.state = "running"
    @project.save
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::RUNNING).deliver_now
    metomope_peak_evaluation = Rails.root.join('lib', 'metamope','build_ref_lib.R')
    injection_order_file = @upload.files.all.first
    standard_file = @upload.files.all.second
    mzxml_file = @upload.files.all.last
    mcq_win_size = @project.mcq_win_size
    mcq_threshold = @project.mcq_threshold
    intensity_threshold = @project.peak_int_threshold
    flatness_factor = @project.flat_fac
    std_blk_threshold = @project.std_blk
    rt_rsd_threshold = @project.rsd_rt
    metamope_projects = Rails.root.join('tmp', 'metomope', 'projects')
    outfile = metamope_projects + "/#{@project.id}/" + 'result.csv'
    zipfile = metamope_projects + "/#{@project.id}/" + 'Result.zip'
    output = `Rscript --vanilla #{metamope_peak_evaluation} < #{injection_order_file} #{standard_file} #{mzxml_file} > #{outfile} [#{maq_win_size} #{mcq_threshold} #{intensity_threshold} #{flatness_factor} #{std_blk_threshold} #{rt_rsd_threshold}]`
    @project.output = output 
    if File.exists?(outfile_1)
	    zip_log = `zip -j #{zipfile} #{outfile_1}`
    #@project.status = Project::FINISHED
    @project.state = "finished"
    @project.save!
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::FINISHED).deliver_now
    end 
  end
end
