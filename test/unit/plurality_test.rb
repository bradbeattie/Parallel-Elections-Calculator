require 'test_helper'
require 'Elections/Plurality'

class PluralityTest < ActiveSupport::TestCase

	# Clear winner (1 candidate, 1 demographic)
	def test_clear_winner
		results = Elections::Plurality.run({
			"Demographic A" => {
				:size => 1,
				:preferences => { "Candidate X" => 100 }
			}
		})
		assert results[:winners] == ["Candidate X"]
	end

	# Preference truncation (2 candidates, 1 demographic)
	def test_preference_truncation
		results = Elections::Plurality.run({
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

	# Majority winner (2 candidates, 2 demographics)
	def test_majority_winner
		results = Elections::Plurality.run({
			"Demographic A" => {
				:size => 2,
				:preferences => {
					"Candidate X" => 2,
					"Candidate Y" => 1
				}
			},
			"Demographic B" => {
				:size => 1,
				:preferences => {
					"Candidate X" => 1,
					"Candidate Y" => 2
				}
			}
		})
		assert results[:winners] == ["Candidate X"]
	end


	# Minority winner (3 candidates, 3 demograhpics)
	def test_minority_winner
		results = Elections::Plurality.run({
			"Demographic A" => {
				:size => 20,
				:preferences => {
					"Candidate X" => 3,
					"Candidate Y" => 2,
					"Candidate Z" => 1
				}
			},
			"Demographic B" => {
				:size => 15,
				:preferences => {
					"Candidate X" => 1,
					"Candidate Y" => 2,
					"Candidate Z" => 3
				}
			},
			"Demographic C" => {
				:size => 15,
				:preferences => {
					"Candidate X" => 1,
					"Candidate Y" => 3,
					"Candidate Z" => 2
				}
			}
		})
		assert results[:winners] == ["Candidate X"]
	end
end
