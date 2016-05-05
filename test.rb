require 'minitest/autorun'
require 'ostruct'
require 'set'
require_relative 'lib/repo'
require_relative 'lib/repo_filter'
require_relative 'lib/repo_finder'

module UsesDoubles
  def double(hash)
    OpenStruct.new(hash)
  end
end

class Repotest < Minitest::Test
  include UsesDoubles

  def test_checking_score_avoids_division_by_zero
    fake_octokit_repo = double(stargazers_count: 101, size: 0)
    assert_equal 101, Repo.new(fake_octokit_repo).score
  end

  def test_repo_has_a_name
    fake_octokit_repo = double(full_name: 'joeschmo/rails')
    assert_equal 'joeschmo/rails', Repo.new(fake_octokit_repo).name
  end

  def test_repo_has_stargazers
    fake_octokit_repo = double(rels: {
      stargazers: double(get: double(data: [1,2,3]))
    })

    repo = Repo.new(fake_octokit_repo)

    assert_equal 3, repo.stargazers.size
  end

  def test_repo_stringifies
    fake_octokit_repo = double(
      full_name: 'joeschmo/rails',
      stargazers_count: 1000,
      size: 20
    )

    repo = Repo.new(fake_octokit_repo)

    assert_equal 'joeschmo/rails 47 1000 20', repo.to_s
  end

  def test_getting_a_users_starred_repos
    fake_octokit_user = double(rels: {
      starred: double(
        get: double(
          data: [
            double(full_name: 'joe/rails')
          ]
        )
      )
    })

    assert_equal 'joe/rails',
      Repo.starred_by(fake_octokit_user)[0].name
  end

  def test_repo_storage_in_set
    rails1 = Repo.new double(
      full_name: 'joeschmo/rails'
    )

    rails2 = Repo.new double(
      full_name: 'joeschmo/rails'
    )

    scientist = Repo.new double(
      full_name: 'github/scientist'
    )

    set = Set.new
    set << rails1
    assert set.include? rails2
    set << rails2
    assert_equal 1, set.size
    refute set.include? scientist
  end
end

class RepoFilterTest < Minitest::Test
  include UsesDoubles

  class NullLogger
    def print(s); end
  end

  def test_it_excludes_nonawesome_repos
    awesome1 = double(stars: 100, score: 10, name: 'a')
    awesome2 = double(stars: 200, score: 20, name: 'b')
    meh1 = double(stars: 200, score: 9, name: 'c')
    meh2 = double(stars: 99, score: 10, name: 'd')

    yielded = []
    RepoFilter.new([awesome1, meh1, awesome2, meh2], logger: NullLogger.new, min_stars: 100, min_score: 10).each do |repo|
      yielded << repo
    end

    assert yielded.include? awesome1
    assert yielded.include? awesome2
    refute yielded.include? meh1
    refute yielded.include? meh2
  end

  def test_it_yields_repos_only_once
    awesome   = double(score: 10, stars: 100, name: 'scientist')
    duplicate = double(score: 10, stars: 100, name: 'scientist')

    yielded = []
    RepoFilter.new([awesome, duplicate], logger: NullLogger.new, min_stars: 100, min_score: 10).each do |repo|
      yielded << repo
    end

    assert yielded.include? awesome
    assert_equal 1, yielded.size
  end
end

class RepoFinderTest < Minitest::Test
  include UsesDoubles

  def test_it_finds_repos_starred_by_a_user
    repos = [
      double(full_name: 'hector/g'),
      double(full_name: 'joeschmo/rails'),
      double(full_name: 'paxicorn/whaddayamean')
    ]

    user = double(
      login: 'phooie',
      rels: {
        starred: double(
          get: double(data: repos)
        )
      }
    )

    count = 0
    yielded = []
    RepoFinder.crawling_from_user(user).each do |repo|
      yielded << repo
      count += 1
      break if count == 3
    end

    assert_equal 3, yielded.size
    assert yielded.map(&:name).include? 'hector/g'
  end

  def test_it_traverses_the_star_graph
    hector = double(
      login: 'hector',
      rels: {}
    )

    paxicorn = double(
      login: 'paxicorn',
      rels: {}
    )

    g = double(
      full_name: 'hector/g',
      rels: {
        stargazers: double(
          get: double(data: [hector])
        )
      }
    )

    rails = double(
      full_name: 'joeschmo/rails',
      rels: {
        stargazers: double(
          get: double(data: [hector, paxicorn])
        )
      }
    )

    whaddayamean = double(
      full_name: 'paxicorn/whaddayamean',
      rels: {
        stargazers: double(
          get: double(data: [paxicorn])
        )
      }
    )

    hector.rels[:starred] = double(
      get: double(data: [g, rails])
    )

    paxicorn.rels[:starred] = double(
      get: double(data: [whaddayamean, rails])
    )

    yielded = []
    RepoFinder.crawling_from_user(hector).each do |repo|
      yielded << repo
    end

    assert yielded.map(&:name).include? 'hector/g'
    assert yielded.map(&:name).include? 'joeschmo/rails'
    assert yielded.map(&:name).include? 'paxicorn/whaddayamean'
  end
end
