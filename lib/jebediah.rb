class Jebediah
	def self.version
		return "1.0.2"
	end

	def initialize(dictPaths=nil)
		if dictPaths == nil then
			# Default configuration is a 3-word phrase (adverb, verb, animal)
			#   e.g. "ridiculously elaborated parrot"
			base = File.expand_path(File.dirname(__FILE__) + '/../dictionaries')
			dictPaths = [
				File.join(base, "adverbs.txt"),
				File.join(base, "verbs.txt"),
				File.join(base, "animals.txt"),
			]
		end

		loadDictionaries(dictPaths)
	end

	# Returns number of words expected in a phrase for this Jebediah instance
	def phraseLength
		return @dictionaries.length
	end

	# Load in dictionaries from paths
	def loadDictionaries(dictPaths)
		@dictionaries = []
		dictPaths.each do |dictPath|
			unless File.exists?(dictPath) then
				puts "Dictionary does not exist: #{dictPath}"
				return
			end

			unless File.file?(dictPath) then
				puts "Dictionary is not a regular file: #{dictPath}"
			end

			unless File.readable?(dictPath) then
				puts "Dictionary is not readable: #{dictPath}"
			end

			# Read dictionary lines into an array, no trailing newline
			@dictionaries.push File.open(dictPath, 'r') { |file| file.readlines.collect{|line| line.chomp} }
		end
	end

	# Test if a string is a valid hash
	def isHash?(str)
		str =~ /^[0-9a-fA-F]+$/
	end

	# Processes arbitrary input formatted as a string
	def processString(str)
		if isHash?(str) then
			return { :type => 'phrase', :result => phraseForHash(str) }
		else
			terms = str.split(' ')
			return { :type => 'hash', :result => hashForPhrase(terms) } if phraseLength == terms.length
			return { :type => 'unreadable' }
		end
	end

	# Processes arbitrary input formatted as an array
	def processArray(arr)
		return processString(arr[0]) if arr.length == 1
		return { :type => 'hash', :result => hashForPhrase(arr) } if arr.length == phraseLength
		return { :type => 'error' }
	end

	# Process an arbitrary string or array, and guess its meaning
	# Returns a hash
	#  :result = hash of phrase (if :type == 'hash'), phrase for hash (if :type == 'phrase'), or undefined (otherwise)
	#  :type = 'hash', 'phrase', 'error'
	def process(input)
		r = processString(input) if input.is_a?(String)
		r = processArray(input) if input.is_a?(Array)
		r[:type] = 'error' if !r.has_key?(:result) || r[:result].nil?
		r.delete(:result) if r[:type] == 'error'

		return r
	end

	# Renders a result from process() as a string
	def renderResult(result)
		has_keys = result.has_key?(:type) and result.has_key?(:result)
		return "Error processing input" if !has_keys or result[:type] == 'error' or result[:type].nil?
		return result[:result] if result[:result].is_a?(String)
		return result[:result].join(" ") if result[:result].is_a?(Array)

		return "Error processing result"
	end

	# Convert a phrase into a hash, e.g. "disobligingly hypnotized grizzly" -> "0123abc"
	# Returns nil if the phrase cannot be converted
	# Phrase can be supplied as a string or array. If string, then words must be separated by whitespace.
	def hashForPhrase(phrase)
		# Suppose we have n+1 dictionaries in our nomenclature.
		# Let L_i be the length of the nth dictionary for 0 <= i <= n.
		# Let W_i be the ith word in the phrase
		# Let K_i be the index of W_i in the ith dictionary, zero-based (i.e. 0 <= K_i < L_i)
		# Our hash is:
		#   H = K0 + L0 K1 + L0 L1 K2 + ... + L0 L1 ... L_(n-1) K_n
		#
		# Represent this integer in hexadecimal to get a hash string.

		weight = 1
		hash = 0

		phrase = phrase.gsub(/\s+/m, ' ').strip.split(' ') if phrase.is_a?(String)

		# If the phrase doesn't have the same number of words as our nomenclature requires, we can't convert
		if phrase.length != @dictionaries.length then
			return nil
		end

		phrase.length.times do |i|
			word = phrase[i]
			dict = @dictionaries[i]
			lineNumber = dict.index(word)
			if lineNumber.nil? then
				return nil
			end

			hash += lineNumber*weight
			weight *= dict.length
		end

		# Render the hash as a 7-digit hex string (suitable for git)
		"%07x" % hash
	end

	# Convert a hash into a phrase, e.g. "abc4321" -> "rightward succeeded seal"
	# Hash can be supplied as an integer, or hexadecimal string.
	#
	# Returns nil if the hash cannot be converted
	def phraseForHash(hash)
		# As noted in hashForPhrase, our hash is just an integer index, of the form
		#  H = K0 + L0 K1 + L0 L1 K2 + ... + L0 L1 ... L_(n-1) K_n
		#
		# The key insight in reversing this is to realize that if we write,
		#   c_0 = 1,  c_n = L0 L1 ... L_(n-1)
		#   s_n = c_n K_n
		#   S_n = s0 + s1 + ... + s_n, 
		# then we must have,
		#   c_(n+1) > S_n.    (see proof below)
		#
		# So if we consider
		#   H = S_n = c_n K_n + S_(n-1)
		# then
		#   S_n / c_n = K_n + S_(n-1) / c_n
		# We know that 0 <= S_(n-1) / c_n < 1, so
		#   int(S_n/c_n) = K_n
		#
		# We can use this information to recurse:
		#   s_n = c_n K_n = c_n * int(S_n/c_n)
		#   S_n - s_n = S_(n-1),

		begin
			hash = "0x" + hash if hash.is_a?(String) and !hash.start_with?("0x")
			weight = @dictionaries.inject(1) { |x, dict| dict.length * x } # L0 L1 L2 ... L_n
			sum = Integer(hash) % weight
			lines = [ 0 ] * @dictionaries.length # We fill from the end backwards, so allocate the total size up front

			(@dictionaries.length-1).downto(0) do |n|
				weight /= @dictionaries[n].length # c_n = L0 L1 .. L_(n-1)
				lines[n] = (sum / weight).to_i # K_n = int(S_n / c_n)
				sum -= weight * lines[n] # S_(n-1) = S_n - c_n K_n
			end
		rescue
			return nil
		end

		#     Proof of c_(n+1) > S_n
		#
		# The following is an inductive proof.
		# Base case:  (c1 > S0)
		#   c1 > S0   <=>   L0 > K0, which we know by definition (0 <= K_i < L_i)
		#
		# Inductive step:  (c_n > S_(n-1)  =>  c_(n+1) > S_n)
		# Recall that,
		#   c_n = L0 L1 ... L_(n-1)
		# Notice that (L_n - K_n) >= 1, so
		#   c_n < L0 L1 ... L_(n-1) * (L_n - K_n) = c_(n+1) - s_n
		# So,
		#         c_n > S_(n-1)
		#    =>  c_(n+1) - s_n > S_(n-1)
		#    =>  c_(n+1) > S_(n-1) + s_n = S_n
		# Therefore, c_n > S_(n-1) => c_(n+1) > S_n.
		# Since we have c1 > S0,
		#   c_(n+1) > S_n for all n > 0.

		phrase = []
		@dictionaries.length.times do |i|
			phrase.push @dictionaries[i][lines[i]].strip
		end

		phrase
	end
end
