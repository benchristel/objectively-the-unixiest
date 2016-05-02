require 'highline'
require 'octokit'
require 'set'
require_relative 'lib/repo'

GITHUB_USER = ARGV[0]

class Crawl
  def initialize(octokit_github_client)
    @github = octokit_github_client
    @repos = Set.new
  end

  def go(max_repos)
    queue_of_repos_to_crawl =
      Repo.starred_by(me)

    while true
      next_repo = queue_of_repos_to_crawl.shift

      next_repo.stargazers.each do |user|
        awesome_new_repos =
	  Repo.starred_by(user)
	  .reject { |r| repos.include? r }
          .select(&:awesome?)

        awesome_new_repos.each { |repo|
	  puts repo
	  add repo
	  return if repos.size >= max_repos
	}

        queue_of_repos_to_crawl += awesome_new_repos
      end
    end
  end

  private

  def repos
    @repos
  end

  def add(repo)
    repos << repo
  end

  def me
    @github.user
  end
end

cli = HighLine.new
password = cli.ask("github password for #{GITHUB_USER}:") { |q| q.echo = '*' }

github_client = Octokit::Client.new(
  login: GITHUB_USER,
  password: password
)

Crawl.new(github_client).go(100)
