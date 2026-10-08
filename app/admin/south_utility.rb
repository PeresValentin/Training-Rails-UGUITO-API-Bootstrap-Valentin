ActiveAdmin.register SouthUtility do
  filter :name
  filter :code
  filter :created_at
  filter :updated_at

  permit_params = %i[
    name code base_url external_api_key external_api_secret
    external_api_authentication_url books_data_url notes_data_url
    short_note_limit medium_note_limit
  ]

  member_action :copy, method: :get do
    @south_utility = resource.dup
    render :new, layout: false
  end

  action_item :copy, only: :show do
    link_to(I18n.t('active_admin.clone_model', model: 'SouthUtility'),
            copy_admin_north_utility_path(id: resource.id))
  end

  controller do
    define_method :permitted_params do
      params.permit(active_admin_namespace.permitted_params, south_utility: permit_params)
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :code
    actions
  end

  show do |south|
    render 'show', locals: { south: south }
    active_admin_comments
  end

  form do |f|
    f.inputs 'Utility Details', allow_destroy: true do
      f.semantic_errors(*f.object.errors.keys)
      f.input :name
      f.input :code
      f.input :external_api_key
      f.input :external_api_secret
      f.input :external_api_authentication_url, as: :url
      f.input :books_data_url, as: :url
      f.input :notes_data_url, as: :url
      f.input :short_note_limit
      f.input :medium_note_limit
      f.actions
    end
  end
end
