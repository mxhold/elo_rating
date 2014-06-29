# elo_rating

`elo_rating` helps you calculate [Elo ratings](https://en.wikipedia.org/wiki/Elo_rating_system), a rating system used primary for Chess.

It can handle multiple players in one game and allows for custom K-factor functions.

- [API Documentation]()

## Getting started

```ruby
gem install elo_rating
```

or add it to your Gemfile and run `bundle`:

```ruby
gem 'elo_rating'
```

## Usage

Say you have two players, both have ratings of 2000. The second player wins. To
determine both player's updated ratings:


```ruby
match = EloRating::Match.new
match.add_player(rating: 2000)
match.add_player(rating: 2000, winner: true)
match.updated_ratings # => [1988, 2012]
```

The first player's rating goes down 12 points and the second player's goes up 12 points.

### >2 players

Most Elo rating calculators only allow for matches of just 2 players, but the
formula can be extended games with more players by calculating rating adjustments
for each player against each of their opponents.

Say you have three players, rated 1900, 2000, and 2000. They are playing a game
like [Monopoly](https://en.wikipedia.org/wiki/Monopoly_(game)) where there is
only one winner. The third player wins.
To determine their new scores:

```ruby
match = EloRating::Match.new
match.add_player(rating: 1900, winner: true)
match.add_player(rating: 2000)
match.add_player(rating: 2000)
match.updated_ratings # => [1931, 1985, 1985]
```

### Ranked games

Some games like [Mario Kart](https://en.wikipedia.org/wiki/Mario_Kart) have
multiple, ranked winners. Let's say you have three players like before, rated
1900, 2000, and 2000. Instead of indicating the winner, you can specify the
ranks:

```ruby
match = EloRating::Match.new
match.add_player(rating: 1900, rank: 1)
match.add_player(rating: 2000, rank: 2)
match.add_player(rating: 2000, rank: 3)
match.updated_ratings # => [1973, 1997, 1931]
```

## Elo rating functions

The functions used in the above calculations are available for use directly:

### Expected score

Say you have 2 players, rated 1900 and 2000.

```ruby
EloRating.expected_score(1900, 2000) # => 0.360
```

The player rated 1900 has a 36% chance of winning.

### Rating adjustment

You can use the expected score and the results of an actual match to determine
how an Elo rating should change.

Let's say we have the expected rating from above of 0.36. If the first player rated 1900 won the match, their actual score would be 1.

We can use this to determine how much their rating should change:

```ruby
EloRating.rating_adjustment(0.36, 1) # => 15.36
```

Their rating should go up about 15 points if they win.

## K-factor

The K-factor is used in calculating the rating adjustment and determines how much impact the most recent game has on a player's rating.

It defaults to 24:

```ruby
EloRating::k_factor # => 24
```

You can change this to any number. With a lower K-factor, ratings are less volatile and change slower:

```ruby
EloRating::k_factor = 10
match = EloRating::Match.new
match.add_player(rating: 2000, winner: true)
match.add_player(rating: 2000)
match.updated_ratings # => [1995, 2005]
```

You can also pass a block to provide a custom function to calculate the K-factor
based on the player's rating:

```ruby
EloRating::set_k_factor do |rating|
  rating ||= 2000
  if rating < 2100
    32
  elsif 2100 <= rating && rating <= 2400
    24
  else
    16
  end
end
```

You can provide a rating to `EloRating.rating_adjustment` that will be used in
your custom K-factor function:

```ruby
EloRating.rating_adjustment(0.75, 0) # => -24.0
EloRating.rating_adjustment(0.75, 0, rating: 2200) # => -18.0
EloRating.rating_adjustment(0.75, 0, rating: 2500) # => -12.0
```

You can also specify a K-factor for a single rating adjustment:

```ruby
EloRating.rating_adjustment(0.75, 0, k_factor: 24) # => -18.0
```

Note: custom K-factor functions must not raise any exceptions when the rating is nil:

```ruby
EloRating::set_k_factor do |rating|
  rating / 100
end
# => ArgumentError: Error encountered in K-factor block when passed nil rating: undefined method `/' for nil:NilClass
```
