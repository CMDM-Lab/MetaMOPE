class RunPeakEvaluationJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    @project = Project.find(project_id)
    @upload = Upload.find_by(:project_id => @project.id)
    @project.state = "running"
    @project.save
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::RUNNING).deliver_now
    metomope_peak_evaluation = Rails.root.join('lib', 'metamope','build_ref_lib.R')
    injection_order_file = @project.injection
    standard_file = @project.standard
    mzxml_file = @upload.mzxmls
    mcq_win_size = @project.mcq_win_size
    mcq_threshold = @project.mcq_threshold
    intensity_threshold = @project.peak_int_threshold
    flatness_factor = @project.flat_fac
    std_blk_threshold = @project.std_blk
    rt_rsd_threshold = @project.rsd_rt
    metamope_projects = Rails.root.join('tmp', 'metomope', 'projects').to_s
    working_dir = metamope_projects + "/#{@project.id}"
    outfile = metamope_projects + "/#{@project.id}/" + 'result.csv'
    zipfile = metamope_projects + "/#{@project.id}/" + 'Result.zip'
    #output = `Rscript --vanilla #{metamope_peak_evaluation} < #{injection_order_file} #{standard_file} #{mzxml_file} > #{outfile} [#{mcq_win_size} #{mcq_threshold} #{intensity_threshold} #{flatness_factor} #{std_blk_threshold} #{rt_rsd_threshold}]`
    output = `Rscript --vanilla #{metamope_peak_evaluation} -p '[#{working_dir} #{injection_order_file} #{standard_file} #{mzxml_file} #{mcq_win_size} #{mcq threshold} #{intensity_threshold} #{flatness_factor} #{std_blk_threshold} #{rt_rsd_threshold} #{outfile}]' 2>&1 > #{metamope_projects}/#{@project.id}/log.txt`
    @project.output = output 
    if File.exists?(outfile)
	    zip_log = `zip -j #{zipfile} #{outfile}`
    #@project.status = Project::FINISHED
    @project.state = "finished"
    @project.save!
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::FINISHED).deliver_now
    end 
  end
end
