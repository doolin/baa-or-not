# frozen_string_literal: true

module BaaOrNot
  # Evaluates whether a BAA is required based on three
  # sequential questions from the HIPAA decision flow.
  class Decision
    QUESTIONS = [
      {
        key: :covered_entity,
        text: "Are you a HIPAA Covered Entity or Business Associate?",
      },
      {
        key: :handles_phi,
        text: "Does the app create, receive, maintain, or transmit PHI?",
      },
      {
        key: :vendor_phi,
        text: "Do third-party vendors process, store, or transmit that PHI for you?",
      },
    ].freeze

    attr_reader :answers

    def initialize(answers = {})
      @answers = answers
    end

    def required?
      answers.values_at(:covered_entity, :handles_phi, :vendor_phi).all?
    end

    def determination
      return "BAA likely required" if required?

      "BAA may not be required"
    end
  end
end
