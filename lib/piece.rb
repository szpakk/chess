require 'colorize'

class Piece
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def x
    position[0]
  end

  def y
    position[1]
  end

  def diagonal_moves
    moves = []
    1.upto(7) do |i|
      y_pos = y + i
      x_pos = x + i
      y_neg = y - i
      x_neg = x - i
      moves << [x_pos, y_pos]
      moves << [x_neg, y_pos]
      moves << [x_neg, y_neg]
      moves << [x_pos, y_neg]
    end
    moves.select! { |x, y| x.between?(0, 7) && y.between?(0, 7) }
  end

  def straight_moves
    moves = []
    8.times do |i|
      moves << [x, i] unless i == y
      moves << [i, y] unless i == x
    end
    moves
  end

  def colors
    background = (self.x + self.y).odd? ? :light_blue : :blue
    piece_color = color == 'white' ? :white : :black
    {:color => piece_color, :background => background}
  end
end

class Pawn < Piece
  attr_accessor :first_step, :position

  def initialize(color, x, y)
    super(color)
    @position = [x, y]
    @first_step = position
  end

  def potential_moves
    moves = [[x, y + 1]] if color == 'white' && y < 7
    moves = [[x, y - 1]] if color == 'black' && y > 0
    moves << [x, y + 2] if color == 'white' && first_step? 
    moves << [x, y - 2] if color == 'black' && first_step?
    moves << [x + 1, y + 1] if color == 'white' && x < 7
    moves << [x - 1, y + 1] if color == 'white' && x > 0
    moves << [x + 1, y - 1] if color == 'black' && x < 7
    moves << [x - 1, y - 1] if color == 'black' && x > 0
    moves 
  end

  def first_step?
    first_step == position
  end

  def promotion?
    return y == 7 if color == 'white'
    return y == 0 if color == 'black'
  end

  def to_s
    " \u265F ".colorize(colors)
  end
end

class Rook < Piece
  attr_accessor :position, :first_move

  def initialize(color, x, y)
    super(color)
    @position = [x, y]
    @first_move = true
  end

  def potential_moves
    straight_moves
  end

  def to_s
    " \u265C ".colorize(colors)
  end

  def first_move?
    first_move
  end
end

class Bishop < Piece
  attr_accessor :position

  def initialize(color, x, y)
    super(color)
    @position = [x, y]
  end

  def potential_moves
    diagonal_moves
  end

  def to_s
    " \u265D ".colorize(colors)
  end
end

class Queen < Piece
  attr_accessor :position

  def initialize(color, y)
    super(color)
    @position = [3, y]
  end

  def potential_moves
    diagonal_moves + straight_moves
  end

  def to_s
    " \u265B ".colorize(colors)
  end
end

class King < Piece
  attr_accessor :position, :first_move

  def initialize(color, y)
    super(color)
    @position = [4, y]
    @first_move = true
  end

  def potential_moves
    moves = [[x + 1, y + 1], [x + 1, y], [x + 1, y - 1], [x, y + 1],
             [x - 1, y + 1], [x - 1, y], [x - 1, y - 1], [x, y + 1]]
    moves.select! { |x, y| x.between?(0,7) && y.between?(0,7) }
    moves
  end

  def first_move?
    first_move
  end

  def to_s
    " \u265A ".colorize(colors)
  end
end

class Knight < Piece
  attr_accessor :position

  def initialize(color, x, y)
    super(color)
    @position = [x, y]
  end

  def potential_moves
    moves = [[x - 2, y - 1], [x - 2, y + 1], [x - 1, y - 2], [x - 1, y + 2],
             [x + 1, y - 2], [x + 1, y + 2], [x + 2, y - 1], [x + 2, y + 1]]
    moves.select { |x, y| x.between?(0,7) && y.between?(0,7) }
  end

  def to_s
    " \u265E ".colorize(colors)
  end
end
