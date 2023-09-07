module VrentalsHelper
  def sort_link(column:, label:)
    if column == params[:column]
      link_to(label, list_vrentals_path(column: column, direction: next_direction))
    else
      link_to(label, list_vrentals_path(column: column, direction: 'asc'))
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

  def rental_balance_message(vrental)
    total_earnings = vrental.total_earnings

    if vrental.total_bookings > total_earnings
      "(a favor d'agència)"
    elsif vrental.total_bookings < total_earnings
      "(a favor del propietari)"
    else
      nil
    end
  end

end
