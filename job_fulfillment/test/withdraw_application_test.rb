# frozen_string_literal: true

require 'test_helper'

module JobFulfillment
  class WithdrawApplicationTest < Infra::DomainTestHelper
    def setup
      @uuid = SecureRandom.uuid
      @application_uuid = SecureRandom.uuid
      @stream = "JobFulfillment::Job$#{@uuid}"
      @candidate_uuid = SecureRandom.uuid

      arrange_setup_for_test
    end

    test 'an application gets withdrawn' do
      arrange_candidate_applied
      expected_events = [application_withdrawn_event]
      published = act(@stream, withdraw_application_command)

      assert_changes(published, expected_events)
    end

    test 'no event gets published when a candidate is already withdrawn' do
      arrange_candidate_applied
      arrange(@stream, [application_withdrawn_event])
      published = act(@stream, withdraw_application_command)
      assert_no_changes(published)
    end

    test 'it raises when an application is not found' do
      assert_raises(Job::ApplicationNotFound) do
        act(@stream, withdraw_application_command)
      end
    end

    test 'it raises when the application is not pending' do
      arrange_candidate_accepted
      assert_raises(Job::ApplicationNotPending) do
        act(@stream, withdraw_application_command)
      end
    end

    test 'it validates the input of the command' do
      assert_raises(Infra::Command::Invalid) do
        invalid_withdraw_application_command
      end
    end

    private

    def application_withdrawn_event
      ApplicationWithdrawn.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid,
          candidate_uuid: @candidate_uuid
        }
      )
    end

    def arrange_candidate_applied
      candidate_applied_event = CandidateApplied.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid,
          candidate_uuid: @candidate_uuid,
          motivation: @motivation
        }
      )
      arrange(@stream, [candidate_applied_event])
    end

    def arrange_candidate_accepted
      arrange_candidate_applied

      application_accepted_event = ApplicationAccepted.new(
        data:
        {
          job_uuid: @uuid,
          application_uuid: @application_uuid
        }
      )
      arrange(@stream, [application_accepted_event])
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

    def withdraw_application_command
      WithdrawApplication.new(
        job_uuid: @uuid,
        application_uuid: @application_uuid,
        candidate_uuid: @candidate_uuid
      )
    end

    def invalid_withdraw_application_command
      WithdrawApplication.new(job_uuid: @uuid)
    end
  end
end
