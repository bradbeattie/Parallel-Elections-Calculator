require 'test_helper'
require 'Elections/RandomBallot'

class RandomBallotTest < ActiveSupport::TestCase

	# Clear winner (1 candidate, 1 demographic)
	def test_clear_winner
		results = Elections::RandomBallot.run({
			"Demographic A" => {
				:size => 1,
				:preferences => { "Candidate X" => 100 }
			}
		})
		assert results[:winners] == ["Candidate X"]
	end

	# Majority winner (2 candidates, 1 demographic)
	def test_majority_winner
		results = Elections::RandomBallot.run({
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


	# Contained winner (2 candidates, 2 demograhpics)
	def test_contained_winner
		results = Elections::RandomBallot.run({
			"Demographic A" => {
				:size => 20,
				:preferences => {
					"Candidate X" => 3,
					"Candidate Y" => 2,
				}
			},
			"Demographic B" => {
				:size => 15,
				:preferences => {
					"Candidate X" => 1,
					"Candidate Y" => 2,
				}
			}
		})
		assert (results[:winners] & ["Candidate X", "Candidate Y"]).length == 1
	end
end
