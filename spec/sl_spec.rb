require './soccer_league.rb'

describe SoccerLeague do
  describe '#points_wording' do
    it 'shows the singular form when the argument is 1' do
      expect(subject.send(:points_wording, 1)).to eq('1 pt')
    end

    it 'shows the plural form when the argument is 0' do
      expect(subject.send(:points_wording, 0)).to eq('0 pts')
    end

    it 'shows the plural form when the argument is 2' do
      expect(subject.send(:points_wording, 2)).to eq('2 pts')
    end
  end

  describe '#record_game_result' do
    it 'processes a single first team win correctly' do
      expect(subject).to receive(:record_win).with(
        won: 'Schalke 04', lost: 'Tigers 11'
      )
      subject.send(:record_game_result, 'Schalke 04 5, Tigers 11 3')
    end

    it 'processes a single first team loss correctly' do
      expect(subject).to receive(:record_win).with(
        won: 'Tigers 54', lost: 'Lions 17'
      )
      subject.send(:record_game_result, 'Lions 17 0, Tigers 54 2')
    end

    it 'processes a draw correctly' do
      expect(subject).to receive(:record_draw).with('Lions').once
      expect(subject).to receive(:record_draw).with('Tigers').once
      subject.send(:record_game_result, 'Lions 3, Tigers 3')
    end
  end

  describe '#process_games' do
    it 'keeps the standings hash current' do
      subject.process_games './spec/test_results.txt'
      expect(subject.standings.size).to eq(4)
      expect(subject.standings['Lions']).to eq(9)
      expect(subject.standings['Tigers']).to eq(4)
      expect(subject.standings['Leopards']).to eq(4)
      expect(subject.standings['House Cats']).to eq(0)
    end

    it 'processes the default input file when no arguments passed' do
      expect(subject).to receive(:read_data).with('./grmgarber/sample-input.txt')
      subject.process_games
    end

    it 'works OK when the data file is missing or another IO exception' do
      expect(subject).to receive(:puts).with(
        'Error processing input data file ./missing.txt: No such file or directory @ rb_sysopen - ./missing.txt'
      )
      expect { subject.process_games './missing.txt' }.to_not raise_error
    end
  end

  describe '#display_team_standings' do
    let(:standings) do
      { 'Lions' => 9, 'Tigers' => 4, 'Leopards' => 4, 'House Cats' => 0 }
    end

    it 'prints out the standings correctly' do
      subject.instance_variable_set('@standings', standings)
      expect(subject).to receive(:puts).with('1. Lions, 9 pts')
      expect(subject).to receive(:puts).with('2. Tigers, 4 pts')
      expect(subject).to receive(:puts).with('2. Leopards, 4 pts')
      expect(subject).to receive(:puts).with('4. House Cats, 0 pts')

      subject.send(:display_standings)
    end
  end

  describe '#read_data' do
    it 'invokes record_game_result as many times as there are lines in the input' do
      expect(subject).to receive(:record_game_result).exactly(6).times
      subject.send(:read_data, './spec/test_results.txt')
    end
  end
end

