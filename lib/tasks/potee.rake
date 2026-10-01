namespace :potee do
  desc "Delete anonymous users (and their boards) not seen for DAYS days (default 30)"
  task cleanup_anonymous: :environment do
    days = ENV.fetch("DAYS", 30).to_i
    count = 0
    User.abandoned(days.days.ago).find_each do |user|
      user.destroy!
      count += 1
    end
    puts "Deleted #{count} anonymous users not seen for #{days} days"
  end
end
