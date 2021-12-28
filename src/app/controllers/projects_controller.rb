class ProjectsController < ApplicationController

    before_action :authenticate_user!
    
    def index
        @projects = current_user.projects
    end

    def show
        @project = Project.find(params[:id])
    end

    def new
        @project = Project.new
    end
    
    def create
        @project = Project.new(project_params)
        @project.user_id = current_user.id
        @project.access_key = [*('a'..'z'),*('0'..'9')].shuffle[0,12].join
        @project.state = "new"
        if @project.save
            session[:id] = @project.id
            session[:access_key] = @project.access_key
            flash[:notice] = "Your project has been created."
            redirect_to projects_path
        else
			flash[:alert] = "Something went wrong."
			render :new
        end
    end

    def upload
        if params[:id].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to upload your data (a blue button under the project name)'
  	        redirect_to projects_path
  		return
        else
            @project = Project.find(params[:id])
            if @project.user_id == current_user.id
                #@project.status = Project::UPLOAD
                session[:access_key] = @project.access_key
                @project.save 
            else    
                flash[:alert] = "You have no permission to upload files to this project."
                redirect_to root_path  
            end
        end       
    end

    def run
        if params[:id].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to run analyses  (a blue button under the project name)'
            redirect_to projects_path 
        return
        else
            @project = Project.find(params[:id])
            if @project.user_id == current_user.id
                @uploads = @project.uploads
                return @project
            else
				flash[:alert] = 'You have no permission to access this project'
				redirect_to projects_path
			end        
        end       
    end

    def do_run
        @project = Project.find(params[:id])
        @upload = Upload.find_by(:project_id => @project.id)
        #@project.status = Project::RUN_PENDING
        @project.state = "run_pending"
		@project.save
        if @project.mobile_phase_evaluation & @project.peak_evaluation
            RunMobilePhaseEvaluationJob.perform_now(@project.id, @upload.id)
            RunPeakEvaluationJob.perform_now(@project.id, @upload.id)
        end
        if @project.mobile_phase_evaluation & !@project.peak_evaluation
            RunMobilePhaseEvaluationJob.perform_now(@project.id, @upload.id)
        end
        if @project.peak_evaluation & !@project.mobile_phase_evaluation
            RunPeakEvaluationJob.perform_now(@project.id, @upload.id)
        end

        #if success
		flash[:notice] = "Your project #{@project.name} has been enqueued. "
		#ProjectMailer.notify_progress(@project.user.id, @project.id, Project::RUN_PENDING).deliver_now
		redirect_to projects_path

	end

    def retrieve
		if params[:access_key].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to retrieve results  (a green button under the project name)'
            redirect_to projects_path
            return
        else
			@project = Project.find_by(:access_key => params[:access_key])
            return @project
        end
	end

    def retrieve_dl
        if params[:access_key].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to retrieve results  (a green button under the project name)'
            redirect_to projects_path
            return
        else
            access = params[:access_key]
            @project = Project.where(:access_key => params[:access_key])
            project_id = @project.id
            #send_file{"tmp/metamope/projects/#{project_id}/Result.zip", filename: access, type: "applcation/zip"}
        end
    end

    private
    def project_params
        params.require(:project).permit(:access_key, :name, :mobile_phase_evaluation, :peak_evaluation, :state, :upload,
                                        :mcq_win_size, :flat_fac, :mcq_threshold, :peak_int_threshold, 
                                        :std_blk, :rsd_rt, :output)
    end

end