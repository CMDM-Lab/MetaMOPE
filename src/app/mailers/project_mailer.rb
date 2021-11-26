class ProjectMailer < ApplicationMailer

    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.project_mailer.notify_progress.subject
    #
    def notify_progress(user_id, project_id, status)
      @user = User.find(user_id)
      @project = Project.find(project_id)
      @comment = ''
      case status
      when 2
      @comment = 'Enqueue and wait'
      when 3
      @comment = 'Analyzing'
      when 4
      @comment = 'Finished'
      end
      mail(:from => 'Test@web.cmdm.tw', :to => @user.email, :subject => "Your project #{@project.name} status has changed to #{@comment}!")
    end
  end