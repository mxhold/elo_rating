require_relative '../lib/elo_rating.rb'

describe EloRating::Match do
  describe '#updated_ratings' do
    context 'simple match with two players and one winner' do
      it 'returns the updated ratings of all the players' do
        match = EloRating::Match.new
        match.add_player(rating: 2000)
        match.add_player(rating: 2000, winner: true)
        expect(match.updated_ratings).to eql [1988, 2012]
      end
    end
    context 'match with 3 players and one winner' do
      it 'returns the updated ratings of all the players' do
        match = EloRating::Match.new
        match.add_player(rating: 1900, winner: true)
        match.add_player(rating: 2000)
        match.add_player(rating: 2000)
        expect(match.updated_ratings).to eql [1931, 1985, 1985]
      end
    end
    context 'ranked game with 3 players' do
      it 'returns the updated ratings of all the players' do
        match = EloRating::Match.new
        match.add_player(rating: 1900, place: 1)
        match.add_player(rating: 2000, place: 2)
        match.add_player(rating: 2000, place: 3)
        expect(match.updated_ratings).to eql [1931, 1997, 1973]
      end
    end
    context 'multiple winners specified' do
      it 'raises an error' do
        match = EloRating::Match.new
        match.add_player(rating: 1000, winner: true)
        match.add_player(rating: 1000, winner: true)
        expect { match.updated_ratings }.to raise_error ArgumentError
      end
    end
    context 'place specified for one player but not all' do
      it 'raises an error' do
        match = EloRating::Match.new
        match.add_player(rating: 1000)
        match.add_player(rating: 1000, place: 2)
        expect { match.updated_ratings }.to raise_error ArgumentError
      end
    end
  end

  describe '#add_player' do
    context 'adding a player with a rating' do
      it 'creates a new player with the specified rating' do
        match = EloRating::Match.new
        expect(EloRating::Match::Player).to receive(:new).with(rating: 2000, match: match)

        match.add_player(rating: 2000)
      end
      it 'appends the new player to the match\'s player' do
        match = EloRating::Match.new
        match.add_player(rating: 2000)

        expect(match.players.size).to eql 1
      end
      it 'returns the match itself so multiple calls can be chained' do
        match = EloRating::Match.new
        match.add_player(rating: 1000).add_player(rating: 2000)

        expect(match.players.size). to eql 2
      end
    end

    context 'adding a player with a non-numeric rating' do
      it 'raises an error' do
        match = EloRating::Match.new

        expect { match.add_player(rating: :foo) }.to raise_error(ArgumentError)
      end
    end

    context 'adding a player with a non-numeric place' do
      it 'raises an error' do
        match = EloRating::Match.new

        expect { match.add_player(rating: 1000, place: :foo) }.to raise_error(ArgumentError)
      end
    end

    context 'adding a player with both winner and place specified' do
      it 'raises an error' do
        match = EloRating::Match.new

        expect { match.add_player(rating: 1000, place: 2, winner: true) }.to raise_error ArgumentError
      end
    end
  end
end
