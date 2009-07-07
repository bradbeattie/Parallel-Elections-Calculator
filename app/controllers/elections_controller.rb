require 'Elections/Plurality'
require 'Elections/InstantRunoff'
require 'Elections/SchulzeMethod'
require 'Elections/RankedPairs'
require 'Elections/RangeVoting'

class ElectionsController < ApplicationController

	skip_before_filter :verify_authenticity_token
	include LanguageHelper
	
	def index
	end
	
	def results

		# Defining the available voting systems and their attributes
		defaults = {
			Elections::Plurality => true,
			Elections::InstantRunoff => true,
			Elections::SchulzeMethod => true,
			Elections::RankedPairs => true,
			Elections::RangeVoting => true
		}
		
		# Determine which voting systems we'll be using
		@systems ||= defaults.keys if params[:systems] == ["all"]
		@systems ||= defaults.select { |system,default| default }.keys if params[:systems].nil?
		@systems ||= defaults.select { |system,default| params[:systems].include?(system.name.underscore) }

		# Process the demographics, their sizes and their preferences
		candidates = params[:candidates]
		@demographics = Hash.new
		params[:demographics].zip(params[:demographic_sizes], params[:preferences].values).each do |array|
			@demographics[array[0]] = {
				:size => array[1].to_i,
				:preferences => Hash[*candidates.zip(array[2].collect { |p| p.to_i }).flatten]
			}
		end

		# Call each voting system in turn
		@results = Hash.new
		@systems.each do |system|
			begin
				@results[system] = system.run(deep_copy(@demographics))
			#rescue Exception => e
			end
		end
	end
end
