module VrentalsHelper

  def add_vragreement_links(vrental)
    latest_vragreement = vrental.vragreements.order(year: :desc).first if vrental.vragreements.present?
    content = content_tag(:small) do
      if vrental.rates.present? && vrental.rates.where("EXTRACT(YEAR FROM firstnight) IN (?, ?)", Date.today.year - 1, Date.today.year)
        if vrental.vragreements.where("year IN (?, ?)", Date.today.year - 1, Date.today.year ).present?
          concat(link_to "Contracte #{latest_vragreement.year}", vrental_vragreement_path(vrental, latest_vragreement), class: "text-primary")
          concat(tag(:br))
          concat(link_to "Afegir contracte #{latest_vragreement.year + 1}", copy_vrental_vragreement_path(vrental, latest_vragreement), class: "text-info")
        elsif vrental.rates.where("firstnight > ?", Date.today).present?
          future_date = vrental.rates.where("firstnight > ?", Date.today).order(:firstnight).first&.firstnight
          concat(link_to "Afegir contracte #{future_date.year}", new_vrental_vragreement_path(vrental, year: future_date.year), class: "text-info")
        else
          concat(link_to "Afegir tarifes", vrental_rates_path(vrental))
        end
      else
        concat(link_to "Afegir tarifes", vrental_rates_path(vrental))
      end
    end

    content
  end

  def sort_link(column:, label:)
    query_params = {}
    query_params[:filter_name] = params[:filter_name] if params[:filter_name].present?
    query_params[:filter_status] = params[:filter_status] if params[:filter_status].present?
    direction = column == params[:column] ? next_direction : 'asc'
    link_to(label, list_vrentals_path(column: column, direction: direction, **query_params))
  end

  def sort_link_earnings(column:, label:)
    if column == params[:column]
      link_to(label, list_earnings_vrentals_path(column: column, direction: next_direction))
    else
      link_to(label, list_earnings_vrentals_path(column: column, direction: 'asc'))
    end
  end

  def next_direction
    params[:direction] == 'asc' ? 'desc' : 'asc'
  end

  def sort_indicator
    if params[:direction] == "asc"
      tag.i(class: "fas fa-fw fa-sort-up sort sort-asc")
    elsif params[:direction] == "desc"
      tag.i(class: "fas fa-fw fa-sort-down sort sort-desc")
    end
  end

  def rental_balance_message(vrental = nil)
    total_earnings = vrental.nil? ? Earning.where.not(amount: nil).sum(:amount) : vrental.total_earnings

    total_bookings = vrental.nil? ? Booking.where.not(price: nil).sum(:price) : vrental.total_bookings

    if total_bookings > total_earnings
      "(a favor d'agència)"
    elsif total_bookings < total_earnings
      vrental.nil? ? "(a favor dels propietaris)" : "(a favor del propietari)"
    else
      nil
    end
  end

  def cut_off_time_options
    options = []
    (0..23).each do |hour|
        time = hour.to_s
        formatted_time = "#{hour.to_s.rjust(2, '0')}:00h"
        options << [formatted_time, time]
    end
    options
  end

  def check_in_out_time_options
    options = []
    (0..23).each do |hour|
      (0..45).step(15).each do |minute|
        decimal_time = (hour + (minute.to_f / 60)).round(2).to_s
        formatted_time = "#{hour.to_s.rjust(2, '0')}:#{minute.to_s.rjust(2, '0')}h"
        options << [formatted_time, decimal_time]
      end
    end
    options
  end
end
