# http://en.wikipedia.org/wiki/Plurality_voting_system

require 'Elections/VotingSystem'

module Elections
	class Plurality < VotingSystem

		def self.run(demographics)
			results = Hash.new
			results[:warnings] = self.perturbPreferences(demographics)
			results[:preferences] = self.preferences(demographics)
			results[:supporters] = self.supporters(results[:preferences])
			results[:votes] = self.votes(demographics, results[:supporters])
			results[:winners] = self.winners(results[:votes])
			return results
		end
		
		# Ensures no demographic equally ranks to candidates as best
		def self.perturbPreferences(demographics)
			demographics_to_perturb = demographics.select { |d, a| a[:preferences].group_by { |c,p| p }.sort.last[1].length > 1 }.keys
			demographics_to_perturb.each { |d| demographics[d][:preferences].each { |c, p| demographics[d][:preferences][c] = p + (rand-0.5)/10 } }
			return demographics_to_perturb unless demographics_to_perturb.empty?
		end
		
		# Returns the most preferred candidate of each demographic
		def self.preferences(demographics)
			demographics.inject({}) { |hash,d| hash.merge({d[0] => d[1][:preferences].max { |a,b| a[1] <=> b[1] }[0]}) }
		end

		# Returns the supporting demographics of each candidate
		def self.supporters(preferences)
			preferences.inject({}) { |hash, px| hash.merge({px[1] => preferences.collect { |py| py[0] if px[1] == py[1] }.compact}) }
		end
		
		# Returns the number of votes each candidate recieved
		def self.votes(demographics, supporters)
			Hash[*supporters.keys.zip(supporters.collect { |c, s| s.inject(0) { |votes,d| votes + demographics[d][:size] } }).flatten]
		end
		
		# Returns the candidates that got the most votes
		def self.winners(votes)
			top_score = votes.max { |a,b| a[1] <=> b[1] }[1]
			votes.reject { |candidate,votes| votes != top_score }.collect { |candidate,votes| candidate }
		end
	end
end
