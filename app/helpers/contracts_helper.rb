module ContractsHelper
  def sort_link_contract(column:, label:)
    if column == params[:column]
      link_to(label, list_contracts_path(column: column, direction: next_direction_contract))
    else
      link_to(label, list_contracts_path(column: column, direction: 'asc'))
    end
  end

  def next_direction_contract
    params[:direction] == 'asc' ? 'desc' : 'asc'
  end


  def sort_indicator_contract
    # tag.span(class: "sort sort-#{params[:direction]}")
    if params[:direction] == "asc"
      tag.i(class: "fas fa-fw fa-sort-up sort sort-asc")
    elsif params[:direction] == "desc"
      tag.i(class: "fas fa-fw fa-sort-down sort sort-desc")
    end
  end
end
