require 'strscan'

class ParseXml
  class Tag
    def initialize(name:, children:)
      @name = name
      @children = children
    end

    attr_reader :name, :children

    def ==(tag)
      name == tag.name && children == tag.children
    rescue NoMethodError
      return false
    end
  end

  def self.call(to_parse)
    new(tokenize to_parse).call
  end

  def self.tokenize(to_parse)
    scanner = StringScanner.new(to_parse)
    tokens  = []
    chars   = "<>\"'=\\/"
    regex   = /[#{chars}]|\s+|\w+|[^#{chars}\s\w]+/m
    tokens << scanner.scan(regex) until scanner.eos?
    tokens
  end

  def initialize(tokens)
    @tokens = tokens
    @index = 0
  end

  def call
    @parsed ||= parse
  end

  private

  def parse
    # puts "PARSING tokens = #{@tokens.inspect}"
    children = parse_tags
    if children.one?
      children.first
    else
      Tag.new name: ':root', children: children
    end
  end

  def parse_tags
    tags = []
    while (tag = parse_tag)
      tags << tag
    end
    tags
  end

  private def parse_tag
    # puts "PARSING TAG index=#{@index}"
    open do
      opt_whitespace
      expect '<'
      opt_whitespace
      name = expect /\A\w+\z/
      opt_whitespace
      expect '>'

      children = parse_tags

      opt_whitespace
      expect '<'
      opt_whitespace
      expect '/'
      opt_whitespace
      expect name
      opt_whitespace
      expect '>'

      Tag.new name: name, children: children
    end
  end

  def open
    index = @index
    # puts "OPEN index=#{index}"
    reason = catch :fail do
      result = yield
      # puts "OPEN SUCCEEDED #{index} => #{@index}"
      return result
    end
    # puts "OPEN FAILED #{index} => #{@index} (#{reason})"
    @index = index
    nil
  end

  def opt_whitespace
    @index += 1 if token &.match?(/\A\s+\z/)
  end

  def token
    @tokens[@index]
  end

  def expect(expected)
    actual = token()
    case expected
    when String
      throw :fail, "#{actual.inspect} != #{expected.inspect}" if actual != expected
    when Regexp
      throw :fail, "#{actual.inspect} !~ #{expected.inspect}" if actual !~ expected
    else
      raise "fixme: #{token.inspect}"
    end
    @index += 1
    actual
  end
end
