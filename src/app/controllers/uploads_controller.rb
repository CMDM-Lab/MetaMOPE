class UploadsController < ApplicationController

    before_action :authenticate_user!

    def index
        @uploads = Upload.all
    end

    def new
        @upload = Upload.new
    end

    def start
        @project = Project.find(params[:id])
        session[:id] = params[:id]
        session[:access_key] = @project.access_key
    end

    def create
        @project = Project.find(session[:id])
        @upload = @project.uploads.create(upload_params)
        session[:project_id] = @project.id
        #@project.state = "upload"
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
        params.require(:upload).permit(:project_id, :mobile_phase, :mzxmls => [])
    end
end