# frozen_string_literal: true

require 'test_helper'

module JobFulfillment
  class AcceptApplicationTest < Infra::DomainTestHelper
    def setup
      @uuid = SecureRandom.uuid
      @application_uuid = SecureRandom.uuid
      @stream = "JobFulfillment::Job$#{@uuid}"

      arrange_setup_for_test
    end

    test 'an application gets accepted' do
      arrange_candidate_applied
      expected_events = [application_accepted_event]
      published = act(@stream, accept_application_command)

      assert_changes(published, expected_events)
    end

    test 'no event gets published when a candidate is already accepted' do
      arrange_candidate_applied
      arrange(@stream, [application_accepted_event])
      published = act(@stream, accept_application_command)
      assert_no_changes(published)
    end

    test 'it raises when an application is not found' do
      assert_raises(Job::ApplicationNotFound) do
        act(@stream, accept_application_command)
      end
    end

    test 'it cannot apply if the application is not pending' do
      arrange_candidate_rejected
      assert_raises(Job::ApplicationNotPending) do
        act(@stream, accept_application_command)
      end
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_accept_application_command
      end
    end

    private

    def application_accepted_event
      ApplicationAccepted.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid
        }
      )
    end

    def arrange_candidate_applied
      candidate_applied_event = CandidateApplied.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid,
          candidate_uuid: SecureRandom.uuid,
          motivation: @motivation
        }
      )
      arrange(@stream, [candidate_applied_event])
    end

    def arrange_candidate_rejected
      arrange_candidate_applied
      candidate_rejected_event = ApplicationRejected.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid
        }
      )
      arrange(@stream, [candidate_rejected_event])
    end

    def arrange_setup_for_test
      job_created_event = JobCreated.new(
        data: {
          job_uuid: @uuid,
          starts_on: Time.zone.now.tomorrow,
          ends_on: Time.zone.now.tomorrow + 1.day,
          spots: 1
        }
      )
      arrange(@stream, [job_created_event])
    end

    def accept_application_command
      AcceptApplication.new(
        job_uuid: @uuid,
        application_uuid: @application_uuid
      )
    end

    def invalid_accept_application_command
      AcceptApplication.new(job_uuid: @uuid)
    end
  end
end
