require 'minitest/autorun'
require 'ostruct'
require 'set'
require_relative 'lib/repo'

class CrawlerTest < Minitest::Test
  def test_awesome_repo
    fake_octokit_repo = double(stargazers_count: 1000, size: 1)
    assert Repo.new(fake_octokit_repo).awesome?
  end

  def test_meh_repo
    fake_octokit_repo = double(stargazers_count: 1, size: 1)
    refute Repo.new(fake_octokit_repo).awesome?
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

    assert_equal 'joeschmo/rails 50 1000 20', repo.to_s
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

  private

  def double(hash)
    OpenStruct.new(hash)
  end
end
