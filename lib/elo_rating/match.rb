##
# This class represents a single game between a number of players.
class EloRating::Match

  # All the players of the match.
  attr_reader :players

  # Creates a new match with no players.
  def initialize
    @players = []
  end

  # Adds a player to the match
  #
  # ==== Attributes
  # * +rating+: the Elo rating of the player
  # * +winner+ (optional): boolean, whether this player is the winner of the match
  # * +place+ (optional): a number representing the rank of the player within the match; the lower the number, the higher they placed
  #
  # Raises an +ArgumentError+ if the rating or place is not numeric, or if
  # both winner and place is specified.
  def add_player(**player_attributes)
    players << Player.new(**(player_attributes.merge(match: self)))
    self
  end

  # Calculates the updated ratings for each of the players in the match.
  #
  # Raises an +ArgumentError+ if more than one player is marked as the winner or
  # if some but not all players have +place+ specified.
  def updated_ratings
    validate_players!
    players.map(&:updated_rating)
  end

  private

  def validate_players!
    raise ArgumentError, 'Only one player can be the winner' if multiple_winners?
    raise ArgumentError, 'All players must have places if any do' if inconsistent_places?
  end

  def multiple_winners?
    players.select { |player| player.winner? }.size > 1
  end

  def inconsistent_places?
    players.select { |player| player.place }.any? &&
      players.select { |player| !player.place }.any?
  end

  class Player
  # :nodoc:
    attr_reader :rating, :place, :match
    def initialize(match:, rating:, place: nil, winner: nil)
      validate_attributes!(rating: rating, place: place, winner: winner)
      @match = match
      @rating = rating
      @place = place
      @winner = winner
    end

    def winner?
      @winner
    end

    def validate_attributes!(rating:, place:, winner:)
      raise ArgumentError, 'Rating must be numeric' unless rating.is_a? Numeric
      raise ArgumentError, 'Winner and place cannot both be specified' if place && winner
      raise ArgumentError, 'Place must be numeric' unless place.nil? || place.is_a?(Numeric)
    end

    def opponents
      match.players - [self]
    end

    def updated_rating
      (rating + total_rating_adjustments).round
    end

    def total_rating_adjustments
      opponents.map do |opponent|
        rating_adjustment_against(opponent)
      end.reduce(0, :+)
    end

    def rating_adjustment_against(opponent)
      EloRating.rating_adjustment(
        expected_score_against(opponent),
        actual_score_against(opponent),
        rating: rating
      )
    end

    def expected_score_against(opponent)
      EloRating.expected_score(rating, opponent.rating)
    end

    def actual_score_against(opponent)
      if won_against?(opponent)
        1
      elsif opponent.won_against?(self)
        0
      else # draw
        0.5
      end
    end

    def won_against?(opponent)
      winner? || placed_ahead_of?(opponent)
    end

    def placed_ahead_of?(opponent)
      if place && opponent.place
        place < opponent.place
      end
    end
  end
end

