require 'Elections/CondorcetMethod'

module Elections
	class SchulzeMethod < CondorcetMethod
		def self.run(demographics)
		
			# Is there any candidate preferred over all others?
			results = Elections::SchulzeMethod.initializeCondorcetResults(demographics)
			return results unless results[:winners].empty?
			
			# Build the graph
			require 'rgl/adjacency'
			graph = RGL::DirectedAdjacencyGraph[*results[:sortedStrongPairs].values.collect { |c| c[0] }.flatten]
			results[:candidates].each { |c| graph.add_vertex(c) }
			edge_weights = deep_copy(results[:sortedStrongPairs].values)
			
			# Loop until we're out of edges
			results[:removed] = Array.new
			until graph.edges.empty?
				
				# Remove vertices with only outgoing edges until there aren't any
				vertices_count = 0
				while graph.vertices.length != vertices_count
					vertices_count = graph.vertices.length
					graph.vertices.each do |v|
						if (graph.edges.select { |e| e if e.source == v }.length == 0) && (graph.edges.select { |e| e if e.target == v }.length > 0)
							results[:removed] << v
							graph.remove_vertex(v)
						end
					end
				end
				
				# Eliminate the weakest edge(s)
				unless graph.edges.empty?
					weakest_edges = edge_weights.pop
					weakest_edges.each do |e|
						results[:removed] << e
						graph.remove_edge(e.keys[0], e.keys[1])
					end
				end
			end
			
			# Detemine the winners and return the results
			results[:winners] = graph.vertices
			return results
		end
	end
end
