require 'test_helper'
require 'Elections/SchulzeMethod'

class SchulzeMethodTest < ActiveSupport::TestCase

	# Clear winner (1 candidate, 1 demographic)
	def test_clear_winner
		results = Elections::SchulzeMethod.run({
			"Demographic A" => {
				:size => 1,
				:preferences => { "Candidate X" => 100 }
			}
		})
		assert results[:winners] == ["Candidate X"]
	end

	# Majority winner (2 candidates, 1 demographic)
	def test_majority_winner
		results = Elections::SchulzeMethod.run({
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
	
		
	# Disagree with Ranked Pairs
	def test_disagree_with_ranked_pairs
		results = Elections::SchulzeMethod.run({
			"Demographic V" => {
				:size => 16,
				:preferences => {
					"Candidate A" => 40,
					"Candidate B" => 50,
					"Candidate C" => 10,
					"Candidate D" => 20,
					"Candidate E" => 30
				}
			},
			"Demographic W" => {
				:size => 27,
				:preferences => {
					"Candidate A" => 30,
					"Candidate B" => 40,
					"Candidate C" => 50,
					"Candidate D" => 10,
					"Candidate E" => 20
				}
			},
			"Demographic X" => {
				:size => 17,
				:preferences => {
					"Candidate A" => 30,
					"Candidate B" => 10,
					"Candidate C" => 50,
					"Candidate D" => 20,
					"Candidate E" => 40
				}
			},
			"Demographic Y" => {
				:size => 31,
				:preferences => {
					"Candidate A" => 40,
					"Candidate B" => 30,
					"Candidate C" => 20,
					"Candidate D" => 50,
					"Candidate E" => 10
				}
			},
			"Demographic Z" => {
				:size => 9,
				:preferences => {
					"Candidate A" => 10,
					"Candidate B" => 30,
					"Candidate C" => 20,
					"Candidate D" => 40,
					"Candidate E" => 50
				}
			}
		})
		assert results[:winners] == ["Candidate A"]
	end
end
