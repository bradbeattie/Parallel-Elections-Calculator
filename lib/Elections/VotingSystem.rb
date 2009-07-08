module Elections
	class VotingSystem
		def self.candidates(demographics)
			demographics.values.collect { |a| a[:preferences].collect { |p| p[0] } }.flatten.uniq
		end
		
		def self.restrictedDemographics(demographics, candidates)
			result = deep_copy(demographics)
			result.each { |d,a| a[:preferences] = a[:preferences].select { |c,v| candidates.include?(c) } }
			return result
		end
	end
end

class Hash
	def grouping_invert
		new_hash = self.group_by { |k,v| v }
		Hash[*new_hash.keys.zip(new_hash.collect { |k,v| v.collect { |w| w[0] } }).flatten(1)]
	end
end

class Array
	def weighted_random(weights=nil)
		return weighted_random(map {|n| n.send(weights)}) if weights.is_a? Symbol

		weights ||= Array.new(length, 1.0)
		total = weights.inject(0.0) {|t,w| t+w.to_f}
		point = Kernel.rand * total
		
		zip(weights).each do |n,w|
			return n if w >= point
			point -= w
		end
	end
end

def deep_copy(object)
	Marshal.load(Marshal.dump(object))
end
