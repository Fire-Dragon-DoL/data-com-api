require 'hashie'

class Company < Hashie::Trash
  property :id,              from: :companyId
  property :zip
  property :address
  property :name
  property :active_contacts, from: :activeContacts
  property :state
  property :graveyarded
  property :city
  property :country

  alias_method :graveyarded?, :graveyarded
end