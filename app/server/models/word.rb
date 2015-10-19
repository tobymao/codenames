module Models
  class Word
    attr_reader :value, :owner, :chosen

    def initialize(value, owner)
      @value = value
      @owner = owner
      @chosen = false
    end

    def choose
      @chosen = true
    end

    def chosen?
      @chosen
    end

    def red?
      @owner = :red
    end

    def blue_team?
      @owner = :blue
    end

    def assasin?
      @owner = :assasin
    end

    def neutral?
      @owner = :neutral
    end

    def data
      {
        value: @value,
        owner: @owner,
        chosen: @chosen,
      }
    end
  end
end
