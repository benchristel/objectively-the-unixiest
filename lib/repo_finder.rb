require_relative 'repo'
require 'octokit'

class CrawlQueue
	def initialize
		@queue = []
	end

	def enqueue(user_or_repo)
		@queue << user_or_repo
	end

	def dequeue
		thing = @queue.shift
		if userish? thing
			return thing
		elsif repoish? thing
			@queue = thing.stargazers + @queue
			return dequeue
		else
			return nil
		end
	end

	private

	def userish?(thing)
		thing.respond_to?(:login) && thing.login
	end

	def repoish?(thing)
		thing.respond_to? :stargazers
	end
end

class RepoFinder
	def self.crawling_from_user(user)
		new(user, Set.new)
	end

	def initialize(user, visited_users)
		@user = user
	end

	def each
		@visited_users = Set.new
		queue = CrawlQueue.new
		queue.enqueue(@user)

		while user = queue.dequeue
			next if visited? user
			visit user
			starred_repos = Repo.starred_by user
			starred_repos.each do |repo|
				yield repo
				queue.enqueue(repo)
			end
		end
	end

	def visit(user)
		@visited_users << user.login
	end

	def visited?(user)
		@visited_users.include? user.login
	end
end
