class RunMobilePhaseEvaluationJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    @project = Project.find(project_id)
    @upload = Upload.find_by(:project_id => @project.id)
    @project.state = "running"
    @project.save
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::RUNNING).deliver_now
    metamope_mobile_phase_evaluation = Rails.root.join('lib','metamope','mobile_phase_evaluation.R')
    grouping_file = @project.grouping
    standard_file = @project.standard
    uploads = @project.uploads
    mobile_phases = []
    uploads.each do |u|
      mobile_phses.push(u.mobile_phase)
    end
    mzxml_files = []
    uploads.each do |u|
      mzxml_files.push(u.mzxmls)
    end
    mcq_win_size = @project.mcq_win_size
    mcq_threshold = @project.mcq_threshold
    intensity_threshold = @project.peak_int_threshold
    metamope_projects = Rails.root.join('tmp', 'metamope', 'projects').to_s
    working_dir = metamope_projects + "/#{@project.id}"
    outfile1 = metamope_projects + "/#{@project.id}/" + 'PeakInformation.csv'
    outfile2 = metamope_projects + "/#{@project.id}/" + 'PeakQualityScore.csv'
    zipfile = metamope_projects + "/#{@project.id}/" + 'Result.zip'
    output = `Rscript --vanilla #{metamope_mobile_phase_evaluation} -p '[#{working_dir} #{grouping_file} #{standard_file} #{mobile_phases} #{mzxml_files} #{mcq_win_size} #{mcq_threshold} #{intensity_threshold} #{outfile1} #{outfile2}]' 2>&1 > #{metamope_projects}/#{@project.id}/log.txt` 
    @project.output = output 
    #check if all output file exist
    if File.exists?(outfile1) and File.exists?(outfile2)
	    zip_log = `zip -j #{zipfile} #{outfile1} #{outfile2}`
      #@project.status = Project::FINISHED
      @project.state = "finished"
      @project.save!
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::FINISHED).deliver_now
    end  
  end
end