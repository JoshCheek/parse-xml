require 'strscan'

module ParseXml
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
    scanner = StringScanner.new to_parse
    # scanner.scan /\s*/
    scanner.scan /</
    name = scanner.scan /\w+/
    scanner.scan />/
    scanner.scan /<\//
    scanner.scan Regexp.new Regexp.escape name
    scanner.scan />/
    tag = Tag.new name: name, children: []
    tag
  end
end
