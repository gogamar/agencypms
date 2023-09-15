class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: :home

  def home
    @vragreements = policy_scope(Vragreement)
    @vrowners = policy_scope(Vrowner)
    @task = Task.new
    @tasks = Task.where(start_date: Time.now.beginning_of_month.beginning_of_week..Time.now.end_of_month.end_of_week).order(start_date: :asc)
  end

end
