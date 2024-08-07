class Category < ApplicationRecord
  belongs_to :parent, class_name: Category.name, optional: true
  has_many :children, class_name: Category.name,
                      foreign_key: :parent_id,
                      dependent: :destroy
  has_one_attached :image
  before_save :update_parent_path

  private

  def update_parent_path
    if parent
      parent_path_segment = if parent.parent_path.present?
                              "#{parent.parent_path}/"
                            else
                              ""
                            end
      self.parent_path = "#{parent_path_segment}#{parent.category_name}"
    else
      self.parent_path = nil
    end
  end
end
