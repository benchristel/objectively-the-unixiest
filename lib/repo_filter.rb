require 'set'

class RepoFilter
	# Removes duplicate and non-awesome repos from the given
	# enumerable.

	def initialize(enumerable)
		@enumerable = enumerable
		@seen = Set.new
	end

	def each
		total_count = 0
		awesome_count = 0

		@enumerable.each do |repo|
			if not_seen_before?(repo)
				total_count += 1

				if repo.awesome?
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
		not @seen.include?(repo)
	end

	def mark_as_seen(repo)
		@seen << repo
	end

	def print_status(total_count, awesome_count)
		percentage = (awesome_count.to_f / total_count * 100).round(1)
		STDERR.print "  #{total_count} repos crawled, #{percentage}% awesome   \r"
	end
end