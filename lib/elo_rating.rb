module EloRating
  def self.k_factor
    @@k_factor ||= 24
  end
  
  def self.k_factor=(k_factor)
    @@k_factor = k_factor
  end

  def self.expected_score(player_rating, opponent_rating)
    1.0/(1 + (10 ** ((opponent_rating - player_rating)/400.0)))
  end

  def self.rating_adjustment(expected_score, actual_score)
    k_factor * (actual_score - expected_score)
  end

  def self.updated_ratings(results)
    Match.new(results).updated_ratings
  end

  class Match
    attr_reader :players
    def initialize(results)
      @players = results.map do |rating, place|
        Player.new(rating, place)
      end
      @players.each do |player|
        player.opponents = @players - [player]
      end
    end

    def updated_ratings
      players.map(&:updated_rating)
    end
  end

  class Player
    attr_accessor :opponents
    attr_reader :rating, :place
    def initialize(rating, place)
      @rating = rating
      @place = place
    end

    def updated_rating
      rating + total_rating_adjustments
    end

    def total_rating_adjustments
      opponents.map do |opponent|
        rating_adjustment_against(opponent)
      end.reduce(0, :+)
    end

    def rating_adjustment_against(opponent)
      EloRating.rating_adjustment(
        expected_score_against(opponent),
        actual_score_against(opponent)
      )
    end

    def expected_score_against(opponent)
      EloRating.expected_score(rating, opponent.rating)
    end

    def actual_score_against(opponent)
      if place < opponent.place # won
        1
      elsif place > opponent.place # lost
        0
      else # draw
        0.5
      end
    end
  end
end
