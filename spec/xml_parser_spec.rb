require 'parse_xml'

RSpec.describe 'ParseXml' do
  def parses!(to_parse, expected)
    actual = ParseXml.call to_parse
    expect(actual).to eq expected
  end

  def tag(name, *children, **attributes)
    ParseXml::Tag.new(name: name, children: children, attributes: attributes)
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

  it 'parses attributes whose values are double quoted' do
    parses! '<a b="c" de="fg" empty=""></a>', tag('a', b: "c", de: "fg", empty: "")
  end

  it 'parses attributes whose values are single quoted' do
    parses! "<a b='c' de='fg' empty=''></a>", tag('a', b: "c", de: "fg", empty: "")
  end

  it 'parses attributes whose values aren\'t quoted' do
    skip 'got a meeting I have to go to'
    parses! "<a b=c de=fg></a>", tag('a', b: "c", de: "fg")
  end

  it 'closes off open tags when an parent tag is closed'
end
