require "elo_rating/version"
require 'elo_rating/match'
# :main: README.md

##
# EloRating helps you calculate Elo ratings.
#
# See the README for an introduction.
module EloRating

  # Default K-factor.
  @k_factor = Proc.new do |rating|
    24
  end

  # Calls the K-factor function with the provided rating.
  def self.k_factor(rating = nil)
    @k_factor.call(rating)
  end

  # Sets the K-factor by providing a block that optionally takes a +rating+
  # argument:
  #
  #   EloRating::set_k_factor do |rating|
  #     if rating && rating > 2500
  #       24
  #     else
  #       16
  #     end
  #   end
  #
  # Raises an +ArgumentError+ if an exception is encountered when calling the provided block with nil as the argument
  def self.set_k_factor(&k_factor)
    k_factor.call(nil)
    @k_factor = k_factor
  rescue => e
    raise ArgumentError, "Error encountered in K-factor block when passed nil rating: #{e}"
  end
  
  # Sets the K-factor to a number.
  def self.k_factor=(k_factor)
    @k_factor = Proc.new do
      k_factor
    end
  end

  # Calculates the expected score of a player given their rating (+player_rating+)
  # and their opponent's rating (+opponent_rating+).
  #
  # Returns a float between 0 and 1 where 0.999 represents high certainty of the
  # first player winning.
  def self.expected_score(player_rating, opponent_rating)
    1.0/(1 + (10 ** ((opponent_rating - player_rating)/400.0)))
  end

  # Calculates the amount a player's rating should change.
  #
  # ==== Arguments
  # * +expected_score+: a float between 0 and 1, representing the probability of
  # the player winning
  # * +actual_score+: 0, 0.5, or 1, whether the outcome was a loss, draw, or win
  # (respectively)
  # * +rating+ (optional): the rating of the player, used by the K-factor function
  # * +k_factor+ (optional): the K-factor to use for this calculation to be used
  # instead of the normal K-factor or K-factor function
  #
  # Returns a positive or negative float representing the amount the player's
  # rating should change.
  def self.rating_adjustment(expected_score, actual_score, rating: nil, k_factor: nil)
    k_factor ||= k_factor(rating)
    k_factor * (actual_score - expected_score)
  end
end

