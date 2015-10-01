#! /usr/local/bin/ruby

require "gosu"
require "yaml"
require "trollop"
require "colorize"

$opts = Trollop::options do
	opt :fullscreen, "Go fullscreen"
end

class NilClass

	def [](num)
		nil
	end

end

module Tilt

WIDTH = 800
HEIGHT = 600
BLOCKSIZE = 120

private

class Board

	attr_reader :grid

	def initialize(level_num)
		@grid = []
		(HEIGHT / BLOCKSIZE).times do |y|
			new_row = []
			(WIDTH / BLOCKSIZE - 1).times do |x|
				new_row.push Block.new(x, y)
			end
			@grid.push new_row
		end
		@grid[0][1] = Wall.new 1, 0
		@grid[4][2] = Wall.new 2, 4
		@movable_blocks = [GreenBlock.new(0, 0)]
		@plus_x = 0.125
		@plus_y = 0
		@all_movable_blocks_hit_wall = true
		@hole = Gosu::Image.new "images/hole.png"
	end

	def update
		@all_movable_blocks_hit_wall = true
		@movable_blocks.each do |block|
			hit_wall = block.move self, @plus_x, @plus_y
			if hit_wall == "won"
				return true
			end
			if !hit_wall
				puts "not hit_wall"
				@all_movable_blocks_hit_wall = false
			else
				puts "hit_wall"	
			end
		end
		false
	end

	def draw
		@grid.each do |row|
			row.each do |item|
				item.draw
			end
		end
		@hole.draw 2 * BLOCKSIZE + 100, 2 * BLOCKSIZE, 0
		@movable_blocks.each do |item|
			item.draw
		end
	end

	def tilt_up
		if @all_movable_blocks_hit_wall
			@plus_x = 0
			@plus_y = -0.125
		end
	end

	def tilt_down
		if @all_movable_blocks_hit_wall
			@plus_x = 0
			@plus_y = 0.125
		end
	end

	def tilt_right
		if @all_movable_blocks_hit_wall
			@plus_x = 0.125
			@plus_y = 0
		end
	end

	def tilt_left
		if @all_movable_blocks_hit_wall
			@plus_x = -0.125
			@plus_y = 0
		end
	end

end

class GreenBlock

	def initialize(x, y)
		@x = x.to_f
		@y = y.to_f
		@image = Gosu::Image.new "images/green block.png"
		@hit_wall = false
		@old_plus_x = 0
		@old_plus_y = 0
	end

	def move(board, plus_x, plus_y)
		if @x == 2.0 && @y == 2.0
			return "won"
		end
		if !@hit_wall
			@x += plus_x
			if @x < 0 || @x > 4
				@x -= plus_x
				@hit_wall = true
			end
			if board.grid[@y + 0][@x + 0].class == Wall
				if plus_x > 0
					8.times { @x -= plus_x }
				else
					@x -= plus_x
				end
				@hit_wall = true
			end
			if !@hit_wall
				@y += plus_y
				if @y < 0 || @y > 4
					@y -= plus_y
					@hit_wall = true
				end
				if board.grid[@y + 0][@x + 0].class == Wall
					if plus_y > 0
						8.times { @y -= plus_y }
					else
						@y -= plus_y
					end
					@hit_wall = true
				end
			end
		end
		if @old_plus_x != plus_x || @old_plus_y != plus_y
			@hit_wall = false
		end
		@old_plus_x = plus_x
		@old_plus_y = plus_y
		@hit_wall
	end

	def draw
		@image.draw @x * BLOCKSIZE + 100, @y * BLOCKSIZE, 0
	end
end

class Block

	def initialize(x, y)
		@x = x.to_f
		@y = y.to_f
		@image = Gosu::Image.new "images/block.png"
	end

	def draw
		@image.draw @x * BLOCKSIZE + 100, @y * BLOCKSIZE, 0
	end

end

class Wall < Block

	def initialize(x, y)
		super x, y
		@image = Gosu::Image.new "images/wall.png"
	end

end

public

class Screen < Gosu::Window

	def initialize
		super WIDTH, HEIGHT
		self.caption = "Tilt"
		@board = Board.new 0
	end

	def draw
		@board.draw
	end

	def update
		won = @board.update
		if won
			puts "YOU WON".green
			sleep 2
			exit
		end
		if Gosu::button_down?(Gosu::KbW) || Gosu::button_down?(Gosu::KbUp)
			@board.tilt_up
		end
		if Gosu::button_down?(Gosu::KbA) || Gosu::button_down?(Gosu::KbLeft)
			@board.tilt_left
		end
		if Gosu::button_down?(Gosu::KbS) || Gosu::button_down?(Gosu::KbDown)
			@board.tilt_down
		end
		if Gosu::button_down?(Gosu::KbD) || Gosu::button_down?(Gosu::KbRight)
			@board.tilt_right
		end
	end

	def needs_cursor?
		true
	end

end

end

Tilt::Screen.new.show