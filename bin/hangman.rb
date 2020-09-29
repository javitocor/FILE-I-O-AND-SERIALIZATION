require 'json'

class Board 
  def initialize(word)
    $length = word.length
    $underscore = Array.new($length, '__')
    $matches = Array.new($length, '*')
  end

  def panel 
    $matches.each{|x| print "|#{x}| " }
    puts ' '
    $underscore.each{|x| print " #{x} " }
    puts ' '
  end

  def update_panel(arr, letter) 
    arr.each{|x| $matches[x] = letter}
  end

  def panel_reset 
    $tries_played = 0
    $letters_matched = 0
  end
end

class Check 
  def check(letter) 
    if valid_input(letter)
      letters = $word.count(letter)
      if letters > 0 
        $let << letter
        puts "You have found #{letters} letters"
        arr = (0...$word.length).find_all { |i| $word[i,1] == letter }
        $new_board.update_panel(arr, letter)
        $letters_matched += letters
      else
        puts 'No matches found! Try again!'
      end
    else
      puts 'Please enter a valid letter'
    end
  end

  def valid_input(letter)
    letter.length === 1 ? (!letter.match(/\A[a-zA-Z]*\z/).nil? ? true : false) : false   
  end

  def checker_win 
    $letters_matched === $word.length
  end
end

class Reader

  def pick_random_line
    return 'No file found' if !File.exist? '5desk.txt'
    $word = File.readlines("5desk.txt").sample
    $word = $word.downcase
    $word
  end

end

class Choose
  def selector
      print "Do you want to be the coder? (y/n) : "
      $answer = gets.chomp.downcase
      if $answer == "y" 
          chooser
      else
          $new_random = Reader.new
          $new_random.pick_random_line 
      end 
  end
  def chooser
     print 'Choose a word: '
     $word = gets.chomp.downcase
     $word
  end
end

class SaveGame 
  def save_game(player)
    Dir.mkdir("games") unless Dir.exists?("games")
    json = {
      :word=> $word,
      :tries=> $tries_played,
      :matches=> $letters_matched,
      :player=> player,
      :letters=> $let      
    }
    filename = "games/Game_#{player}.json"
  
    File.open(filename,'w') do |file|
      file.write json.to_json
    end
  end

  def load_game(id) 
    data = File.open("./games/Game_#{id}.json", "r") {|file| file.read}
    json = JSON.parse(data)
    
    $word = json["word"] 
    $tries_played = json["tries"]
    $letters_matched = json["matches"] 
    @player1 = json["player"] 
    $let = json["letters"]
  end
end

class Game < Check
  def initialize(player1)
    @player1 = player1
    $let = []
    a = []
    puts "Welcome #{@player1}, let's play HangMan"
    puts "Try to find out the hidden word"
    sleep 1
  end

  def restart(repeat)
    $repeat == 'y' ? start : (p 'See you next time, Goodbye!')
  end

  def start     
    $newSave = SaveGame.new
    print "Do you want to load a previous game? (y/n)"
    $load = gets.chomp.downcase 
    if $load == "y"
      $newSave.load_game(1)
      $new_board = Board.new($word)
      a = $let.map(&:clone)
      a.each{|x| check(x)}
      $new_board.panel
      puts 'Continue playing your previous game!'
    else
      $new_selector = Choose.new
      $new_selector.selector
      puts "Let's start the game"
      sleep 1
      puts "You have up to 10 wrong tries"
      sleep 1
      puts "You only can enter one single letter uppercase or downcase"
      sleep 1
      puts "Symbols or numbers are not allowed"
      sleep 1
      puts "Good Luck!"
      sleep 1
      $new_board = Board.new($word)
      $new_board.panel_reset       
      $new_board.panel
    end     
    turn    
    print 'Would you like to play another game? (y/n) : '
    $repeat = gets.chomp
    restart($repeat)
  end

  private 

  def turn
    while $tries_played < 11  
      break if save == false
      puts ''
      print 'Choose Letter: '
      letter = gets.chomp
      check(letter.downcase)
      win
      break if checker_win || $tries_played == 10 
    end
  end

  def save 
    print "Do you want to save the game? (y/n)"
    $save = gets.chomp.downcase
    if $save == 'y'
      $newSave.save_game(@player1)
      print 'Do you want to continue playin? (y/n)'
      $continue = gets.chomp.downcase
      if $continue == 'y'
        puts "Keep playing!"
      else
        false
      end
    else
      puts "Keep playing!"
    end
  end

  def win
    if checker_win
      puts "#{$word}"
      puts "You found the hidden word #{@player1}! Congratulations!" 
    else
      $tries_played += 1
      $new_board.panel
      puts "Tries left: #{10 - $tries_played}" 
      if $tries_played === 10
        puts 'Bad luck! You could not find the word!'
        puts "The word was: #{$word}"
      end
    end 
  end
end