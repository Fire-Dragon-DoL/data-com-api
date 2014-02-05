require 'hashie'

class Company < Hashie::Trash
  property :id, from: :companyId

  def to_json(options={})
    {companyId: id}
  end
end