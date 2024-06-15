class GetAllBookingsJob < ApplicationJob
  queue_as :default

  def perform(office, to_date, job_id)
    begin
      puts "Importing bookings from Beds24 for #{office.name} to #{to_date}. The job id is #{job_id}"

      office.vrentals.each do |vrental|
        if vrental.prop_key.present?
          VrentalApiService.new(vrental).get_bookings_from_beds(nil, to_date)
        end
      end

      update_job_status(job_id, "completed")
    rescue => e
      update_job_status(job_id, "failed")
      puts "Error JOB importing bookings: #{e.message}"
      raise e
    end
  end

  private

  def update_job_status(job_id, status)
    JobRecord.find_by(id: job_id).update(status: status)
  end
end
