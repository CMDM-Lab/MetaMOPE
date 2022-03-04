class UploadsController < ApplicationController

    before_action :authenticate_user!

    def index
        @uploads = Upload.all
    end

    def new
        @upload = Upload.new
    end

    def start
        if params[:id].nil?
            flash[:alert] = 'Please create a project or select a project from Project list to run analyses  (a blue button under the project name)'
            redirect_to projects_path
            return
        else
            @project = Project.find(params[:id])
            session[:id] = params[:id]
            session[:access_key] = @project.access_key
        end
    end

    def create
        @project = Project.find(session[:id])
        @upload = @project.uploads.create(upload_params)
        session[:project_id] = @project.id
        @project.state = "upload"
        @project.save
        if @upload.save
            redirect_to run_project_path
        end
    end

    def destroy
        @upload.destroy
        redirect_to start_upload_path
    end

    private
    def upload_params
        params.require(:upload).permit(:project_id, :mobile_phase, {mzxmls: []})
    end
end