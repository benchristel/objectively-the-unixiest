class Repo
  MINIMUM_STARS = 100
  MINIMUM_SCORE = 10

  def initialize(octokit_repo)
    @octokit_repo = octokit_repo
  end

  def self.starred_by(octokit_user)
    octokit_user.rels[:starred].get.data.map(&method(:new))
  end

  def awesome?
    stars > MINIMUM_STARS &&
      score > MINIMUM_SCORE
  end

  def score
    stars / (size + 1)
  end

  def size
    @octokit_repo.size
  end

  def stars
    @octokit_repo.stargazers_count
  end

  def stargazers
    @octokit_repo.rels[:stargazers].get.data
  end

  def name
    @octokit_repo.full_name
  end

  def to_s
    "#{name} #{score} #{stars} #{size}"
  end

  def eql?(other)
    name == other.name
  end

  def hash
    name.hash
  end
end
