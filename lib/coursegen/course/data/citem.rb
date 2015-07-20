require 'active_support/inflector'

#
# Coursegen Item decorates Nanoc Item
#
class CItem

  attr_reader :order, :section, :subsection, :subsection_citem, :title,
              :type, :identifier, :short_name, :status, :nitem, :css_class, :homework, :desc
  attr_accessor :lecture_number, :lecture_date

  # Callable with nitem=nil to create a mock
  def initialize nitem=nil, ident=nil, type=nil, order=nil
    if !nitem.nil?
      raise ArgumentError, "invalid CItem contruction" unless ident.nil?
      binding.pry
      @nitem = nitem
      defaults_from_nitem @nitem
      parse_identifier @nitem.identifier
    else
      raise ArgumentError, "invalid CItem contruction" unless nitem.nil?
      @nitem = nil
      @status = nil
      @type = type
      @identifier = ident
      @order = order
      @title = ident
      @style = nil
      parse_identifier(ident)
    end
  end

  def hidden?
    if @nitem.nil?
      false
    else
      @nitem[:status] == 'hidden' || %w(css min.css js png).include?(@nitem[:extension])
    end
  end

  def path
    @nitem.path
  end

  def is_lecture?
    !@lecture_date.nil?
  end

  def collapsed?
    @collapsed = @nitem[:collapsed].nil? ? true : @nitem[:collapsed]
  end

  def lecture_date_s
    @lecture_date.strftime('%a %b %-d') unless @lecture_date.nil?
  end

  def lecture_number_s
    "#{@section.singularize} #{@lecture_number.to_s}"
  end

  private

  def defaults_from_nitem(nitem)
    @type = @nitem[:type] || 'page'
    fail ArgumentError, 'Invalid page type' unless ["page", "subsection"].include? @type

    @subsection = nil
    @status = @nitem[:status]
    @order = @nitem[:order].to_i unless @nitem[:order].nil?
    @identifier = @nitem.identifier
    @section = @nitem[:section]
    @title = @nitem[:title]
    @css_class = @nitem[:css_class]
    @homework = @nitem[:homework]
    @desc = @nitem[:desc]
  end

  def parse_identifier ident
    parts = ident.to_s.split("/")
    @section ||= parts[2]
    parsed_title = parts[-1].match(/^((\d*)_)?([^\/]*)$/)
    raise RuntimeError, "Invalid item title" if parsed_title.nil?

    @order ||= parsed_title[2].to_i
    @short_name = parsed_title[3]
    @title ||= short_name
    if @type == "subsection"
      @subsection = "/#{parts[1..-1].join('/')}/"
    elsif @type == "page"
      @subsection = "/#{parts[1..-2].join('/')}/"
    end
  end
end
