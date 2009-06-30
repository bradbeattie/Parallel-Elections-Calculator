class ElectionsController < ApplicationController

	skip_before_filter :verify_authenticity_token
	include LanguageHelper
	
	
	def index
	end
	
	def results
	
		# A really weird thing I ran into in my development setup
		raise "WTF?" if params[:preferences][params[:preferences].keys.last].last == "Pr"
	
		# Process the incoming parameters
		@candidates = params[:candidates]
		@demographics = params[:demographics]
		@demographic_sizes = Hash[*@demographics.zip(params[:demographic_sizes].collect{|i| [i.to_i, 1].max}).flatten]
		@preferences = Hash.new ## TODO: Should be able to do this with flatten(1)
		@demographics.zip(params[:preferences].values).each{|i,j| @preferences[i] = j.collect{|k| k.to_i}}
		@preferences.each{|demographic, values| @preferences[demographic] = Hash[*@candidates.zip(values).flatten]}

		# Tweak the preferences so that we don't have any ties within demographics
		@preferences.each do |d,p|
			while p.values.uniq.length != p.values.length
				@preference_warning = d;
				p.each { |c,v| p[c] = v + (rand-0.5)/10 }
			end
			@preferences[d] = p
		end
		
		# Call each voting system in turn
		@results = Hash.new
		systems = params[:systems]
		systems = ["plurality", "instant_runoff", "ranked_pairs", "schulze_method", "range_voting"] if systems == ["all"]
		systems ||= ["plurality", "instant_runoff", "schulze_method"]
		systems.each do |s|
			begin
				@results[s] = send(s, deep_copy(@candidates), deep_copy(@demographics), deep_copy(@demographic_sizes), deep_copy(@preferences))
			rescue Exception => e
			end
		end
	end
	
	
	private
	
	
	# http://en.wikipedia.org/wiki/Plurality_voting_system
	def plurality(candidates, demographics, demographic_sizes, preferences)

		# Initialize the display globals
		results = Hash.new
		results[:preferences] = Hash.new
		results[:supporters] = Hash.new
		results[:votes] = Hash.new
		
		# Determine the most preferred candidate of each demographic
		preferences.each { |d,c| results[:preferences][d] = c.max { |c1,c2| c1[1] <=> c2[1] }[0] }
		
		# Determine the supporting demographics of each candidate
		candidates.each { |c| results[:supporters][c] = [] }
		results[:preferences].each { |d,c| results[:supporters][c] << d }

		# Determine the votes for each candidate
        candidates.each { |c| results[:votes][c] = 0 }
		results[:preferences].each { |d,c| results[:votes][c] += demographic_sizes[d] }
		
		# Determine who got the most votes
		top_score = results[:votes].max { |a,b| a[1] <=> b[1] }[1]
		results[:winners] = results[:votes].reject { |a,b| b != top_score }.collect {|a,b| a}
		return results
	end
	
	
	# http://en.wikipedia.org/wiki/Instant-runoff_voting
	def instant_runoff(candidates, demographics, demographic_sizes, preferences)

		# Initialize the display globals
		results = Hash.new
		results[:preferences] = Array.new
		results[:supporters] = Array.new
		results[:votes] = Array.new
		results[:eliminated] = Array.new
		results[:ties] = Array.new

		# Perform each voting round until no candidates remain
		round = 0
		until candidates.empty? do
			
			# Initialize the first round of voting
			results[:preferences][round] = Hash.new
			results[:supporters][round] = Hash.new
			results[:votes][round] = Hash.new
			results[:ties][round] = Array.new
						
			# Determine the votes for each candidate
			demographics.each { |d| results[:preferences][round][d] = preferences[d].sort { |p1,p2| p2[1] <=> p1[1] }.collect {|c,v| c}} if round == 0
			demographics.each { |d| results[:preferences][round][d] = results[:preferences][round-1][d].collect { |c| c if candidates.include?(c) }.compact} if round > 0
			candidates.each { |c| results[:supporters][round][c] = results[:preferences][round].collect { |d,p| d if p[0] == c }.compact }
			results[:supporters][round] = results[:supporters][round].delete_if {|c, d| d.empty? }
			candidates = results[:supporters][round].keys
			candidates.each { |c| results[:votes][round][c] = results[:supporters][round][c].inject(0) { |votes,d| votes + demographic_sizes[d] }}
									
			# Determine who the least popular candidate is
			results[:eliminated][round] = results[:votes][round].collect { |c,v| [c,v] if v > 0 }.compact.sort { |v1,v2| v1[1] <=> v2[1] }.slice(0)[0]
			fewest_votes = results[:votes][round].sort { |c1,c2| c1[1] <=> c2[1] }[0][1]
			least_popular = results[:votes][round].collect { |c| c[0] if c[1] == fewest_votes }.compact
			
			# Sometimes candidates tie for least popular
			until least_popular.empty?
				results[:ties][round] << ranked_pairs(least_popular, demographics, demographic_sizes, preferences)[:winners]
				eliminated = least_popular
				least_popular = least_popular - results[:ties][round].last
			end
			results[:ties][round] = Array.new if results[:ties][round].length == 1
			results[:ties][round] = results[:ties][round].flatten
				
			# Eliminate the least popular candidate
			results[:eliminated][round] = eliminated
			candidates = candidates - eliminated

			# Move on to the next round
			round = round + 1
		end

		# Determine who got the most votes
		results[:rounds] = round - 2
		results[:winners] = results[:eliminated].pop
		return results
	end
	
	
	# http://en.wikipedia.org/wiki/Ranked_Pairs
	def ranked_pairs(candidates, demographics, demographic_sizes, preferences)

		# Order the pairwise compairsons
		results = order_pairwise_compairsons(candidates, demographics, demographic_sizes, preferences)
		
		# Is there any candidate preferred over all others?
		considered = results[:pairs].collect { |p| p.first[0] }.uniq
		results[:winners] = considered.collect { |c| c if results[:pairs].count { |p| p.keys.first == c } == candidates.length-1}.compact
		return results unless results[:winners].empty?
		
		# Lock pairs
		require 'rgl/adjacency'
		locked_pairs = Array.new
		results[:locking] = Array.new
		results[:sorted_pairs].each do |p|
			if RGL::DirectedAdjacencyGraph[*(locked_pairs+p.collect{ |p| p.keys }).flatten].cycles.length == 0 
				locked_pairs << p.collect{ |p| p.keys }
				p.each { |p| results[:locking] << [p.keys.first, p.keys.last, "Kept"] }
				results[:locked] = true
			else
				p.each { |p| results[:locking] << [p.keys.first, p.keys.last, "Discarded"] }
			end
		end
		
		# Determine winner
		graph = RGL::DirectedAdjacencyGraph[*locked_pairs.flatten]
		results[:winners] = candidates - graph.edges.collect { |e| e.target  }.uniq
		return results
	end
	
	
	# http://en.wikipedia.org/wiki/Schulze_method
	def schulze_method(candidates, demographics, demographic_sizes, preferences)
		
		# Order the pairwise comparisons
		results = order_pairwise_compairsons(candidates, demographics, demographic_sizes, preferences)
		results[:removed] = Array.new
		
		# Is there any candidate preferred over all others?
		considered = results[:pairs].collect { |p| p.first[0] }.uniq
		results[:winners] = considered.collect { |c| c if results[:pairs].count { |p| p.keys.first == c } == candidates.length-1}.compact
		return results unless results[:winners].empty?
		
		# Build the graph
		require 'rgl/adjacency'
		graph = RGL::DirectedAdjacencyGraph[*results[:sorted_pairs].collect { |m| m.collect { |p| p.keys } }.flatten]
		candidates.each { |c| graph.add_vertex(c) }
		edge_weights = deep_copy(results[:sorted_pairs])
		results[:steps] = Array.new
		
		# Loop until we're out of edges
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
		
		results[:winners] = graph.vertices
		return results
	end
	
	# http://en.wikipedia.org/wiki/Range_voting
	def range_voting(candidates, demographics, demographic_sizes, preferences)
		results = Hash.new
		results[:preferences] = preferences
		results[:sums] = Hash.new
		candidates.each { |c| results[:sums][c] = demographics.inject(0) { |sum,d| sum + preferences[d][c].round * demographic_sizes[d] } }
		results[:winners] = results[:sums].group_by { |c,s| s }.sort { |a,b| b <=> a }[0][1].collect { |c, s| c }
		return results
	end
	
	##########################################################################################
	## Helper methods
	
	def order_pairwise_compairsons(candidates, demographics, demographic_sizes, preferences)
	
		# Initialize the display globals
		results = Hash.new
		results[:preferences] = Hash.new
		results[:supporters] = Hash.new
		results[:votes] = Hash.new

		# Determine the preferences for each candidate
		demographics.each { |d| results[:preferences][d] = preferences[d].sort { |p1,p2| p2[1] <=> p1[1] }.collect {|c,v| c} }

		# Tally each pairwise comparison
		results[:pairs] = candidates.combination(2).to_a.collect do |c|
			comparison = demographics.inject([0,0]) do |votes,d|
				if results[:preferences][d].index(c[0]) > results[:preferences][d].index(c[1])
					[votes[0], votes[1] + demographic_sizes[d]]
				else
					[votes[0] + demographic_sizes[d], votes[1]]
				end
			end
			Hash[c.zip(comparison)] if comparison[0] != comparison[1]
		end.compact
		results[:pairs] = results[:pairs].collect { |c| Hash[*c.sort { |p1,p2| p2[1] <=> p1[1] }.flatten] }
		results[:sorted_pairs] = results[:pairs].group_by { |p| p.values.first }.sort { |m1,m2| m2 <=> m1 }.collect { |s,mp| mp }		
		return results
	end
	
	def deep_copy( object )
		Marshal.load( Marshal.dump( object ) )
	end
end
