module ClearScreen
  def clear_screen
    system('cls') || system('clear')
  end
end

class Participant
  include ClearScreen

  attr_accessor :cards

  def initialize
    set_name
    @cards = []
  end

  def stay
    puts "#{name} stays!"
    sleep(1)
    clear_screen
  end

  def black_jack?
    total == Game::BLACKJACK
  end

  def total
    total = cards.map do |card|
      if %w(J Q K).include?(card[1])
        10
      elsif card[1] == 'A'
        11
      else
        card[1].to_i
      end
    end.sum

    count_ace.times do
      break if total <= Game::BLACKJACK
      total -= 10
    end

    total
  end

  def not_busted_and_no_black_jack
    !busted? && !black_jack?
  end

  def >(other)
    total > other.total
  end

  def show_total
    puts "#{name}'s total is: #{total}."
  end

  def add_card(card)
    cards << card
  end

  def show_cards
    puts "----#{name}'s Cards----"
    cards.each do |card|
      puts "=> #{card[1]} of #{card[0]}"
    end
  end

  def busted?
    total > Game::BLACKJACK
  end

  def hit(card)
    puts "#{name} hits!"
    add_card(card)
  end

  def to_s
    name
  end

  private

  attr_reader :name

  def count_ace
    cards.map do |card|
      card[1]
    end.count('A')
  end
end

class Player < Participant
  def set_name
    name = ''
    loop do
      puts 'Please enter your name:'
      name = gets.chomp.strip
      break unless name.empty?
      puts 'Invalid name!'
    end
    @name = name.capitalize
  end
end

class Dealer < Participant
  def set_name
    @name = %w(R2D2 ROBOT HAL ARNOLD RAMBO).sample
  end

  def show_first_card
    puts "----#{name}'s card----"
    puts "=> #{cards[0][1]} of #{cards[0][0]}."
  end
end

class Deck
  SUITS = %w(Heart Diamond Spades Clubs)
  FACES = %w(2 3 4 5 6 7 8 9 10 J Q K A)

  def initialize
    @cards = pack_of_cards
  end

  def deal_one
    cards.shuffle.pop
  end

  private

  attr_reader :cards

  def pack_of_cards
    SUITS.clone.product(FACES.clone)
  end
end

class Game
  include ClearScreen

  BLACKJACK = 21

  def initialize
    clear_screen
    @player = Player.new
  end

  def start
    display_welcome_message
    game_loop
    display_goodbye_messsage
  end

  private

  attr_reader :player, :dealer
  attr_accessor :deck

  def game_loop
    loop do
      @dealer = Dealer.new
      initialize_deck_display_opponent_name_and_dealing_message
      deal_cards_and_show_flop

      player_turn

      if player.not_busted_and_no_black_jack
        dealer_turn
        show_both_players_card_and_total_with_result if !dealer.busted?
      end

      answer = ask_player_for_rematch
      break unless play_again?(answer)
      reset
    end
  end

  def initialize_deck_display_opponent_name_and_dealing_message
    display_opponents_name
    display_dealing_message
    initialize_new_deck
  end

  def deal_cards_and_show_flop
    deal_cards
    show_flop
  end

  def show_both_players_card_and_total_with_result
    show_both_players_card
    show_both_players_total
    show_result
  end

  def show_busted
    if player.busted?
      puts "#{player} is busted! #{dealer} wins!"
    elsif dealer.busted?
      clear_screen
      dealer.show_cards
      dealer.show_total
      puts ''
      puts "#{dealer} is busted! #{player} wins!"
    end
  end

  def reset
    clear_screen
    player.cards = []
    self.deck = Deck.new
  end

  def display_welcome_message
    clear_screen
    puts '***Welcome to Twenty-One Game.***'
    puts ''
  end

  def display_opponents_name
    puts "Your challenger is #{dealer}."
    puts ''
  end

  def display_dealing_message
    puts 'Please hit enter to start dealing the cards.'
    gets.chomp
    clear_screen

    puts "Dealing Cards to player's..."
    sleep(2)
    clear_screen
  end

  def show_both_players_total
    player.show_total
    dealer.show_total
  end

  def show_both_players_card
    player.show_cards
    puts ''
    dealer.show_cards
    puts ''
  end

  def show_result
    dealer_name = dealer
    puts ''
    if dealer.black_jack?
      puts "#{dealer_name} have blackjack! #{dealer_name} won!"
    elsif dealer > player
      puts "#{dealer_name} won!"
    elsif player > dealer
      puts "#{player} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_goodbye_messsage
    puts "\nThank you for playing Twenty-One Game."
    sleep(2)
    clear_screen
  end

  def initialize_new_deck
    @deck = Deck.new
  end

  def deal_cards
    2.times do
      player.add_card(deck.deal_one)
      dealer.add_card(deck.deal_one)
    end
  end

  def player_turn
    puts "#{player}'s turn."
    player_hit_or_stay
  end

  def player_hit_or_stay
    loop do
      if player.black_jack?
        display_player_cards_total_and_black_jack_message
        break
      end

      answer = ask_player_to_hit_or_stay

      break if answer == 's'

      player_hits_shows_cards_and_total

      if player.busted?
        show_busted
        break
      end

      dealer.show_first_card
      puts ''
    end
  end

  def display_player_cards_total_and_black_jack_message
    clear_screen
    player.show_cards
    player.show_total
    puts ''
    puts "#{player} you have blackjack! You won!"
  end

  def player_hits_shows_cards_and_total
    player.hit(deck.deal_one)
    puts ''
    player.show_cards
    player.show_total
    puts ''
  end

  def ask_player_to_hit_or_stay
    puts 'Would you like to (h)it or (s)tay?'
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if %w(h s).include?(answer)
      puts "Sorry, must enter 'h' or 's'."
    end
    clear_screen
    answer
  end

  def dealer_turn
    clear_screen
    puts "#{dealer}'s turn."

    sleep(1)
    dealer_hits

    return show_busted if dealer.busted?
    dealer.stay
  end

  def dealer_hits
    loop do
      break if dealer.total >= 17
      dealer.hit(deck.deal_one)
      sleep(1)
    end
  end

  def show_flop
    player.show_cards
    player.show_total
    puts ''
    dealer.show_first_card
    puts '.......?'
    puts ''
  end

  def ask_player_for_rematch
    answer = nil
    loop do
      puts "\nWould you like to play again?(y or n)"
      answer = gets.chomp
      break if %w(y n).include?(answer)
      puts 'Sorry, must enter y or n.'
    end

    answer
  end

  def play_again?(answer)
    answer == 'y'
  end
end

Game.new.start
