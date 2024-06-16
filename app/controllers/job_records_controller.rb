class JobRecordsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    job_record = JobRecord.new(job_record_params)

    if job_record.save
      render json: job_record, status: :created
    else
      render json: { errors: job_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    job_record = JobRecord.find_by(job_id: params[:job_id])

    if job_record.update(job_record_params)
      render json: job_record
    else
      render json: { errors: job_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    job_record = JobRecord.find_by(job_id: params[:job_id])

    if job_record
      job_record.destroy
      head :no_content
    else
      render json: { errors: "Job record not found" }, status: :not_found
    end
  end

  def status
    skip_authorization
    job_record = JobRecord.find_by(id: params[:job_id])

    if job_record
      render json: { status: job_record.status }
      if job_record.status == 'completed'
        job_record.destroy
      end
    else
      render json: { status: 'not_found' }, status: :not_found
    end
  end

  private

  def job_record_params
    params.permit(:job_id, :status)
  end
end
