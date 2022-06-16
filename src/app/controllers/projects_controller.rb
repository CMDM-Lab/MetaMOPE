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
            redirect_to project_update_path(session[:id])
        else
			flash[:alert] = "Something went wrong."
			render :new
        end
    end

    def upload
        if params[:id].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to upload your data'
  	        redirect_to projects_path
  		return
        else
            @project = Project.find(params[:id])
            if @project.user_id == current_user.id
                @project.status = "upload"
                session[:id] = @project.id
                session[:access_key] = @project.access_key
                @project.save 
                redirect_to run_project_path(session[:id])
            else    
                flash[:alert] = "You have no permission to upload files to this project."
                redirect_to root_path  
            end
        end       
    end

    def edit
        if params[:id].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to run analysis'
            redirect_to projects_path
            return
        else 
            @project = Project.find(params[:id])
            return @project
        end
    end

    def update
        if params[:id].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to run analysis'
            redirect_to projects_path
            return
        else 
            @project = Project.find(params[:id])
            @project.update(project_params)
            if @project.is_example
                @project.mcq_win_size = 3.0
                @project.mcq_threshold = 0.9
                if @project.mobile_phase_evaluation
                    @project.peak_int_threshold = 5000.0
                elsif @project.peak_evaluation
                    @project.peak_int_threshold = 1000.0
                    @project.std_blk = 6.0
                    @project.rsd_rt = 15.0
                end
            end
            @project.save
            flash[:notice] = "Project has been updated."
            session[:id] = @project.id
            redirect_to start_upload_path(session[:id])
        end  
    end

    def run
        if params[:id].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to run analysis'
            redirect_to projects_path 
            return
        else
            @project = Project.find(params[:id])
            session[:id] = @project.id
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
		@project.save
        if @project.mobile_phase_evaluation & !@project.peak_evaluation
            RunMobilePhaseEvaluationJob.perform_now(@project.id)
        elsif @project.peak_evaluation & !@project.mobile_phase_evaluation
            RunPeakEvaluationJob.perform_now(@project.id)
        end

        #if success
		flash[:notice] = "Your project #{@project.name} has been enqueued. "
        session[:access_key] = @project.access_key
		redirect_to retrieve_project_path(session[:access_key])
	end

    def retrieve
		if params[:access_key].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to retrieve results'
            redirect_to projects_path
            return
        else
			@project = Project.find_by(:access_key => params[:access_key])
            session[:access_key] = @project.access_key
            return @project
        end
	end

    def retrieve_dl
        if params[:access_key].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to retrieve results'
            redirect_to projects_path
            return
        else
            access = params[:access_key]
            @project = Project.find_by(:access_key => params[:access_key])
            project_id = @project.id
            send_file("#{Rails.root}/tmp/metamope/projects/#{project_id}/result/Result.zip", filename: access+"_Result.zip", type: "applcation/zip")
        end
    end

    def send_demo
        @project = Project.find(params[:id])
        if @project.mobile_phase_evaluation
            send_file("#{Rails.root}/app/assets/images/demo_mp.zip")
        elsif @project.peak_evaluation
            send_file("#{Rails.root}/app/assets/images/demo_ref_lib.zip")
        end
    end

    private
    def project_params
        params.require(:project).permit(:access_key, :name, :mobile_phase_evaluation, :peak_evaluation, :state, :upload,
                                        :injection, :standard, :is_example,
                                        :mcq_win_size, :flat_fac, :mcq_threshold, :peak_int_threshold, 
                                        :std_blk, :rsd_rt, :output, :uploads_attributes => [:id, :mobile_phase, :_destroy, mzxmls: []])
    end

end