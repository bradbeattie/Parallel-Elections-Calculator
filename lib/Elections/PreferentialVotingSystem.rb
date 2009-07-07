require 'Elections/VotingSystem'

module Elections
	class PreferentialVotingSystem < VotingSystem

		# Determine the preferences for each candidate
		def self.preferences(demographics)
			Hash[*demographics.collect { |d,a| [d, a[:preferences].group_by { |p| p[1] }.sort.reverse.collect { |p| p[1].collect { |q| q[0] } } ] }.flatten(1)]
		end		
	end
end
