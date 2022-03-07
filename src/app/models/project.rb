class Project < ApplicationRecord

    belongs_to :user
	has_many :uploads

	mount_uploader :standard, StandardUploader
	mount_uploader :injection, InjectionUploader

	#has_one_attached :grouping
	#has_one_attached :injection
	#has_one_attached :standard

	#validates :grouping, blob:{content_type: ['text/csv']}
	#validates :injection, blob:{content_type: ['text/csv']}
	#validates :standard, blob:{content_type: ['text/csv']}

	accepts_nested_attributes_for :uploads,
		:allow_destroy => true,
		:reject_if => :all_blank

	#state_machine :initial => :new do
		
	#	event :upload do
	#		transition :new => :upload
	#	end
		
	#	event :do_run do
	#		transition :upload => :run_pending
	#	end 

	#	event :perform do
	#		transition :run_pending => :running
	#	end 

	#	state :finished do 
	#		validates_presence_of :output
	#	end
		
	#end
end
