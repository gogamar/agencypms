class CleaningPlan < ApplicationRecord
  belongs_to :cleaning_company
  has_many :cleaning_schedules, dependent: :destroy

  def create_schedules_for_bookings
    @office = self.cleaning_company.office
    # priority: 1. checkout and checkin on the same day - same day cleaning
    # priority: 2. checkout and checkin more than rate minimum days apart - next day possible if 48 hours notice before booking
    # priority: 3. checkout and checkin less than rate minimum days apart - next day cleaning possible

    # need to enter cleaning_hours for each vrental based on number of bedrooms
    # need to enter cleaning company to the vrentals that we want to set a preference to
    # if a cleaning company has 2 people, and the cleaning hours on vrental is 2, cleaning schedule should be 1 hour
    # After the number of people * max number of hours in between checkout and checkin is exhausted for the day, move to the second cleaning company

    # For each company show the Cleaning Plans and let the user edit them if necessary (then update the rest..) and download them in pdf

    @office.bookings.where('checkout >= ? AND checkout <= ?', self.from, self.to).find_each do |booking|
      CleaningSchedule.create(
        cleaning_plan: self,
        cleaning_company: self.cleaning_company,
        cleaning_start: booking.checkout,
        cleaning_end: booking.checkout + 2.hours
      )
    end
  end
end
