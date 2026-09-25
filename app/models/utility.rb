# == Schema Information
#
# Table name: utilities
#
#  id                                   :bigint(8)        not null, primary key
#  name                                 :string           not null
#  type                                 :string           not null
#  code                                 :integer
#  base_url                             :string
#  external_api_key                     :string
#  external_api_secret                  :string
#  external_api_access_token            :string
#  external_api_access_token_expiration :datetime
#  integration_urls                     :jsonb
#  jsonb                                :jsonb
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#
class Utility < ApplicationRecord
  include EntityWithCode
  include AttributeJsonParser

  JSON_ATTRIBUTES = %i[integration_urls].freeze

  has_many :users, dependent: :destroy

  validates :name, uniqueness: true
  validates :name, :type, presence: true

  store_accessor :integration_urls, :external_api_authentication_url, :books_data_url

  def generate_entity_code
    return if code.present? && !code.to_i.zero?
    self.code = id
    save!
  end

  def self.valid_type?(type)
    subclasses.include?(type.safe_constantize)
  end

  def utility_service_type
    "UtilityService::#{utility_type}".safe_constantize
  end

  def parameter_validator_service_type
    "ParameterValidatorService::#{utility_type}".safe_constantize
  end

  def transform_response_service_dispatcher_type
    "TransformResponseService::#{utility_type}".safe_constantize
  end

  def utility_service(user = nil)
    @utility_service ||= utility_service_type::Base.new(self, user)
  end

  def parameter_validator_service(controller: nil, params: {})
    @parameter_validator_service ||=
      parameter_validator_service_type::Base.new(self, controller, params)
  end

  def transform_response_service_dispatcher(user = nil)
    @transform_response_service_dispatcher ||=
      transform_response_service_dispatcher_type::Dispatcher.new(self, user)
  end

  def find_consumer(params)
    consumers.find_by(username: params[:username])
  end

  def clean_name
    self.class.name.underscore.split('_').first
  end

  def note_content_length(note)
    return 'short' if short_note?(note)
    return 'medium' if medium_note?(note)

    'long'
  end

  def short_note?(_note)
    raise NotImplementedError, "#{self.class.name} must implement #short_note?"
  end

  private

  def utility_type
    type.chomp('Utility')
  end

  def medium_note?(_note)
    raise NotImplementedError, "#{self.class.name} must implement #medium_note?"
  end
end
