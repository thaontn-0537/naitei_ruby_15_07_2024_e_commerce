module CategoriesHelper
  def gravatar_for_category category,
    options = {size: Settings.gravatar.size, default: "identicon"}
    gravatar_id = Digest::MD5.hexdigest(category.id.to_s)
    size = options[:size]
    default = options[:default]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=#{default}"
    image_tag(gravatar_url, alt: category.category_name, class: "gravatar")
  end
end
