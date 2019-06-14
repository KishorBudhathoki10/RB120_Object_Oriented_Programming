class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts '-----+-----+-----'
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts '-----+-----+-----'
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/Abcsize

  def []=(index, marker)
    squares[index].marker = marker
  end

  def unmarked_keys
    squares.keys.select { |key| squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def won?(marker)
    WINNING_LINES.any? do |line|
      line.all? { |key| squares[key].marker == marker }
    end
  end

  def find_at_risk_square(line, marker)
    if squares.values_at(*line).map(&:marker).count(marker) == 2
      return squares.select do |k, v|
        line.include?(k) && v.marker == ' '
      end.keys.first
    end
    nil
  end

  def retrieve_at_risk_square(marker)
    square = nil
    WINNING_LINES.each do |line|
      square = find_at_risk_square(line, marker)

      break if square
    end

    square
  end

  private

  attr_reader :squares
end

class Score
  attr_reader :state

  def initialize
    @state = 0
  end

  def increment_by_one
    @state += 1
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_accessor :marker
  attr_reader :name

  def initialize(marker)
    @marker = marker
    set_name
  end

  def to_s
    name
  end
end

class Human < Player
  private

  def set_name
    n = nil
    loop do
      puts 'Please enter your name:'
      n = gets.chomp.strip
      break unless n.empty?
      puts 'Unvalid name.'
    end

    @name = n.capitalize
  end
end

class Computer < Player
  private

  def set_name
    @name = %w(Hal RDX Robo Boxer).sample
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  FIRST_TO_MOVE = 'choose'

  def initialize
    clear_screen
    @board = Board.new
    @human = Human.new(HUMAN_MARKER)
    @current_marker = FIRST_TO_MOVE
  end

  def play
    clear_screen
    display_welcome_message

    loop do
      @human_score = Score.new
      @computer_score = Score.new

      players_choose_marker

      @computer = Computer.new(COMPUTER_MARKER)
      challenger_message

      game_loop
      display_grand_result

      break unless play_again?
      display_play_again_message

      reset
    end

    display_goodbye_message
  end

  private

  attr_reader :board, :human, :computer, :human_score, :computer_score
  attr_accessor :current_marker

  def game_loop
    loop do
      select_who_moves_first if FIRST_TO_MOVE == 'choose'
      display_score
      display_board

      round_game

      display_result
      add_one_on_winners_score

      break if grand_winner?

      next_round_message
      reset
    end
  end

  def round_game
    loop do
      current_player_moves
      switch_current_player_marker

      break if someone_won? || board.full?

      display_score
      display_board
    end
  end

  def challenger_message
    puts "\n#{computer} is your next challenger."
    puts ''
  end

  def players_choose_marker
    mark = ''
    puts "Which marker would you like to use for this game? (X or O)"

    loop do
      mark = gets.chomp.upcase
      break if %w(X O).include?(mark)
      puts 'Must choose (X or O).'
    end

    HUMAN_MARKER.replace(mark)

    if HUMAN_MARKER == 'X'
      COMPUTER_MARKER.replace('O')
    else
      COMPUTER_MARKER.replace('X')
    end
  end

  def select_who_moves_first
    first_player = ''
    loop do
      puts "Decide who moves first. ('c' for computer, 'p' for you)"
      first_player = gets.chomp.downcase
      break if %w(c p).include?(first_player)
      puts "Must enter 'c' or 'p'."
    end

    @current_marker = first_player == 'p' ? HUMAN_MARKER : COMPUTER_MARKER
  end

  def add_one_on_winners_score
    if human_won?
      human_score.increment_by_one
    elsif computer_won?
      computer_score.increment_by_one
    end
  end

  def next_round_message
    puts 'Please hit enter to start next round.'
    gets.chomp
  end

  def grand_winner?
    human_grand_winner? || computer_grand_winner?
  end

  def human_grand_winner?
    human_score.state == 5
  end

  def computer_grand_winner?
    computer_score.state == 5
  end

  def display_grand_result
    if human_grand_winner?
      puts "#{human} you are our Grand Master!"
    else
      puts "#{computer} is Grand Master!"
    end
  end

  def display_score
    clear_screen
    puts "#{' ' * human.name.length}    Score"
    puts "#{human}: #{human_score.state}  ||  "\
    "#{computer}: #{computer_score.state}"
    puts ''
  end

  def reset
    clear_screen
    board.reset
    self.current_marker = FIRST_TO_MOVE
  end

  def current_player_moves
    if human_turn?
      human_moves
    else
      computer_moves
    end
  end

  def switch_current_player_marker
    self.current_marker = if human_turn?
                            COMPUTER_MARKER
                          else
                            HUMAN_MARKER
                          end
  end

  def human_turn?
    current_marker == HUMAN_MARKER
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end

  def someone_won?
    human_won? || computer_won?
  end

  def human_won?
    board.won?(HUMAN_MARKER)
  end

  def computer_won?
    board.won?(COMPUTER_MARKER)
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts 'Sorry, must be y or n'
    end

    answer == 'y'
  end

  def display_result
    display_score
    display_board

    if human_won?
      puts "#{human} won!"
    elsif computer_won?
      puts "#{computer} won!"
    else
      puts "It's a tie!"
    end
  end

  def clear_screen
    system('cls') || system('clear')
  end

  def computer_moves
    square = board.retrieve_at_risk_square(COMPUTER_MARKER)
    square = board.retrieve_at_risk_square(HUMAN_MARKER) if !square

    square = 5 if !square && board.unmarked_keys.include?(5)
    square = board.unmarked_keys.sample if !square

    board[square] = computer.marker
  end

  def human_moves
    puts "Choose a square between (#{joinor(board.unmarked_keys)}): "
    square = nil

    loop do
      square = gets.chomp
      if square.to_i.to_s == square
        square = square.to_i
        break if board.unmarked_keys.include?(square)
      end

      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def joinor(arr, punctuation=', ', word='or')
    case arr.size
    when 0 then ''
    when 0..2 then arr.join(" #{word}")
    else "#{arr[0..-2].join(punctuation)} #{word} #{arr[-1]}"
    end
  end

  def display_welcome_message
    puts "***Welcome to TicTacToe Game***"
    puts "\nAny player winning first 5 games is our Grand Winner."
    puts ''
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
    sleep(2)
    clear_screen
  end

  def display_board
    puts "#{human} you're a #{human.marker}."\
    " #{computer} is a #{computer.marker}."
    puts ''
    board.draw
    puts ''
  end
end

game = TTTGame.new
game.play
