require 'spec_helper'
require 'data-com-api/paging_maths'

describe DataComApi::PagingMaths, focus: true do
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

    context "when records available" do

      it "is 1 when using :first" do
        expect(paging_maths.page_index(:first)).to be 1
      end

      it "is 1_000 when using :last" do
        expect(paging_maths.page_index(:last)).to be 1_000
      end

      it "is 33334 when using :last and page_size is 3" do
        expect(paging_maths.page_index(:last)).to be 33334
      end

    end

    context "when no records available" do
      before do
        paging_maths.total_records = 0
      end

      # Just to ensure that subject of subject doesn't create disasters
      it "has no records available" do
        expect(paging_maths.total_records).to be 0
      end

      [:first, :last, 2, 3].each do |random_page|
        it "is nil when no records are available" do
          expect(paging_maths.page_index(random_page)).to be_nil
        end
      end

    end

  end

  describe "#records_per_page" do

    it "raises error when 0 is passed" do
      expect{paging_maths.records_per_page(0)}.to raise_error ArgumentError
    end

    it "is the same amount of records when using 1 or :first" do
      expect(paging_maths.records_per_page(:first)).to be paging_maths.records_per_page(1)
    end

    it "is the same amount of records when using 33334 (last) with page_size 3 or :last" do
      paging_maths.page_size = 3
      expect(paging_maths.records_per_page(:last)).to be paging_maths.records_per_page(33334)
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

    it "is 1 on page 33334 with page_size 3" do
      paging_maths.page_size  = 3
      expect(paging_maths.records_per_page(33334)).to be 1
    end

    it "is page_size when not on last page" do
      expect(paging_maths.records_per_page(1)).to be paging_maths.page_size
    end

  end

  describe "#page_from_offset" do

    it "is nil when no records available" do
      paging_maths.total_records = 0
      expect(paging_maths.page_from_offset(0)).to be_nil
    end

    it "is 1 when offset is 0" do
      expect(paging_maths.page_from_offset(0)).to be 1
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

    it "is 33334 when page_size = 3" do
      paging_maths.page_size = 3
      expect(paging_maths.total_pages).to be 33334
    end

    it "is equal to total_records when total_records < page_size" do
      paging_maths.total_records = 3
      expect(paging_maths.total_records).to be paging_maths.total_records
    end

  end

end
