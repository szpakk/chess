require_relative 'piece'
require_relative 'player'

class Board
  attr_accessor :board, :player1, :player2, :current_player, :other_player, :current_piece

  def create_board
    board = []
    8.times { board << [" ", " ", " ", " ", " ", " ", " ", " "] }
    board
  end

  def draw_board
    puts "  a b c d e f g h"
    board.reverse.each_with_index do |row, index|
      puts "#{8 - index} #{row[0]} #{row[1]} #{row[2]} #{row[3]} #{row[4]} #{row[5]} #{row[6]} #{row[7]} #{8 - index}"
    end
    puts "  a b c d e f g h"
  end

  def is_free?(x,y)
    return board[y][x] == " " ? true : false
  end

  def create_players(name1, name2)
    @player1 = Player.new(name1)
    @player2 = Player.new(name2)
    @current_player = @player1
    @other_player = @player2
  end

  def update_board
    @board = create_board
    player1.set.each { |piece| board[piece.y][piece.x] = piece }
    player2.set.each { |piece| board[piece.y][piece.x] = piece }
  end

  def choose_piece(x, y)
    @current_piece = board[y][x]
  end

  def is_move_possible?(piece, x, y)
    return false unless piece.potential_moves.include?([x, y]) && (is_free?(x, y) || board[y][x].color != piece.color)
    return true if piece.is_a?(Knight)
    return true if piece.is_a?(King) && !is_move_checked?(x,y)
    return is_vertical_possible?(piece, y) || is_horizontal_possible?(piece, x) if piece.is_a?(Rook)
    return is_diagonal_possible?(piece, x, y) if piece.is_a?(Bishop)
    return is_vertical_possible?(piece, y) || is_horizontal_possible?(piece, x) || is_diagonal_possible?(piece, x, y) if piece.is_a?(Queen)
    if piece.is_a?(Pawn)
      return true if x == piece.x && is_free?(x, y) && is_vertical_possible?(piece, y)
      return true unless is_free?(x, y) || x == piece.x
      false
    end
  end

  def is_vertical_possible?(piece, y)
    if piece.y < y
      (piece.y + 1).upto(y - 1) { |i| return false unless is_free?(i, piece.x) }
      true
    elsif piece.y > y
      (piece.y - 1).downto(y + 1) { |i| return false unless is_free?(i, piece.x) }
      true
    else
      false
    end    
  end

  def is_horizontal_possible?(piece, x)
    if piece.x < x
      (piece.x + 1).upto(x - 1) { |i| return false unless is_free?(piece.y, i) }
      true
    elsif piece.x > x
      (piece.x - 1).downto(x + 1) { |i| return false unless is_free?(piece.y, i) }
      true
    else
      false
    end    
  end

  def is_diagonal_possible?(piece, x, y)
      x_pos, y_pos = piece.x, piece.y
      iterations = (piece.x - x).abs - 1
      iterations.times do |i|
        x_pos = piece.x < x ? x_pos + 1 : x_pos - 1
        y_pos = piece.y < y ? y_pos + 1 : y_pos - 1
        return false unless is_free?(x_pos, y_pos)
      end
      true
  end

  def is_move_checked?(x,y)
    other_player.set.each { |piece| return true if is_move_possible?(piece, x, y)}
    false
  end

  def move(piece, x, y)
    if is_move_possible?(piece, x, y)
      other_player.set.delete(board[y][x]) unless is_free?(x, y)
      piece.position = [x, y]
    else
      false
    end
  end

  def is_check?
    current_player.set.each do |piece|
      return true if is_move_possible?(piece, other_player.king_x, other_player.king_y)
    end
    false
  end

  def is_mate?
    current_set_copy = current_player.set[0..-1]
    other_set_copy = other_player.set[0..-1]
    other_player.set.each do |piece|
      piece.potential_moves.each do |x, y|
        move(piece, x, y)
        update_board
        return false unless is_check?
        other_player.set = other_set_copy
        current_player.set = current_set_copy
        update_board
      end
    end
    true
  end
end
