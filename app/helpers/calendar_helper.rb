module CalendarHelper
  def booking_line_style(checkin, checkout, current_date)
    start_date = [checkin, current_date].max
    end_date = [checkout, current_date].min

    position = (start_date - checkin).to_i * 100 / (checkout - checkin).to_i
    width = (end_date - start_date).to_i * 100 / (checkout - checkin).to_i

    "left: #{position}%; width: #{width}%;"
  end
end
