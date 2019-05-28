class History
  attr_accessor :human_moves, :computer_moves, :winner

  def initialize
    @turns = []
    @human_moves = []
    @computer_moves = []
    @winner = []
  end

  def add_turn!(number)
    @turns << number
  end

  def add_moves!(human, computer)
    @human_moves << human.value
    @computer_moves << computer.value
  end

  def add_winner!(name)
    @winner << name
  end

  def show_history(len1, len2)
    turns.length.times do |idx|
      puts "#{turns[idx].center(5)}#{human_moves[idx].center(len1 + 12)}"\
      "#{computer_moves[idx].ljust(10)}#{winner[idx].rjust(len2 + 2)}"
    end
  end

  private

  def turns
    @turns.map(&:to_s)
  end
end

class Move
  attr_reader :value

  VALUES = { 'r' => 'rock',
             'p' => 'paper',
             's' => 'scissors',
             'l' => 'lizard',
             'k' => 'spock' }

  WINNING_PIECES = { 'rock' => ['scissors', 'lizard'],
                     'paper' => ['rock', 'spock'],
                     'scissors' => ['paper', 'lizard'],
                     'lizard' => ['paper', 'spock'],
                     'spock' => ['scissors', 'rock'] }

  def initialize(value)
    @value = value
  end

  def >(other_move)
    WINNING_PIECES[value].include?(other_move.value)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
  end

  def set_score
    @score = 0
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp.strip
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n.capitalize
  end

  def choose
    choice = nil
    loop do
      puts "Please choose (r, p, s, l or k) for "\
      "(rock, paper, scissors, lizard or spock)"
      puts 'press (ctrl + c) to quit the game.'
      choice = gets.chomp.downcase
      break if Move::VALUES.keys.include?(choice)
      puts "Sorry, invalid chioce."
    end
    self.move = Move.new(Move::VALUES[choice])
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny'].sample
  end

  def choose
    self.move = case name
                when 'R2D2'
                  Move.new(r2d2s_choice)
                when 'Chappie'
                  Move.new(chappies_choice)
                when 'Hal'
                  Move.new(hals_choice)
                else
                  Move.new(Move::VALUES.values.sample)
                end
  end

  private

  def chappies_choice
    probability = rand(10)
    if probability > 3
      ['paper', 'rock'].sample
    elsif probability == 0
      'spock'
    else
      ['paper', 'lizard'].sample
    end
  end

  def r2d2s_choice
    ['rock', 'spock'].sample
  end

  def hals_choice
    probability = rand(10)
    if probability > 2
      ['scissors', 'lizard'].sample
    elsif probability == 2
      'spock'
    else
      'rock'
    end
  end
end

# Game Orchestration Engine
class RPSGame
  def initialize
    clear_screen
    @human = Human.new
  end

  def play
    clear_screen
    display_welcome_message

    outer_game_loop
    display_goodbye_message

    sleep(2)
    clear_screen
  end

  private

  attr_accessor :human, :computer, :rounds, :history

  def challengers_introduction
    puts "#{computer.name} is your challenger."
  end

  def display_game_history
    len1 = human.name.length
    len2 = computer.name.length
    puts "\nRound      #{human.name}      #{computer.name}       Winner"
    puts "------------------------------------#{'-' * (len1 * 1.5)}"
    history.show_history(len1, len2)
  end

  def outer_game_loop
    loop do
      @computer = Computer.new
      computer.set_score
      human.set_score
      @rounds = 0
      @history = History.new

      challengers_introduction
      inner_game_loop
      display_score

      display_grand_winner
      break unless play_again?
      clear_screen
    end
  end

  def inner_game_loop
    loop do
      @rounds += 1
      inner_loop_game_methods
      break if grand_winner?
    end
  end

  def inner_loop_game_methods
    history.add_turn!(rounds)
    display_score
    history.add_moves!(human.choose, computer.choose)
    clear_screen
    display_moves
    display_winner
    increment_score!
    add_winner_in_history
    display_game_history
  end

  def display_grand_winner
    if human.score == 10
      puts "#{human.name} is our Grand Master."
    else
      puts "#{computer.name} is our Grand Master."
    end
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard and Spock Game!"
    puts "Player winning first 10 games will be our Grand Winner."
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard and Spock. Good bye!"
  end

  def display_moves
    puts "#{human.name} choose #{human.move}."
    puts "#{computer.name} choose #{computer.move}."
  end

  def human_won?
    human.move > computer.move
  end

  def computer_won?
    computer.move > human.move
  end

  def display_score
    puts "\n\n#{' ' * human.name.length}      SCORE"
    puts "#{human.name}: #{human.score}    ||    "\
    "#{computer.name}: #{computer.score}"
    puts ''
  end

  def display_winner
    if human_won?
      puts "#{human.name} won!"
    elsif computer_won?
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def increment_score!
    if human_won?
      human.score += 1
    elsif computer_won?
      computer.score += 1
    end
  end

  def add_winner_in_history
    history.add_winner!(if human_won?
                          human.name
                        elsif computer_won?
                          computer.name
                        else
                          'Draw'
                        end)
  end

  def play_again?
    answer = ''
    loop do
      puts "Would you like to play again?"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts 'Sorry, must be y or n.'
    end

    return true if answer == 'y'
    return false if answer == 'n'
  end

  def grand_winner?
    human.score == 10 || computer.score == 10
  end

  def clear_screen
    system('cls') || system('clear')
  end
end

RPSGame.new.play
