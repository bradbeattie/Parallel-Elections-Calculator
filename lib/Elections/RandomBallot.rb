# http://en.wikipedia.org/wiki/Plurality_voting_system

require 'Elections/VotingSystem'

module Elections
	class RandomBallot < VotingSystem

		def self.run(demographics)
			results = Elections::Plurality.run(demographics)
			results[:winners] = [results[:votes].keys.weighted_random(results[:votes].values)]
			return results
		end
	end
end
