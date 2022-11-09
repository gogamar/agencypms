module RealestatesHelper
  def sort_link(column:, label:)
    if column == params[:column]
      link_to(label, list_realestates_path(column: column, direction: next_direction))
    else
      link_to(label, list_realestates_path(column: column, direction: 'asc'))
    end
  end

  def next_direction
    params[:direction] == 'asc' ? 'desc' : 'asc'
  end


  def sort_indicator
    # tag.span(class: "sort sort-#{params[:direction]}")
    if params[:direction] == "asc"
      tag.i(class: "fas fa-fw fa-sort-up sort sort-asc")
    elsif params[:direction] == "desc"
      tag.i(class: "fas fa-fw fa-sort-down sort sort-desc")
    end
  end
end
