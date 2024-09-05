module UsersHelper
  def display_user_addresses user
    return if user.addresses.blank?

    if user.addresses.size > 1
      sanitized_addresses = user.addresses.map.with_index(1) do |address, index|
        "#{index}. #{address.place}"
      end.join("<br>")
      sanitize sanitized_addresses
    else
      user.addresses.first.place
    end
  end
end
