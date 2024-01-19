class ChangeArrivalDayInRates < ActiveRecord::Migration[7.0]
  def change
    add_column :rates, :temporary_arrival_day, :integer

    Rate.where(arrival_day: 'saturdays').update_all(temporary_arrival_day: 6)
    Rate.where(arrival_day: 'everyday').update_all(temporary_arrival_day: 7)

    remove_column :rates, :arrival_day
    rename_column :rates, :temporary_arrival_day, :arrival_day

    add_column :rate_plans, :temporary_gen_arrival, :integer

    RatePlan.where(gen_arrival: 'saturdays').update_all(temporary_gen_arrival: 6)
    RatePlan.where(gen_arrival: 'everyday').update_all(temporary_gen_arrival: 7)

    remove_column :rate_plans, :gen_arrival
    rename_column :rate_plans, :temporary_gen_arrival, :gen_arrival

    add_column :rate_periods, :temporary_arrival_day, :integer

    RatePeriod.where(arrival_day: 'saturdays').update_all(temporary_arrival_day: 6)
    RatePeriod.where(arrival_day: 'everyday').update_all(temporary_arrival_day: 7)

    remove_column :rate_periods, :arrival_day
    rename_column :rate_periods, :temporary_arrival_day, :arrival_day
  end
end
