require 'sinatra'
require 'sinatra/partial'
require 'rack-flash'

require_relative './lib/sudoku'
require_relative './lib/cell'
require_relative './helpers/application'

enable :sessions
set :session_secret, "I'm the not-so-secret secret key."
use Rack::Flash
set :partial_template_engine, :erb


#################################################################
def puzzle(sudoku)
	sudoku.each_with_index.map do |element, index|
		random_index =  [*0..81].sample(rand(25..50))
		if random_index.include? (index)
			element = 0
		else
			element		
		end
	end
end

def random_sudoku
	seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
	sudoku = Sudoku.new(seed.join)
	sudoku.solve!
	sudoku.to_s.chars
end

def generate_new_puzzle_if_necessary
	return if session[:current_solution]
		sudoku = random_sudoku
		session[:solution] = sudoku
		session[:puzzle] = puzzle(sudoku)
		session[:current_solution] = session[:puzzle]
end

def prepare_to_check_solution
	@check_solution = session[:check_solution]
	if @check_solution
		flash[:notice] = "Incorrect values are highlighted in <font style='BACKGROUND-COLOR: #9CC1CC'>this yucky colour</font>."
	end
	session[:check_solution] = nil
end

def box_order_to_row_order(cells)
	boxes = cells.each_slice(9).to_a
	(0..8).to_a.inject([]) do |memo, i|
		first_box_index = i / 3*3
		three_boxes = boxes[first_box_index, 3]
		three_rows_of_three = three_boxes.map do |box|
			row_number_in_a_box = i % 3
			first_cell_in_the_row_index = row_number_in_a_box *3
			box[first_cell_in_the_row_index, 3]
		end
	memo += three_rows_of_three.flatten
	end
end
#################################################################


#################################################################
get '/' do
	prepare_to_check_solution
	generate_new_puzzle_if_necessary

	@current_solution = session[:current_solution] || session[:puzzle]
	@solution = session[:solution]
	@puzzle = session[:puzzle]

  erb :index
end

post '/' do
	cells = box_order_to_row_order(params["cell"])
	session[:current_solution] = cells.map { |value| value.to_i }.join
	session[:check_solution] = true
	redirect to('/')
end

post '/save' do
	session[:check_solution] = false
	redirect to('/')
end

post '/newsudoku' do
	session.clear
	redirect to('/')
end


get '/solution' do
	@current_solution = session[:solution]
	@solution = session[:solution]
	@puzzle = session[:solution] 
	erb :index
	# erb :solution
end
#################################################################
