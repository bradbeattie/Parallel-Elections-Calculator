require 'test_helper'
require 'Elections/RankedPairs'

class RankedPairsTest < ActiveSupport::TestCase

	# Clear winner (1 candidate, 1 demographic)
	def test_clear_winner
		results = Elections::RankedPairs.run({
			"Demographic A" => {
				:size => 1,
				:preferences => { "Candidate X" => 100 }
			}
		})
		assert results[:winners] == ["Candidate X"]
	end

	# Majority winner (2 candidates, 1 demographic)
	def test_majority_winner
		results = Elections::RankedPairs.run({
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


	# Condorcet winner (3 candidates, 4 demograhpics)
	def test_condorcet_winner
		results = Elections::RankedPairs.run({
			"Demographic A" => {
				:size => 1,
				:preferences => {
					"Candidate X" => 100,
					"Candidate Y" => 100,
					"Candidate Z" => 50
				}
			},
			"Demographic B" => {
				:size => 1,
				:preferences => {
					"Candidate X" => 0,
					"Candidate Y" => 50,
					"Candidate Z" => 50
				}
			},
			"Demographic C" => {
				:size => 1,
				:preferences => {
					"Candidate X" => 0,
					"Candidate Y" => 50,
					"Candidate Z" => 100
				}
			},
			"Demographic D" => {
				:size => 1,
				:preferences => {
					"Candidate X" => 100,
					"Candidate Y" => 50,
					"Candidate Z" => 0
				}
			}
		})
		assert results[:winners] == ["Candidate Y"]
	end

	# Non-condorcet winner (3 candidates, 3 demograhpics)
	def test_condorcet_winner
		results = Elections::RankedPairs.run({
			"Demographic A" => {
				:size => 13,
				:preferences => {
					"Candidate X" => 100,
					"Candidate Y" => 50,
					"Candidate Z" => 0
				}
			},
			"Demographic B" => {
				:size => 12,
				:preferences => {
					"Candidate X" => 0,
					"Candidate Y" => 100,
					"Candidate Z" => 50
				}
			},
			"Demographic C" => {
				:size => 11,
				:preferences => {
					"Candidate X" => 50,
					"Candidate Y" => 0,
					"Candidate Z" => 100
				}
			}
		})
		assert results[:winners] == ["Candidate X"]
	end
end
