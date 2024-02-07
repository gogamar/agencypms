module NewsHelper
  def build_search_query(params)
    search_query_parts1 = []
    search_query_parts1 << params[:param1] if params[:param1].present?
    search_query_parts1 << params[:param2] if params[:param2].present?
    if search_query_parts1.length > 1
      part1_string = "(#{search_query_parts1.join(' OR ')})"
    else
      part1_string = search_query_parts1.first
    end
    search_query_parts2 = []
    search_query_parts2 << params[:param3] if params[:param3].present?
    search_query_parts2 << params[:param4] if params[:param4].present?
    if search_query_parts2.length > 1
      part2_string = "(#{search_query_parts2.join(' OR ')})"
    else
      part2_string = search_query_parts2.first
    end
    search_query = part1_string
    search_query += " AND #{part2_string}" if part2_string.present?

    return search_query
  end
end
