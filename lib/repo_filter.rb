require 'set'

class RepoFilter
	# Removes duplicate and non-awesome repos from the given
	# enumerable.

	def initialize(enumerable, options={})
		@logger = options[:logger] || STDERR
		@enumerable = enumerable
		@seen = Set.new
		@options = options
	end

	def each
		total_count = 0
		awesome_count = 0

		@enumerable.each do |repo|
			if not_seen_before?(repo)
				total_count += 1

				if awesome? repo
					awesome_count += 1
					print_status(total_count, awesome_count)
					yield repo
					mark_as_seen repo
				end
			end
		end
	end

	private
	def not_seen_before?(repo)
		not @seen.include?(repo.name)
	end

	def mark_as_seen(repo)
		@seen << repo.name
	end

	def print_status(total_count, awesome_count)
		percentage = (awesome_count.to_f / total_count * 100).round(1)
		@logger.print "  #{total_count} repos crawled, #{percentage}% awesome   \r"
	end

	def awesome?(repo)
		repo.score >= min_score && 
			repo.stars >= min_stars &&
			matches_language?(repo)
	end

	def matches_language?(repo)
		language == '' || repo.language == language
	end

	def min_score
		@options[:min_score]
	end

	def min_stars
		@options[:min_stars]
	end

	def language
		@options[:language]
	end
end
