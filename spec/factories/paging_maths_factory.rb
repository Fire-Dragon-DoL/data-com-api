require 'data-com-api/paging_maths'

FactoryGirl.define do

  factory :paging_maths, class: DataComApi::PagingMaths do
    page_size     50
    max_offset    100_000
    total_records 1_000_000
  end

end