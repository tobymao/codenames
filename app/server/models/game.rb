module Models
  class Game
    WORDS = %w(Acne Acre Addendum Advertise Aircraft Aisle Alligator Alphabetize America Ankle Apathy Applause Applesauce Application Archaeologist Aristocrat Arm Armada Asleep Astronaut Athlete Atlantis Aunt Avocado).freeze

    attr_reader :id, :current, :words, :winner, :team_a, :team_b
    attr_accessor :team_a, :team_b

    def initialize
      @id = SecureRandom.uuid
      @team_a = []
      @team_b = []
      @red_team = []
      @blue_team = []

      @clues = 0
      @first, @second = Random.rand(2) == 0 ? [:red, :blue] : [:blue, :red]
      @current = @first
      @words = setup_words(@first, @second)
      puts "*** my words are #{words}"
    end

    def give_clue(clue, count)
      @clues = count
    end

    def end_turn
      @current = other
      @clues = 0
    end

    def end_game(winner)
      @clues = 0
      @winner = winner
    end

    def choose_word(value)
      word = @words.find(value)
      recurrent nil if word.chosen?

      word.choose
      @clues -= 1

      if @current != word.owner || @clues <= 0
        end_turn
      end

      end_game(other) if word.assasin?
      end_game(:red) if @words.select(&:red?).all?(&:chosen?)
      end_game(:blue) if @words.select(&:blue?).all?(&:chosen?)

      word.owner
    end

    def data
      {
        id: @id,
        red_team: @red_team,
        blue_team: @blue_team,
        clues: @clues,
        current: @current,
        words: @words.map(&:data),
      }
    end

    private
    def other
      @current == :red ? :blue : :red
    end

    def setup_words(first, second)
      pool = [:assasin]
      7.times { pool << :neutral }
      8.times { pool << second }
      9.times { pool << first }

      WORDS.sample(25).map do |word|
        Word.new(word, pool.delete_at(rand(pool.length)))
      end
    end
  end
end
