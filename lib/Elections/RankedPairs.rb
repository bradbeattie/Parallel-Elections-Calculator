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
			results[:warnings] = Array.new
			results[:sortedStrongPairs].each do |v,pairs|
			
				# Sort out which pairs cause cycles
				cyclic_pairs = pairs.select { |p| RGL::DirectedAdjacencyGraph[*(lockedPairs+p).flatten].cycles.length > 0 }
				pairs -= cyclic_pairs

				# If we have to randomly select, throw up a warning
				while RGL::DirectedAdjacencyGraph[*(lockedPairs+pairs).flatten].cycles.length > 0
					p = pairs.sample
					pairs.delete(p)
					cyclic_pairs << p
					results[:warnings] << p
				end
								
				# Keep the acyclic pairs, discard the cylic ones
				pairs.each { |p| results[:locking] << [p[0], p[1], "Kept"]; lockedPairs << p }
				cyclic_pairs.each { |p| results[:locking] << [p[0], p[1], "Discarded"] }
			end
						
			# Determine the winners and return the results
			graph = RGL::DirectedAdjacencyGraph[*lockedPairs.flatten]
			results[:winners] = results[:candidates] - graph.edges.collect { |e| e.target  }.uniq
			return results
		end
	end
end
