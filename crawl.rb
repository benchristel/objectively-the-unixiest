require 'highline'
require 'octokit'
require 'set'
require_relative 'lib/repo'
require_relative 'lib/repo_filter'
require_relative 'lib/repo_finder'

GITHUB_USER = ARGV[0]

class Crawl
  def initialize(octokit_github_client)
    @github = octokit_github_client
  end

  def go(max_repos)
    count = 0

    find_awesome_repos.each do |repo|
      puts repo
      count += 1
      break if count == max_repos
    end
    STDERR.puts "\ndone!"
  end

  private

  def find_awesome_repos
    RepoFilter.new(RepoFinder.crawling_from_user(me))
  end

  def me
    @github.user
  end
end

cli = HighLine.new(STDIN, STDERR)
password = cli.ask("github password for #{GITHUB_USER}:") { |q| q.echo = '*' }

github_client = Octokit::Client.new(
  login: GITHUB_USER,
  password: password
)

Crawl.new(github_client).go(450)
