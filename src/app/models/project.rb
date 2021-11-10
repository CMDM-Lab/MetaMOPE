class Project < ApplicationRecord
    Project::NEW = 0
	Project::UPLOAD = 1
	Project::RUN_PENDING = 2
	Project::RUNNING = 3
	Project::FINISHED = 4

    belongs_to :user


end
