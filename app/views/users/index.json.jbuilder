json.array!(@users) do |user|
  json.extract! user, :id, :active, :create_at, :creator, :email, :first_name, :last_name, :notify, :password_hash, :role, :updated_at
  json.url user_url(user, format: :json)
end
