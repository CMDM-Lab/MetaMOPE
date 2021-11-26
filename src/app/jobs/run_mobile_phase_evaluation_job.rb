class RunMobilePhaseEvaluationJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    @project = Project.find(project_id)
    #@project.status = Project::RUNNING
    @project.save
    ProjectMailer.notify_progress(@project.user.id, @project.id, Project::RUNNING).deliver_now
    metamope_mobile_phase_evaluation = '/lib/metamope/mobile_phase_evaluation.R'
    metomope_peak_evaluation = '/lib/metamope/build_ref_lib.R'
    #metomope_projects = ''
    #input grouping file
    #input standard file
    #input mzxml file
    mcq_win_size = @project.mcq_win_size
    mcq_threshold = @project.mcq_threshold
    intensity_threshold = @project.peak_int_threshold
    #out peak information file
    #out peak quality score file
    #out zipfile
    #output  = Rscript...
    #@project.output = output -haven't create output column in project model
    #check if all output file exist
    #@project.status
    #@project.save
    #send email
  end
end
