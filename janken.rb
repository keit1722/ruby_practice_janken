class Janken
  GAME_MODE_CHOICE = %w[easy hard].freeze
  GAME_COUNT_CHOICE = [1, 3, 5].freeze
  HAND_CHOICE = %i[g c p].freeze

  def initialize(player, cpu)
    @player = player
    @cpu = cpu
  end

  def start
    select_game_count(select_game_mode)
    @game.game_count.times { play_game }
    puts '結果'
    puts "#{@game.show_result(@player.result)}で#{@game.show_final_result(@player.result, @cpu.result)}"
  end

  def select_game_mode
    puts "どのモードにしますか？(press #{GAME_MODE_CHOICE.join(' or ')})"
    selected_game_mode = gets.chomp
    if GAME_MODE_CHOICE.include?(selected_game_mode)
      puts "#{selected_game_mode}モードを選択しました。"
      selected_game_mode
    else
      puts "#{GAME_MODE_CHOICE.join(' か ')}を選択してください。"
      select_game_mode
    end
  end

  def select_game_count(selected_game_mode)
    selected_game_mode = selected_game_mode
    puts "何本勝負？(press #{GAME_COUNT_CHOICE.join(' or ')})"
    selected_game_count = gets.chomp.to_i
    if GAME_COUNT_CHOICE.include?(selected_game_count)
      puts "#{selected_game_count}本勝負を選びました。"
      @game = Game.new(selected_game_mode, selected_game_count)
    else
      puts "#{GAME_COUNT_CHOICE.join(' か ')}を選択してください。"
      select_game_count(selected_game_mode)
    end
  end

  def play_game(start_with = 'じゃんけん')
    puts "#{@player.result.size + 1}本目"
    puts "#{start_with}…(press #{HAND_CHOICE.join(' or ')})"
    @player.hand = gets.chomp.to_sym

    if HAND_CHOICE.include?(@player.hand)
      @cpu.set_hand(HAND_CHOICE)
      puts "CPU...#{@cpu.hand}"
      puts "あなた...#{@player.hand}"
      result_per_game = @game.judge(@player.hand, @cpu.hand)
      if result_per_game.zero?
        play_game('あいこで')
      else
        @player.result << result_per_game
        @cpu.result << result_per_game * -1
        puts result_per_game == 1 ? '勝ち！' : '負け！'
        puts @game.show_result(@player.result)
      end
    else
      puts "#{HAND_CHOICE.join(' か ')}を選択してください。"
      play_game
    end
  end
end

class Game
  attr_accessor :game_mode, :game_count

  HAND = {
    g: {
      call: 'グー',
      against: {
        c: 1,
        p: -1,
      },
    },
    c: {
      call: 'チョキ',
      against: {
        g: -1,
        p: 1,
      },
    },
    p: {
      call: 'パー',
      against: {
        g: 1,
        c: -1,
      },
    },
  }.freeze

  def initialize(game_mode, game_count)
    @game_mode = game_mode
    @game_count = game_count
  end

  def judge(players_hand, cpus_hand)
    players_hand = players_hand
    cpus_hand = cpus_hand
    if win?(players_hand, cpus_hand)
      1
    elsif draw?(players_hand, cpus_hand)
      0
    else
      -1
    end
  end

  def win?(players_hand, cpus_hand)
    HAND[players_hand.to_sym][:against][cpus_hand.to_sym] == 1
  end

  def draw?(players_hand, cpus_hand)
    @game_mode == 'easy' && players_hand == cpus_hand
  end

  def show_result(players_result)
    win_count = players_result.select { |number| number == 1 }
    lose_count = players_result.select { |number| number == -1 }
    "#{win_count.sum}勝#{lose_count.sum * -1}敗"
  end

  def show_final_result(players_result, cpus_result)
    players_result.sum > cpus_result.sum ? 'あなたの勝ち！' : 'あなたの負け！'
  end
end

class Player
  attr_accessor :hand, :result

  def initialize
    @hand = nil
    @result = []
  end
end

class Cpu
  attr_accessor :hand, :result

  def initialize
    @result = []
  end

  def set_hand(hand_choice)
    @hand = hand_choice.sample
  end
end

janken = Janken.new(Player.new, Cpu.new)
janken.start
