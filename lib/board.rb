require_relative 'piece'
require_relative 'player'
require 'colorize'
require 'yaml'

class Board
  attr_accessor :board, :player1, :player2, :current_player, :other_player, :current_piece, :rescue_moves, :last_move, :passant

  def initialize
    @rescue_moves = []
    @passant = false
  end

  def create_board
    board = []
    even_line = ["   ".colorize(:background => :blue), "   ".colorize(:background => :light_blue),
                  "   ".colorize(:background => :blue), "   ".colorize(:background => :light_blue),
                  "   ".colorize(:background => :blue), "   ".colorize(:background => :light_blue),
                  "   ".colorize(:background => :blue), "   ".colorize(:background => :light_blue)]
    odd_line = even_line.reverse
    8.times { |i| i.even? ? board << even_line[0..-1] : board << odd_line[0..-1] }
    board
  end

  def draw_board
    puts "\n   a  b  c  d  e  f  g  h "
    board.reverse.each_with_index do |row, index|
      puts "#{8 - index}|#{row[0]}#{row[1]}#{row[2]}#{row[3]}#{row[4]}#{row[5]}#{row[6]}#{row[7]}|#{8 - index}"
    end
    puts "   a  b  c  d  e  f  g  h "
  end

  def is_free?(x,y)
    return !board[y][x].is_a?(Piece)
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

  def log_last_move(piece, x, y)
    @last_move = {:piece => piece, :x => x, :y => y }
  end

  def is_move_possible?(piece, x, y)
    passant = false
    return false unless rescue_moves.empty? || rescue_moves.include?([x, y])
    return false unless piece.potential_moves.include?([x, y]) && (is_free?(x, y) || board[y][x].color != piece.color)
    return true if piece.is_a?(Knight)
    return true if piece.is_a?(King) && !is_move_checked?(x,y)
    return is_vertical_possible?(piece, y) || is_horizontal_possible?(piece, x) if piece.is_a?(Rook)
    return is_diagonal_possible?(piece, x, y) if piece.is_a?(Bishop)
    return is_vertical_possible?(piece, y) || is_horizontal_possible?(piece, x) || is_diagonal_possible?(piece, x, y) if piece.is_a?(Queen)
    if piece.is_a?(Pawn)
      if x == piece.x && is_free?(x, y) && is_vertical_possible?(piece, y)
        last_move = log_last_move(piece, x, y) if (piece.y - y).abs == 2
        return true 
      elsif !self.last_move.nil? && self.last_move[:y] == piece.y && (piece.x - self.last_move[:x]).abs == 1 && is_free?(x, y)
        self.passant = true
        return true
      elsif !is_free?(x, y) && x != piece.x
        return true
      else
        return false
     end
    end
  end

  def is_vertical_possible?(piece, y)
    if piece.y < y
      (piece.y + 1).upto(y - 1) { |i| return false unless is_free?(piece.x, i) }
      true
    elsif piece.y > y
      (piece.y - 1).downto(y + 1) { |i| return false unless is_free?(piece.x, i) }
      true
    else
      false
    end    
  end

  def is_horizontal_possible?(piece, x)
    if piece.x < x
      (piece.x + 1).upto(x - 1) { |i| return false unless is_free?(i, piece.y) }
      true
    elsif piece.x > x
      (piece.x - 1).downto(x + 1) { |i| return false unless is_free?(i, piece.y) }
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
    other_player.set.each do |piece|
      return true if (!piece.is_a?(King) && is_move_possible?(piece, x, y)) || (piece.is_a?(King) && piece.potential_moves.include?([x, y]))
    end
    false
  end

  def possible_castling?(piece, x, y)
    piece.is_a?(Rook) && piece.first_move? &&
      ((piece.x == 3 && x == 3 && !is_move_checked?(2, y)) || (piece.x == 5 && x == 5 && !is_move_checked?(6, y)))
  end

  def castling(side)
    print "Do you want to perform castling? Type 'y' or 'n': "
    answer = gets.chomp
    until answer.downcase == 'y' || answer.downcase == 'n'
      print "Invalid command. Type 'y' or 'n': "
      answer = gets.chomp
    end
    if answer == 'y'
      y = current_player.king_y
      x = current_player.king_x
      new_x = side == 3 ? 2 : 6
      king = board[y][x]
      king.position = [new_x, y]
      king.first_move = false
    end
  end

  def promote_pawn(piece)
    player = player1.color == piece.color ? player1 : player2
    player.set << Queen.new(piece.color, piece.y)
    player.set[-1].position = [piece.x, piece.y]
    player.set.delete(board[piece.y][piece.x])
  end

  def move(piece, x, y)
    if is_move_possible?(piece, x, y)
      player1.set.delete(board[y][x]) || player2.set.delete(board[y][x]) unless is_free?(x, y)
      (player1.set.delete(board[last_move[:y]][last_move[:x]]) || player2.set.delete(board[last_move[:y]][last_move[:x]])) && self.passant = false if self.passant
      piece.position = [x, y]
      update_board
      if possible_castling?(piece, x, y)
        castling(x)
      end
      piece.first_move = false if piece.is_a?(Rook) || piece.is_a?(King)
      promote_pawn(piece) if piece.is_a?(Pawn) && piece.promotion?
      true
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
    current_set_copy = YAML::dump(current_player.set)
    other_set_copy = YAML::dump(other_player.set)
    mate = true
    other_player.set.size.times do |i|
      other_player.set[i].potential_moves.each do |x, y|
        move(other_player.set[i], x, y)
        update_board
        unless is_check?
          rescue_moves << [x, y]
          mate = false
        end
        other_player.set = YAML::load(other_set_copy)
        current_player.set = YAML::load(current_set_copy)
        update_board
      end
    end
    mate
  end

  def start_game
    puts "Welcome to the Chess Game!"
    puts "Type:\n  'start' to start new game\n  'load' to load saved game\n  'quit' to exit"
    commands = ['start', 'load', 'quit']
    print ">> "
    command = gets.chomp
    until commands.include?(command.downcase)
      print "Invalid command. Try again: "
      command = gets.chomp
    end
    new_game if command.downcase == 'start'
    load_game if command.downcase == 'load'
    exit if command.downcase == 'quit'
  end

  def new_game
    puts "Enter name of the first player (white set): "
    p1_name = gets.chomp
    puts "Enter name of the second player (black set): "
    p2_name = gets.chomp
    create_players(p1_name, p2_name)

    game_controller
  end

  def parse_command
    command = gets.chomp
    until command.downcase == 'quit' || command.downcase == 'save' || command.downcase =~ /^[a-h][1-8]$/
      print "Invalid command! Try again: "
      command = gets.chomp
    end
    command.downcase
  end

  def parse_piece
    until current_piece.is_a?(Piece) && current_piece.color == current_player.color
      print "Invalid piece. Try again or type 'back' to return: "
      command = gets.chomp
      return game_controller if command.downcase == 'back'
      x, y = parse_choice(command.downcase)
      choose_piece(x, y)
    end
  end

  def parse_move
    print "Choose move or type 'back' to choose other piece: "
    move_choice = gets.chomp
    return game_controller if move_choice.downcase == 'back'
    x, y = parse_choice(move_choice.downcase)
    until move_choice.downcase =~ /^[a-h][1-8]$/ && move(current_piece, x, y) != false
      print "Invalid move! Try again or type 'back' to return: "
      move_choice = gets.chomp
      return game_controller if move_choice.downcase == 'back'
      x, y = parse_choice(move_choice.downcase)
    end
  end

  def game_controller
    create_board
    update_board
    draw_board
    puts ""    
    loop do
      puts "It's #{current_player.name}'s turn."
      print "Choose piece, type 'save' to save game or 'quit' to exit: "
      command = parse_command
      if command == 'save'
        begin
          save_game
          puts "Game saved successfully!"
        rescue
          puts "Unable to save the game!"
        end
        return game_controller
      end
      exit if command == 'quit'
      x, y = parse_choice(command)
      choose_piece(x, y)
      parse_piece
      parse_move
      update_board
      draw_board
      rescue_moves = []
      print "\nCheck" if is_check?
      if is_mate?
        puts "mate!"
        exit
      end 
      puts is_check? ? "!" : ""
      rescue_moves = [] unless is_check?
      self.last_move = nil unless !last_move.nil? && last_move[:piece].color ==  current_player.color
      self.current_player, self.other_player = self.other_player, self.current_player
    end
  end

  def parse_choice(position)
    x = position[0].ord - 97
    y = position[1].to_i - 1
    [x, y]
  end

  def save_game
    Dir.mkdir('sav') unless Dir.exist?('sav')
    save_file = File.open('sav/save.yaml', "w")
    yaml = YAML::dump({
      :player1 => @player1,
      :player2 => @player2,
      :current_player => @current_player,
      :other_player => @other_player,
      :rescue_moves => @rescue_moves,
      :last_move => @last_move,
      :passant => @passant
    })
    save_file << yaml
    save_file.close
  end

  def load_game
    if File.exist?("sav/save.yaml")
      data = File.read("sav/save.yaml")
      data = YAML::load(data)
    else
      puts "There are no saves. Starting new game"
      return new_game
    end
    @player1 = data[:player1]
    @player2 = data[:player2]
    @current_player = data[:current_player]
    @other_player = data[:other_player]
    @rescue_moves = data[:rescue_moves]
    @last_move = data[:last_move]
    @passant = data[:passant]
    game_controller
  end
end
