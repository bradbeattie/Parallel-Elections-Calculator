require 'Elections/CondorcetMethod'

module Elections
	class RankedPairs < CondorcetMethod
		def self.run(demographics)

			# Is there any candidate preferred over all others?
			results = self.initializeCondorcetResults(demographics)
			return results unless results[:winners].empty?
					
			# Lock pairs
			require 'rgl/adjacency'
			lockedPairs = Array.new
			results[:locking] = Array.new
			results[:sortedStrongPairs].each do |v,p|
				if RGL::DirectedAdjacencyGraph[*(lockedPairs+p).flatten].cycles.length == 0 
					lockedPairs << p.collect { |c| c }
					p.each { |p| results[:locking] << [p[0], p[1], "Kept"] }
				else
					p.each { |p| results[:locking] << [p[0], p[1], "Discarded"] }
				end
			end
			
			# Determine the winners and return the results
			graph = RGL::DirectedAdjacencyGraph[*lockedPairs.flatten]
			results[:winners] = results[:candidates] - graph.edges.collect { |e| e.target  }.uniq
			return results
		end
	end
end
