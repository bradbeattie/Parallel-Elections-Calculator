# http://en.wikipedia.org/wiki/instant_runoff_voting

require 'Elections/PreferentialVotingSystem'
require 'Elections/SchulzeMethod'
require 'Elections/Plurality'

module Elections
	class InstantRunoff < PreferentialVotingSystem
	
		def self.run(demographics)
		
			results = Hash.new
			results[:candidates] = [self.candidates(demographics)]
			results[:warnings] = { :preferences => self.perturbPreferences(demographics), :ties => {} }
			results[:preferences] = self.preferences(demographics)
			results[:supporters] = Array.new
			results[:votes] = Array.new
			results[:eliminated] = Array.new

			# Perform each voting round until no candidates remain
			round = 0
			until results[:candidates][round].empty? do
				
				# Determine the votes for each candidate
				currentDemographics = self.restrictedDemographics(demographics, results[:candidates][round])
				currentPreferences = Elections::Plurality.preferences(currentDemographics)
				results[:supporters][round] = Elections::Plurality.supporters(currentPreferences)
				results[:votes][round] = Elections::Plurality.votes(currentDemographics, results[:supporters][round])
										
				# Determine who the least popular candidate is
				least_popular = [results[:votes][round].grouping_invert.min[1]]
				results[:warnings][:ties][round] = least_popular.last if least_popular.last.length > 1
				until least_popular.last.empty?
					least_popular << least_popular.last - Elections::SchulzeMethod.run(self.restrictedDemographics(currentDemographics, least_popular.last))[:winners]
				end
					
				# Eliminate the least popular candidate and move on to the next round
				results[:eliminated][round] = least_popular.slice(-2, 1)[0]
				results[:candidates][round+1] = results[:candidates][round] - results[:eliminated][round]
				round = round + 1
			end

			# Determine who got the most votes and return the results
			results[:winners] = results[:eliminated].pop
			return results
		end
		
		# Ensures no demographic equally ranks to candidates as best
		def self.perturbPreferences(demographics)
			demographics_to_perturb = demographics.select { |d, a| !a[:preferences].group_by { |c,p| p }.select { |v,p| p.length > 1 }.empty? }.keys
			demographics_to_perturb.each { |d| demographics[d][:preferences].each { |c, p| demographics[d][:preferences][c] = p + (rand-0.5)/10 } }
			return demographics_to_perturb unless demographics_to_perturb.empty?
		end
	end
end
