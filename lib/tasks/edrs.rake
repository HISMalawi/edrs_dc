namespace :edrs do
  desc "Creating default user"
  
  task setup: :environment do

    require Rails.root.join('db','seeds.rb')

  end

end