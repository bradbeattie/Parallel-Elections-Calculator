require 'test_helper'
require 'Elections/RangeVoting'

class RangeVotingTest < ActiveSupport::TestCase

	# Clear winner (1 candidate, 1 demographic)
	def test_clear_winner
		results = Elections::RangeVoting.run({
			"Demographic A" => {
				:size => 1,
				:preferences => { "Candidate X" => 100 }
			}
		})
		assert results[:winners] == ["Candidate X"]
	end

	# Majority winner (2 candidates, 1 demographic)
	def test_majority_winner
		results = Elections::RangeVoting.run({
			"Demographic A" => {
				:size => 1,
				:preferences => {
					"Candidate X" => 2,
					"Candidate Y" => 1
				}
			}
		})
		assert results[:winners] == ["Candidate X"]
	end


	# Compromise winner (3 candidates, 2 demograhpics)
	def test_compromise_winner
		results = Elections::RangeVoting.run({
			"Demographic A" => {
				:size => 20,
				:preferences => {
					"Candidate X" => 100,
					"Candidate Y" => 0,
					"Candidate Z" => 60
				}
			},
			"Demographic B" => {
				:size => 15,
				:preferences => {
					"Candidate X" => 0,
					"Candidate Y" => 100,
					"Candidate Z" => 60
				}
			}
		})
		assert results[:winners] == ["Candidate Z"]
	end
end
