require 'spec_helper'
require 'data-com-api/paging_maths'

describe DataComApi::PagingMaths do
  subject(:paging_maths) do
    FactoryGirl.build(:paging_maths,
      max_offset:    100_000,
      page_size:     100,
      total_records: 1_000_000
    )
  end

  describe "#any_record?" do

    it "is false when no records available" do
      paging_maths.total_records = 0
      expect(paging_maths.any_record?).to be_false
    end

    it "is true when records available" do
      expect(paging_maths.any_record?).to be_true
    end

    it "is false when page_size = 0" do
      paging_maths.page_size = 0
      expect(paging_maths.any_record?).to be_false
    end

    it "is true when page_size > 0" do
      expect(paging_maths.any_record?).to be_true
    end

    it "is false when max_offset = 0" do
      paging_maths.max_offset = 0
      expect(paging_maths.any_record?).to be_false
    end

    it "is true when max_offset > 0" do
      expect(paging_maths.any_record?).to be_true
    end

  end

  describe "#page_index" do

    it "raises error when 0 is passed" do
      expect{paging_maths.page_index(0)}.to raise_error ArgumentError
    end

    it "raises error when nil is passed" do
      expect{paging_maths.page_index(nil)}.to raise_error ArgumentError
    end

    it "doesn't raise error when value > total_pages is passed" do
      expect{paging_maths.page_index(paging_maths.total_pages + 1)}.not_to raise_error
    end

    it "is nil when value > total_pages is passed" do
      expect(paging_maths.page_index(paging_maths.total_pages + 1)).to be_nil
    end

    context "when records available" do

      it "is 1 when using :first" do
        expect(paging_maths.page_index(:first)).to be 1
      end

      it "is 1 000 when using :last" do
        expect(paging_maths.page_index(:last)).to be 1_000
      end

      it "is 33 333 when using :last and page_size is 3" do
        paging_maths.page_size = 3
        expect(paging_maths.page_index(:last)).to be 33_333
      end

    end

    context "when no records available" do
      before do
        paging_maths.total_records = 0
      end

      # Just to ensure that subject of subject doesn't create disasters
      it "ensures has no records" do
        expect(paging_maths.total_records).to be 0
      end

      [:first, :last, 2, 3].each do |random_page|
        it "is nil" do
          paging_maths.total_records = 0
          expect(paging_maths.page_index(random_page)).to be_nil
        end
      end

    end

  end

  describe "#records_per_page" do

    it "raises error when 0 is passed" do
      expect{paging_maths.records_per_page(0)}.to raise_error ArgumentError
    end

    it "is nil when page > total_pages" do
      expect(paging_maths.records_per_page(paging_maths.total_pages + 1)).to be_nil
    end

    it "is the same amount of records when using 1 or :first" do
      expect(paging_maths.records_per_page(:first)).to be paging_maths.records_per_page(1)
    end

    it "is the same amount of records when using 33 333 (last) with page_size 3 or :last" do
      paging_maths.page_size = 3
      expect(paging_maths.records_per_page(:last)).to be paging_maths.records_per_page(33_333)
    end

    it "is nil when page_size = 0" do
      paging_maths.page_size = 0
      expect(paging_maths.records_per_page(1)).to be_nil
    end

    it "is nil when total_records = 0" do
      paging_maths.total_records = 0
      expect(paging_maths.records_per_page(1)).to be_nil
    end

    it "is nil when max_offset = 0" do
      paging_maths.max_offset = 0
      expect(paging_maths.records_per_page(1)).to be_nil
    end

    it "is 3 on page 33 333 with page_size 3" do
      paging_maths.page_size = 3
      expect(paging_maths.records_per_page(33_333)).to be 3
    end

    it "is page_size when on last page" do
      paging_maths.page_size = 3
      expect(paging_maths.records_per_page(33_333)).to be paging_maths.page_size
    end

  end

  describe "#page_from_offset" do

    it "raises error when offset > max_offset" do
      expect{paging_maths.page_from_offset(paging_maths.max_offset + 1)}.to raise_error ArgumentError
    end

    it "is nil when no records available" do
      paging_maths.total_records = 0
      expect(paging_maths.page_from_offset(0)).to be_nil
    end

    it "is nil when offset > real_max_offset" do
      paging_maths.page_size = 3
      expect(paging_maths.page_from_offset(100_000)).to be_nil
    end

    it "is not nil when offset = real_max_offset" do
      paging_maths.page_size = 3
      expect(paging_maths.page_from_offset(99_999)).to be 33_333
    end

    it "is 1 when offset is 0" do
      expect(paging_maths.page_from_offset(0)).to be 1
    end

    it "is 100 when offset is 10 000" do
      expect(paging_maths.page_from_offset(10_000)).to be 100
    end

  end

  describe "#offset_from_page" do

    it "doesn't raise error when page > total_pages" do
      expect{paging_maths.offset_from_page(paging_maths.total_pages + 1)}.not_to raise_error
    end

    it "is nil when no records available" do
      paging_maths.total_records = 0
      expect(paging_maths.offset_from_page(1)).to be_nil
    end

    it "is nil when page > total_pages" do
      expect(paging_maths.offset_from_page(paging_maths.total_pages + 1)).to be_nil
    end

    it "is 0 when page is 1" do
      expect(paging_maths.offset_from_page(1)).to be 0
    end

    it "is 100 when page is 2" do
      expect(paging_maths.offset_from_page(2)).to be 100
    end

    it "is 99_999 when page is 33 333 and page_size = 3" do
      paging_maths.page_size = 3
      expect(paging_maths.offset_from_page(33_333)).to be 99_999
    end

    it "is 99 999 when page is 33 333 and page_size = 3 and total_records 99 999" do
      paging_maths.page_size     = 3
      paging_maths.total_records = 99_999
      expect(paging_maths.offset_from_page(33_333)).to be 99_999
    end

  end

  describe "#total_pages" do

    it "is 0 when no records available" do
      paging_maths.total_records = 0
      expect(paging_maths.total_pages).to be 0
    end

    it "is 1 000" do
      expect(paging_maths.total_pages).to be 1_000
    end

    it "is 33 333 when page_size = 3" do
      paging_maths.page_size = 3
      expect(paging_maths.total_pages).to be 33_333
    end

    it "is equal to 1 when total_records < page_size" do
      paging_maths.total_records = 3
      paging_maths.page_size     = 4
      expect(paging_maths.total_pages).to be 1
    end

  end

end
