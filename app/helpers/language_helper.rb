module LanguageHelper
    include ApplicationHelper
 
    def terms(array, separator, final_separator)
		if array.length == 1
			return array[0]
		else
			final_term = array.last
			return (array-[array.last]).join(separator) + final_separator + final_term
		end
	end
end