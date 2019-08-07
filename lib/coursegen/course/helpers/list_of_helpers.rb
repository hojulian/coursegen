module ListOfHelpers

  # source: name of a section as a string
  # rows: array with one or more of:
  #     "page"
  #     "subsection"
  # cols: array with one or more of:
  #     :date
  #     :number
  #     :title
  #     :homeworks
  #     :assigned

  def list_of(source:, rows:, cols:, subsections: [], items:)
    markup_adaptor = BootstrapMarkup.new
    data_adaptor = DataAdaptor.new(source)
    lecture_table_builder = ListOf.new(markup_adaptor, data_adaptor, rows, cols, subsections, items)
    lecture_table_builder.render
  end
end
