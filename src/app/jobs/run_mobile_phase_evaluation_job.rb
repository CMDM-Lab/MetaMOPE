class RunMobilePhaseEvaluationJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    @project = Project.find(project_id)
    @project.state = "running"
    @project.save
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::RUNNING).deliver_now
    metamope_mobile_phase_evaluation = Rails.root.join('lib','metamope','mobile_phase_evaluation.R').to_s
    standard_file = @project.standard_identifier
    standard_file_url = Rails.root.join('public','uploads','project','standard').to_s + "/#{@project.id}" + "/#{@project.standard_identifier}"
    uploads = @project.uploads
    mobile_phases = []
    uploads.each do |u|
      mobile_phases.push(u.mobile_phase)
    end
    mzxml_files_phases = []
    uploads.each do |u|
      mzxml_files_urls = []
      u.mzxmls_identifiers.each do |i|
        mzxml_file_url = Rails.root.join('public','uploads','upload','mzxmls').to_s + "/#{u.id}" + "/#{i}"
        mzxml_files_urls.push(mzxml_file_url)
      end
      mzxml_files_phases.push(mzxml_files_urls)
    end
    mcq_win_size = @project.mcq_win_size
    mcq_threshold = @project.mcq_threshold
    intensity_threshold = @project.peak_int_threshold
    metamope_projects = Rails.root.join('tmp', 'metamope', 'projects').to_s
    working_dir = metamope_projects + "/#{@project.id}"
    unless File.exist?(working_dir)
      FileUtils.mkdir_p(working_dir)
    end
    output = `Rscript --vanilla #{metamope_mobile_phase_evaluation} #{working_dir} #{standard_file_url} #{mobile_phases} #{mzxml_files_phases} #{mcq_win_size} #{mcq_threshold} #{intensity_threshold}`
    #2>&1 > #{metamope_projects}/#{@project.id}/log.txt
    #peak_information_file = working_dir + '/peak_information/' + 'PeakInformation.csv'
    peak_information_file = working_dir + '/peak_information'
    #peak_quality_score_table = working_dir + '/peak_information/' + 'PeakQualityScore.csv'
    peak_quality_score_table = working_dir + '/peak_quality_score/' + 'peak_quality_score_table.csv'
    #zipfile = working_dir + 'Result.zip'
    @project.output = output 
    #check if all output file exist
    if File.exists?(peak_information_file) and File.exists?(peak_quality_score_table)
	    zip_log = `zip -j #{peak_information_file} #{peak_quality_score_table}`
      #@project.status = Project::FINISHED
      @project.state = "finished"
      @project.save!
    #ProjectMailer.notify_progress(@project.user.id, @project.id, Project::FINISHED).deliver_now
    end  
  end
end