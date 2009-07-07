require 'Elections/PreferentialVotingSystem'

module Elections
	class CondorcetMethod < PreferentialVotingSystem
		
		def self.initializeCondorcetResults(demographics)
			results = Hash.new
			results[:preferences] = self.preferences(demographics)
			results[:candidates] = self.candidates(demographics)
			results[:pairs] = self.pairs(results[:preferences], demographics, results[:candidates])
			results[:strongPairs] = self.strongPairs(results[:pairs])
			results[:sortedStrongPairs] = results[:strongPairs].grouping_invert
			results[:winners] = self.condorcetWinner(results[:strongPairs], results[:candidates])
			return results
		end
		
		# Returns a tally of pairwise comparisons
		##
		## This function is walking through each demographic's order of preferences and adding to the pair function
		## "I prefer this candidate over this futher candidate." The end result is a tally of each pairwise comparison.
		##
		## I admit that this function isn't as clean as it could be. There's probably some smart way of using Ruby 1.9's
		## combination method ( http://www.ruby-doc.org/core-1.9/classes/Array.html#M000483 ) that just didn't occur. If
		## you're going to improve it, please be careful of ties (when two candidates aren't preferred over eachother,
		## nothing is added to the pairs).
		##
		def self.pairs(preferences, demographics, candidates)
			pairs = Hash[*candidates.combination(2).collect { |p1, p2| [[p1, p2], 0, [p2, p1], 0] }.flatten(1)]
			preferences.collect do |d,dp|
				dp.collect do |p1g|
					p1g.collect do |p1|
						(dp.index(p1g)+1..dp.length-1).collect do |p2g|
							dp[p2g].collect do |p2|
								pairs[[p1,p2]] += demographics[d][:size]
							end
						end
					end
				end
			end
			pairs
		end
		
		# Returns pairs that beat their inverse
		def self.strongPairs(pairs)
			pairs.select { |p,v| v > pairs[[p[1],p[0]]] } 
		end
				
		# Determine if there's a strict Condorcet winner
		def self.condorcetWinner(strongPairs, candidates)
			candidates.select { |c| strongPairs.count { |p| p[0][0] == c } == candidates.length-1 }.compact
		end
	end
end
