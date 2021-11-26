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
        #@project.status = Project::New
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

    def retrieve
		if params[:access_key].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to retrieve results  (a green button under the project name)'
            redirect_to projects_path
            return
        else
			@project = Project.where(:access_key => params[:access_key])
            return @project
        end
	end

    private
    def project_params
        params.require(:project).permit(:access_key, :name, :mobile_phase_evaluation, :peak_evaluation, :upload,
                                        :mcq_win_size, :sample_repeat, :flat_fac, :mcq_threshold, :peak_int_threshold, 
                                        :std_blk, :rsd_rt, :jagedness, :assy_fac, :fwhm, :modality )
    end

end