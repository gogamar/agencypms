class PagesController < ApplicationController
  #skip_before_action :authenticate_user!, only: :home

  def home
    UserMailer.welcome(User.new(email: 'gogamar@gmail.com')).deliver
    @vragreements = policy_scope(Vragreement)
    @vrowners = policy_scope(Vrowner)
    @agreements = policy_scope(Agreement)
    @contracts = policy_scope(Contract)
    @task = Task.new
    @tasks = Task.where(start_date: Time.now.beginning_of_month.beginning_of_week..Time.now.end_of_month.end_of_week).order(start_time: :asc)
  end

end
