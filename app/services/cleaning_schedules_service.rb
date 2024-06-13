
class CleaningSchedulesService
  def initialize(office, from, to)
    @office = office
    @from = from
    @to = to
  end

  def update_cleaning_schedules
    office_bookings = @office.bookings.where('checkout >= ? AND checkout <= ?', @from, @to).order(:checkout)
    cleaning_companies = @office.cleaning_companies

    office_bookings.each do |booking|
      next_vrental_booking = booking.vrental.bookings.where('checkin >= ?', booking.checkout).order(:checkin).first
      cleaning_hours = booking.vrental.cleaning_hours
      # available_cleaning_company = find_available_cleaning_company(cleaning_companies, cleaning_hours)

      # just for testing
      available_cleaning_company = cleaning_companies.first

      next if available_cleaning_company.nil?

      # cleaning_start = determine_cleaning_start_time(booking, next_booking, cleaning_hours)
      # cleaning_end = cleaning_start + cleaning_hours.hours

      cleaning_date_info = determine_cleaning_date(booking, next_vrental_booking, cleaning_hours)

      cleaning_schedule = CleaningSchedule.find_or_initialize_by(booking: booking)
      unless cleaning_schedule.locked?
        cleaning_schedule.attributes = {
          priority: cleaning_date_info[:priority],
          cleaning_date: cleaning_date_info[:cleaning_date],
          next_booking_info: cleaning_date_info[:cleaning_date_reason],
          next_booking_date: cleaning_date_info[:next_booking_date],
          cleaning_company: available_cleaning_company
        }

        cleaning_schedule.save!
      end
    end

    # Adjust priority for future cleaning schedules
    future_cleaning_dates = CleaningSchedule.where('cleaning_date > ?', Date.today).distinct.pluck(:cleaning_date)
    future_cleaning_dates.each do |date|
      CleaningSchedule.where(cleaning_date: date).order(:priority).each_with_index do |future_schedule, index|
        future_schedule.update(priority: index + 1)
      end
    end
  end

  private

  def find_available_cleaning_company(cleaning_companies, cleaning_hours)
    cleaning_companies.each do |company|
      available_hours = company.available_hours_for_period(self.from, self.to)
      return company if available_hours >= cleaning_hours / company.number_of_cleaners
    end
    nil
  end

  def determine_cleaning_date(booking, next_vrental_booking, cleaning_hours)
    if next_vrental_booking
      if next_vrental_booking.checkin == booking.checkout
        # Priority 1: Same day cleaning
        return {cleaning_date: booking.checkout, priority: 1, cleaning_date_reason: "same_day_arrival", next_booking_date: next_vrental_booking.checkin}
      elsif (next_vrental_booking.checkin - booking.checkout).to_i >= minimum_days_for_rate
        # Priority 2: A new booking can still be made for the days in between, clean on the same day just in case
        return {cleaning_date: booking.checkout, priority: 2, cleaning_date_reason: "new_booking_possible", next_booking_date: next_vrental_booking.checkin}
      else
        # Priority 3: Checkout and checkin less than rate minimum days apart, so a new booking can't be made - clean on the next day
        return {cleaning_date: booking.checkout + 1.day, priority: 3, cleaning_date_reason: "new_booking_impossible", next_booking_date: next_vrental_booking.checkin}
      end
    else
      # No next booking, just do the cleaning on the same day
      return {cleaning_date: booking.checkout, priority: 2, cleaning_date_reason: "new_booking_possible", next_booking_date: next_vrental_booking.checkin}
    end
  end

  def minimum_days_for_rate
    # Define the minimum days for rate here or fetch it from the relevant configuration
    2
  end
end
