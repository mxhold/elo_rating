require_relative '../lib/elo_rating.rb'

describe EloRating do
  before do
    @delta = 0.001
  end

  describe '.k_factor' do
    it 'defaults to 24' do
      EloRating.k_factor = nil
      expect(EloRating.k_factor).to eql 24
    end
  end

  describe '.k_factor=' do
    it 'sets the K factor' do
      EloRating.k_factor = 32
      expect(EloRating.k_factor).to eql 32
      EloRating.k_factor = nil
    end
  end

  describe '.expected_score' do
    it 'returns the probability of the first player winning given two players\' Elo ratings' do
      expect(EloRating.expected_score(1613, 1388)).to be_within(@delta).of(0.785)
    end
  end

  describe '.rating_adjustment' do
    it 'returns the amount a rating should change given an expected score and an actual score' do
      expect(EloRating.rating_adjustment(0.5, 1)).to eql(12.0)
    end
  end

  describe '.updated_ratings' do
    # Calculations taken from http://elo.divergentinformatics.com/
    it 'returns updated scores for any number of players given their current ratings and place in a match' do
      updated_ratings = EloRating.updated_ratings({
          2000 => 3,
          1900 => 2,
          1800 => 1
      })
      expect(updated_ratings[0]).to be_within(@delta).of(1966.405)
      expect(updated_ratings[1]).to be_within(@delta).of(1900)
      expect(updated_ratings[2]).to be_within(@delta).of(1833.595)
    end
  end
end
