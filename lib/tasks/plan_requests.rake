namespace :potee do
  desc "Delete plan-from-text requests older than 30 days (FT-001 SD-02)"
  task purge_plan_requests: :environment do
    count = PlanRequest.expired.delete_all
    puts "Deleted #{count} plan requests"
  end
end
