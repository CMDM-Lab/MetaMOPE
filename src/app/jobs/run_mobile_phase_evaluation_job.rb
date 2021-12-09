class RunMobilePhaseEvaluationJob < ApplicationJob
  queue_as :default

  def perform(project_id, upload_id)
    @project = Project.find(project_id)
    #@project.status = Project::RUNNING
    @project.state = "running"
    @project.save
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::RUNNING).deliver_now
    metamope_mobile_phase_evaluation = Rails.root.join('lib', 'metamope','mobile_phase_evaluation.R')
    grouping_file = @upload.files.all.first
    standard_file = @upload.files.all.second
    mzxml_file = @upload.files.all.last
    mcq_win_size = @project.mcq_win_size
    mcq_threshold = @project.mcq_threshold
    intensity_threshold = @project.peak_int_threshold
    metamope_projects = Rails.root.join('tmp', 'metomope', 'projects')
    outfile1 = metamope_projects + "/#{@project.id}/" + 'PeakInformation.csv'
    outfile1 = metamope_projects + "/#{@project.id}/" + 'PeakQualityScore.csv'
    zipfile = metamope_projects + "/#{@project.id}/" + 'Result.zip'
    output = `Rscript --vanilla #{metamope_mobile_phase_evaluation} < #{grouping_file} #{standard_file} #{mzxml_file} > #{outfile1} #{outfile2} [#{maq_win_size} #{mcq_threshold} #{intensity_threshold}]`
    @project.output = output 
    #check if all output file exist
    if File.exists?(outfile_1) and File.exists?(outfile_2)
	    zip_log = `zip -j #{zipfile} #{outfile_1} #{outfile_2}`
      #@project.status = Project::FINISHED
      @project.state = "finished"
      @project.save!
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::FINISHED).deliver_now
    end  
  end
end
