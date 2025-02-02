# frozen_string_literal: true

module JobDrafting
  class PublishJob < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :shift_duration, Infra::Types::TimeRange
    attribute :title, Infra::Types::NotEmpty::String
    attribute :description, Infra::Types::NotEmpty::String
    attribute :dress_code_requirements, Infra::Types::NotEmpty::String.optional
    attribute :wage_per_hour, Infra::Types::Money
    attribute :spots, Infra::Types::Spots
    attribute :work_location, Infra::Types::Address
  end

  class UnpublishJob < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
  end

  class SetSpotsOnJob < Infra::Command
    attribute :job_uuid, Infra::Types::UUID
    attribute :spots, Infra::Types::Spots
  end

  class SubmitSpotsChangeRequest < Infra::Command
    attribute :spots_change_request_uuid, Infra::Types::UUID
    attribute :job_uuid, Infra::Types::UUID
    attribute :current_spots, Infra::Types::Spots
    attribute :requested_spots, Infra::Types::Spots
  end

  class AcceptSpotsChangeRequest < Infra::Command
    attribute :spots_change_request_uuid, Infra::Types::UUID
  end

  class RejectSpotsChangeRequest < Infra::Command
    attribute :spots_change_request_uuid, Infra::Types::UUID
    attribute :minimum_required_spots, Infra::Types::Spots
  end
end
