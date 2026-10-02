ActiveAdmin.register Book do
  permit_params :title, :author, :genre, :image, :publisher, :year, :utility_id, :user_id

  includes :utility, :user

  index do
    selectable_column
    id_column
    column :title
    column :author
    column :genre
    column :publisher
    column :year
    column :utility
    column :user
    actions
  end

  filter :title
  filter :author
  filter :genre
  filter :publisher
  filter :year
  filter :utility
  filter :user, member_label: :email

  show do
    attributes_table do
      row :title
      row :author
      row :genre
      row :image
      row :publisher
      row :year
      row :utility
      row :user
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :author
      f.input :genre
      f.input :image, as: :url
      f.input :publisher
      f.input :year
      f.input :utility
      f.input :user, member_label: :email
    end
    f.actions
  end
end
