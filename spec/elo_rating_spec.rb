require_relative '../lib/elo_rating.rb'

describe EloRating do
  after(:each) do
    EloRating::k_factor = 24
  end

  describe '::k_factor' do
    it 'defaults to 24' do
      expect(EloRating::k_factor).to eql(24)
    end
  end

  describe '::k_factor=' do
    it 'sets the K-factor to an integer' do
      EloRating::k_factor = 10
      expect(EloRating::k_factor).to eql(10)
    end
  end

  describe '::set_k_factor' do
    it "takes a block to determine the K-factor based on a player's rating" do
      EloRating::set_k_factor do |rating|
        if rating && rating > 1000
          15
        else
          24
        end
      end
      expect(EloRating::k_factor(1001)).to eql 15
    end

    context "given a block that doesn't handle nil ratings" do
      it 'raises an error' do
        expect do
          EloRating::set_k_factor do |rating|
            rating * 10
          end
        end.to raise_error ArgumentError
      end
    end
  end

  describe '.expected_score' do
    it "returns the odds of a player winning given their rating and their opponent's rating" do
      expect(EloRating.expected_score(1200, 1000)).to be_within(0.0001).of(0.7597)
    end
  end

  describe '.rating_adjustment' do
    it 'returns the amount a rating should change given an expected score and an actual score' do
      expect(EloRating.rating_adjustment(0.75, 0)).to be_within(0.0001).of(-18.0)
    end

    it 'uses the K-factor' do
      expect(EloRating).to receive(:k_factor).and_return(24)

      EloRating.rating_adjustment(0.75, 0)
    end

    context 'custom numeric k-factor' do
      it 'uses the custom k-factor' do
        EloRating::k_factor = 10

        expect(EloRating.rating_adjustment(0.75, 0)).to be_within(0.0001).of(-7.5)
      end
    end

    context 'custom k-factor function' do
      it 'calls the function with the provided rating to determine the k-factor' do
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

        expect(EloRating.rating_adjustment(0.75, 0)).to be_within(0.0001).of(-24.0)
        expect(EloRating.rating_adjustment(0.75, 0, rating: 2200)).to be_within(0.0001).of(-18.0)
        expect(EloRating.rating_adjustment(0.75, 0, rating: 2500)).to be_within(0.0001).of(-12.0)
      end
    end

    context 'provided with a nonce numeric k-factor' do
      it 'uses the provided k-factor' do
        expect(EloRating.rating_adjustment(0.75, 0, k_factor: 24)).to be_within(0.0001).of(-18.0)
      end
    end
  end
end
