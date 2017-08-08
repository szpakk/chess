require_relative 'piece'

class Player
  @@count = 0

  attr_accessor :name, :set
  attr_reader   :color

  def initialize(name)
    @name = name
    @color = @@count == 0 ? 'white' : 'black'
    y = @color == 'white' ? 0 : 7
    @@count += 1
    @set = [King.new(@color, y), Queen.new(@color, y), Rook.new(@color, 0, y),
            Rook.new(@color, 7, y), Knight.new(@color, 1, y), Knight.new(@color, 6, y),
            Bishop.new(@color, 2, y), Bishop.new(@color, 5, y)]
    8.times { |x| @set << Pawn.new(@color, x, (y-1).abs) }
  end

  def king_x
    set[0].x
  end

  def king_y
    set[0].y
  end

  def self.count=(num)
    @@count = num
  end
end
