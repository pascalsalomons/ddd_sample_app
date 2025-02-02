# frozen_string_literal: true

module Administrating
  class Chip < Infra::ValueObject
    attr_reader :number, :registry, :registry_change_confirmed

    # rubocop: disable Style/OptionalBooleanParameter
    def initialize(number, registry, registry_change_confirmed = false)
      with_immutability do
        super
        @number = number
        @registry = registry
        @registry_change_confirmed = registry_change_confirmed

        raise ArgumentError, 'number cant be nil' if number.nil?
        raise ArgumentError, 'registry cant be nil' if registry.nil?
      end
    end
    # rubocop: enable Style/OptionalBooleanParameter

    def confirm_registry_change
      self.class.new(number, registry, true)
    end
  end
end
