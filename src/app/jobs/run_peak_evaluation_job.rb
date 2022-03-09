class RunPeakEvaluationJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    @project = Project.find(project_id)
    @project.state = "running"
    @project.save
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::RUNNING).deliver_now
    metamope_peak_evaluation = Rails.root.join('lib', 'metamope','build_ref_lib.R').to_s
    injection_order_file = @project.injection_identifier
    injection_order_file_url = Rails.root.join('public','uploads','project','injection').to_s + "/#{@project.id}" + "/#{@project.injection_identifier}"
    standard_file = @project.standard_identifier
    standard_file_url = Rails.root.join('public','uploads','project','standard').to_s + "/#{@project.id}" + "/#{@project.standard_identifier}"
    @upload = @project.uploads
    mzxml_files_url = Rails.root.join('public','uploads','upload','mzxmls').to_s + "/#{@upload.first.id}/"
    mcq_win_size = @project.mcq_win_size
    mcq_threshold = @project.mcq_threshold
    intensity_threshold = @project.peak_int_threshold
    flatness_factor = @project.flat_fac
    std_blk_threshold = @project.std_blk
    rt_rsd_threshold = @project.rsd_rt
    metamope_projects = Rails.root.join('tmp', 'metamope', 'projects').to_s
    working_dir = metamope_projects + "/#{@project.id}"
    unless File.exist?(working_dir)
      FileUtils.mkdir_p(working_dir)
    end
    output = `Rscript --vanilla #{metamope_peak_evaluation} #{working_dir} #{injection_order_file_url} #{standard_file_url} #{mzxml_files_url} #{mcq_win_size} #{mcq_threshold} #{intensity_threshold} #{flatness_factor} #{std_blk_threshold} #{rt_rsd_threshold} 2>&1 > #{metamope_projects}/#{@project.id}/log.txt`
    #outfile = working_dir + 'result.csv'
    outfile_dir = working_dir + "/result/"
    unless File.exist?(outfile_dir)
      FileUtils.mkdir_p(outfile_dir)
    end
    outfile = outfile_dir + "ref_lib_all_results.csv"
    zipfile = outfile_dir + 'Result.zip'
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
