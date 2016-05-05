require 'highline'
require 'trollop'
require 'octokit'
require 'set'
require_relative 'lib/repo'
require_relative 'lib/repo_filter'
require_relative 'lib/repo_finder'

cli_options = Trollop.options do
  opt :quota, "Number of awesome repos to output before exiting", 
    type: :integer,
    default: 100

  opt :min_stars, "Don't output repos with fewer stars than this", 
    type: :integer,
    default: 100

  opt :min_score, "Don't output repos with a lower score than this, where score = stars/size",
    type: :integer,
    default: 10

  opt :language, "Output only repos written in these languages (comma-separated)", 
    type: :string, 
    default: ''
end

GITHUB_USER = ARGV[0]

class Crawl
  def initialize(octokit_github_client, options)
    @github = octokit_github_client
    @options = options
  end

  def go
    count = 0

    find_awesome_repos.each do |repo|
      puts repo
      count += 1
      break if count == quota
    end
    STDERR.puts "\ndone!"
  end

  private

  def find_awesome_repos
    RepoFilter.new(RepoFinder.crawling_from_user(me), @options)
  end

  def me
    @github.user
  end

  def quota
    @options[:quota]
  end
end

cli = HighLine.new(STDIN, STDERR)
password = cli.ask("github password for #{GITHUB_USER}:") { |q| q.echo = '*' }

github_client = Octokit::Client.new(
  login: GITHUB_USER,
  password: password
)

Crawl.new(github_client, cli_options).go
