class BootstrapMarkup
  def initialize
    @str = ""
  end
  def table_begin
    @str << "<table class=\"table table-condensed\">"
  end

  def table_end
    @str << "</table>"
  end

  def headers_begin
    @str << "<thead><tr>"
  end

  def headers_end
    @str << "</tr></thead>"
  end

  def header_begin
    @str << "<th>"
  end

  def header_end
    @str << "</th>"
  end

  def header_content(str)
    @str << str
  end

  def row_begin
    @str << "<tr>"
  end

  def row_end
    @str << "</tr>"
  end

  def cell_begin
    @str << "<td>"
  end

  def cell_end
    @str << "</td>"
  end

  def bigcell_begin
    @str << "<td colspan=\"2\"><h5>"
  end

  def bigcell_end
    @str << "</h5></td>"
  end

  def cell_content(str)
    @str << str
  end

  def render
    @str
  end
end