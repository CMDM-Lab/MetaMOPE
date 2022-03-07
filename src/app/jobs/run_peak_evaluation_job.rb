class RunPeakEvaluationJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    @project = Project.find(project_id)
    @project.state = "running"
    @project.save
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::RUNNING).deliver_now
    metamope_peak_evaluation = Rails.root.join('lib', 'metamope','build_ref_lib.R').to_s
    injection_order_file = @project.injection_identifier
    standard_file = @project.standard_identifier
    uploads = @project.uploads
    #mzxml_file = @upload.mzxmls_urls
    mzxml_files = []
    uploads.each do |u|
      u.mzxmls_identifiers.each do |i|
        mzxml_files_url = Rails.root.join('public','uploads','upload','mzxmls').to_s + "/#{u.id}" + "/#{i}"
        mzxml_files.push(mzxml_files_url)
      end
    end  
    mcq_win_size = @project.mcq_win_size
    mcq_threshold = @project.mcq_threshold
    intensity_threshold = @project.peak_int_threshold
    flatness_factor = @project.flat_fac
    std_blk_threshold = @project.std_blk
    rt_rsd_threshold = @project.rsd_rt
    metamope_projects = Rails.root.join('tmp', 'metomope', 'projects').to_s
    working_dir = metamope_projects + "/#{@project.id}"
    unless File.exist?(working_dir)
      FileUtils.mkdir_p(working_dir)
    end
    output = `Rscript --vanilla #{metamope_peak_evaluation} #{working_dir} #{injection_order_file} #{standard_file} #{mzxml_files} #{mcq_win_size} #{mcq_threshold} #{intensity_threshold} #{flatness_factor} #{std_blk_threshold} #{rt_rsd_threshold}`
    # 2>&1 > #{metamope_projects}/#{@project.id}/log.txt
    #outfile = working_dir + 'result.csv'
    outfile = working_dir + "/result/"
    #zipfile = working_dir + 'Result.zip'
    @project.output = output 
    if File.exists?(outfile)
	    zip_log = `zip -j #{outfile}`
    #@project.status = Project::FINISHED
    @project.state = "finished"
    @project.save!
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::FINISHED).deliver_now
    end 
  end
end
