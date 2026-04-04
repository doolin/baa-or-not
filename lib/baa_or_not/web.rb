# frozen_string_literal: true

require "sinatra/base"
require_relative "decision"

module BaaOrNot
  # Sinatra web application serving the BAA decision tool.
  # Presents a three-question flow to determine whether a
  # Business Associate Agreement is required under HIPAA.
  class Web < Sinatra::Base
    set :views, File.join(__dir__, "views")
    set :host_authorization, permitted: :any

    get %r{/(baa-or-not)?} do
      erb :index
    end

    post %r{/(baa-or-not/)?decide} do
      answers = {
        covered_entity: params["covered_entity"] == "yes",
        handles_phi: params["handles_phi"] == "yes",
        vendor_phi: params["vendor_phi"] == "yes",
      }
      @decision = Decision.new(answers)
      erb :result
    end
  end
end
