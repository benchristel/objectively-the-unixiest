require_relative 'repo'

class RepoFinder
	def self.crawling_from_user(user)
		new(user, Set.new)
	end

	def initialize(user, visited_users)
		@user = user
		@visited_users = visited_users
		visited_users << user.login
	end

	def each
		repos = Set.new

		repos_starred_by_user.each do |repo|
			yield repo
			repos << repo
		end

		repos.each do |repo|
			not_visited(repo.stargazers).each do |user|
				RepoFinder.new(user, @visited_users).each do |repo|
					yield repo
				end
			end
		end
	end

	def repos_starred_by_user
		@user.rels[:starred].get.data.map(&Repo.method(:new))
	end

	def not_visited(users)
		users.reject do |u|
			@visited_users.include? u.login
		end
	end
end