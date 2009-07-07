
require 'Elections/VotingSystem'

module Elections
	class RangeVoting < VotingSystem
		def self.run(demographics)
			results = Hash.new
			results[:preferences] = self.preferences(demographics)
			results[:candidates] = self.candidates(demographics)
			results[:sums] = self.sums(demographics, results[:candidates], results[:preferences])
			results[:winners] = self.winners(results[:sums])
			return results
		end
		
		def self.preferences(demographics)
			Hash[*demographics.collect { |d,a| [d,a[:preferences]] }.flatten(1)]
		end
		
		def self.sums(demographics, candidates, preferences)
			result = Hash.new
			candidates.each { |c| result[c] = demographics.keys.inject(0) { |sum,d| sum + preferences[d][c] * demographics[d][:size] } }
			return result
		end
		
		def self.winners(sums)
			sums.group_by { |c,s| s }.sort { |a,b| b <=> a }[0][1].collect { |c, s| c }
		end
	end
end
