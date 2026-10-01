namespace :db do
  desc 'Load the schema into an empty database, otherwise run pending migrations'
  task ensure: :environment do
    if ActiveRecord::Base.connection.table_exists?('schema_migrations')
      Rake::Task['db:migrate'].invoke
    else
      Rake::Task['db:schema:load'].invoke
    end
  end
end
