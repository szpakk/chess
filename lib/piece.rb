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
    7.times do |i|
      y_pos = y + i
      x_pos = x + i
      y_neg = y - i
      x_neg = x - i 
      moves << [x_pos, y_pos] if x_pos.between?(0,7) && y_pos.between?(0,7)
      moves << [x_neg, y_pos] if x_neg.between?(0,7) && y_pos.between?(0,7)
      moves << [x_neg, y_neg] if x_neg.between?(0,7) && y_neg.between?(0,7)
      moves << [x_pos, y_neg] if x_pos.between?(0,7) && y_neg.between?(0,7)
    end
    moves
  end

  def straight_moves
    moves = []
    8.times do |i|
      moves << [x, i] unless i == y
      moves << [i, y] unless i == x
    end
    moves
  end
end

class Pawn < Piece
  attr_accessor :passant, :position

  def initialize(color, x, y)
    super(color)
    @position = [x, y]
    @passant = position
  end

  def potential_moves
    moves = [[x, y + 1]] if color == 'white' && y < 7
    moves = [[x, y - 1]] if color == 'black' && y > 0
    moves << [x, y + 2] if color == 'white' && passant? 
    moves << [x, y - 2] if color == 'black' && passant?
    moves << [x + 1, y + 1] if color == 'white' && x < 7
    moves << [x - 1, y + 1] if color == 'white' && x > 0
    moves << [x + 1, y - 1] if color == 'black' && x < 7
    moves << [x - 1, y - 1] if color == 'black' && x > 0
    moves 
  end

  def passant?
    passant == position
  end

  def promotion?
    return y == 7 if color == 'white'
    return y == 0 if color == 'black'
  end

  def to_s
    return color == "white" ? "P" : "P".colorize(:red)
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
    return color == "white" ? "R" : "R".colorize(:red)
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
    return color == "white" ? "B" : "B".colorize(:red)
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
    return color == "white" ? "Q" : "Q".colorize(:red)
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
    return color == "white" ? "K" : "K".colorize(:red)
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
    return color == "white" ? "N" : "N".colorize(:red)
  end
end
