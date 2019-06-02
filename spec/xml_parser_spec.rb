require 'parse_xml'

RSpec.describe 'ParseXml' do
  def parses!(to_parse, expected)
    actual = ParseXml.call to_parse
    expect(actual).to eq expected
  end

  def tag(name, *children)
    ParseXml::Tag.new(name: name, children: children)
  end

  it 'parses <$WORD></$WORD> into a tag for $WORD' do
    parses! '<a></a>', tag('a')
    parses! '<abc></abc>', tag('abc')
  end

  it 'parses nested tags' do
    parses! '<a><b></b></a>', tag('a', tag('b'))
  end

  it 'inserts an implicit root over adjacent tags' do
    parses! '<a></a><b></b>', tag(':root', tag('a'), tag('b'))
  end

  it 'ignores whitespace between the tagname and the brackets' do
    parses! '< a >< / a >', tag('a')
  end
end
