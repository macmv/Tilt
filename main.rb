#! /usr/local/bin/ruby

require "gosu"
require "yaml"
require "trollop"

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
		@grid[4][4] = Wall.new 4, 4
		@movable_blocks = [GreenBlock.new(2, 4)]
		@plus_x = 0
		@plus_y = 0
	end

	def update
		@movable_blocks.each do |block|
			block.move self, @plus_x, @plus_y
		end
	end

	def draw
		@grid.each do |row|
			row.each do |item|
				item.draw
			end
		end
		@movable_blocks.each do |item|
			item.draw
		end
	end

	def tilt_up
		@plus_x = 0
		@plus_y = -0.125
	end

	def tilt_down
		@plus_x = 0
		@plus_y = 0.125
	end

	def tilt_right
		@plus_x = 0.125
		@plus_y = 0
	end

	def tilt_left
		@plus_x = -0.125
		@plus_y = 0
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
		if !@hit_wall
			@x += plus_x
			@x -= plus_x if @x < 0 || @x > 4
			if board.grid[@y + 0][@x + 0].class == Wall
				8.times { @x -= plus_x }
				@hit_wall = true
			end
			@y += plus_y
			@y -= plus_y if @y < 0 || @y > 4
			if board.grid[@y + 0][@x + 0].class == Wall
				8.times { @x -= plus_x }
				@hit_wall = true
			end
		end
		if @old_plus_x != plus_x || @old_plus_y != plus_y
			@hit_wall = false
		end
		@old_plus_x = plus_x
		@old_plus_y = plus_y
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
		@board.update
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