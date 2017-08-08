require 'board'
require 'spec_helper'

describe Board do
  describe "#is_mate?" do
    before(:each) do
      Player.count = 0
      @board = Board.new
      @board.create_players("player1", "player2")
    end
    context "returns true if King is checkmated" do
      it "returns true for checkmate with a rook" do
        @board.player1.set = [King.new('white', 0), Rook.new('white', 7, 0)]
        @board.player1.set[0].position = [5, 4]
        @board.player2.set = [King.new('black', 7)]
        @board.player2.set[0].position = [7, 4]
        @board.update_board

        expect(@board.is_mate?).to be true
      end

      it "returns true for fool's mate" do
        @board.update_board
        @board.player1.set[13].position = [5, 2]
        @board.player1.set[14].position = [6, 3]
        @board.player2.set[12].position = [4, 4]
        @board.player2.set[1].position = [7, 3]
        @board.update_board
        @board.current_player, @board.other_player = @board.other_player, @board.current_player
        expect(@board.is_mate?).to be true
      end
    end

    context "returns false if King is not checkmated" do
      it "returns false if king can escape mate" do
        @board.player1.set = [King.new('white', 0), Rook.new('white', 7, 0)]
        @board.player1.set[0].position = [5, 3]
        @board.player2.set = [King.new('black', 7)]
        @board.player2.set[0].position = [7, 4]
        @board.update_board

        expect(@board.is_mate?).to be true
      end

      it "returns false if king can take to avoid mate" do
        @board.player1.set = [King.new('white', 0), Rook.new('white', 7, 0)]
        @board.player1.set[0].position = [6, 4]
        @board.player2.set = [King.new('black', 7)]
        @board.player2.set[0].position = [7, 4]
        @board.update_board

        expect(@board.is_mate?).to be true
      end

      it "returns false for broken fool's mate" do
        @board.update_board
        @board.player1.set[13].position = [5, 2]
        @board.player1.set[14].position = [6, 3]
        @board.player1.set.pop
        @board.player2.set[12].position = [4, 4]
        @board.player2.set[1].position = [7, 3]
        @board.update_board
        @board.current_player, @board.other_player = @board.other_player, @board.current_player

        expect(@board.is_mate?).to be false
      end
    end
  end
end