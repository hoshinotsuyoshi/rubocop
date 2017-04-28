# frozen_string_literal: true

describe RuboCop::Cop::Style::SimpleIfClause do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for offending code' do
    inspect_source(cop, <<-END.strip_indent)
      if foo
        true
      else
        false
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Replace the if-clause with "!!foo".'])
  end

  it 'accepts' do
    inspect_source(cop, 'good_method')
    expect(cop.offenses).to be_empty
  end
end
