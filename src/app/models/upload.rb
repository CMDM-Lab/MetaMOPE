class Upload < ApplicationRecord
    belongs_to :project
    #has_many_attached :mzxmls
    mount_uploaders :mzxmls, MzxmlsUploader

    #validates :mzxmls, blob: {content_type: ['application/xml']}
end