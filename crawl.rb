require 'highline'
require 'octokit'

GITHUB_USER = ARGV[0]

class Crawl
  MINIMUM_STARS_TO_QUALIFY_AS_A_GOOD_REPO = 100
  MINIMUM_STARS_TO_SIZE_RATIO = 10

  def initialize(octokit_github_client)
    @github = octokit_github_client
    @repos = {} # will map repo name to [stargazer_count, size]
  end

  def go(max_repos)
    queue_of_repos_to_crawl = repos_starred_by(me)

    while repos.size < max_repos
      next_repo = queue_of_repos_to_crawl.shift

      if next_repo.nil?
        STDERR.puts "Something has gone horribly wrong! We've run out of internet!"
        break
      end

      add next_repo

      if queue_of_repos_to_crawl.size > max_repos
        # we have enough repos! stop crawling for more
        next
      end

      users_who_starred(next_repo).each do |user|
        interesting_repos = repos_starred_by(user)
          .select { |repo| !repos.include?(repo) && good?(repo) }

        queue_of_repos_to_crawl += interesting_repos

        STDERR.puts "found #{queue_of_repos_to_crawl.length}/#{max_repos} interesting repos"
      end
    end

    print_repos
  end

  private

  def repos
    @repos
  end

  def print_repos
    sorted_repos = repos.to_a.sort_by do |repo|
      stars, size = repo[1]
      -stars.to_f / size
    end

    sorted_repos.each do |repo|
      name = repo[0]
      stars, size = repo[1]
      puts "#{name} #{(stars.to_f/size).round(2)} = #{stars}/#{size}"
    end
  end

  def add(repo)
    repos[repo.full_name] = [repo.stargazers_count, repo.size]
  end

  def good?(repo)
    repo.stargazers_count >= MINIMUM_STARS_TO_QUALIFY_AS_A_GOOD_REPO &&
      repo.stargazers_count.to_f / repo.size >= MINIMUM_STARS_TO_SIZE_RATIO
  end

  def me
    @github.user
  end

  def repos_starred_by(user)
    user.rels[:starred].get.data
  end

  def users_who_starred(repo)
    repo.rels[:stargazers].get.data
  end
end

cli = HighLine.new
password = cli.ask("github password for #{GITHUB_USER}:") { |q| q.echo = '*' }

github_client = Octokit::Client.new(
  login: GITHUB_USER,
  password: password
)

Crawl.new(github_client).go(100)
