require 'spec_helper'
require 'active_support'
require File.expand_path('../../../app/helpers/mongod_paginate_helper', __FILE__)
include MongodPaginateHelper

class String
  def html_safe
    ActiveSupport::SafeBuffer.new(self)
  end
end

RSpec.describe MongodPaginateHelper do

  context '.next_page_class 1' do
    before do
      @obj = double('obj')
      allow(@obj).to receive(:current_page)
                      .and_return(1)
      allow(@obj).to receive(:total_pages)
                      .and_return(1)
    end

    it 'should return \'class="disabled"\'' do
      expect(next_page_class(@obj)).to eq(' class="disabled"')
    end
  end

  context '.next_page_class 2' do
    before do
      @obj = double('obj')
      allow(@obj).to receive(:current_page)
                      .and_return(1)
      allow(@obj).to receive(:total_pages)
                      .and_return(10)
    end

    it 'should return ""' do
      expect(next_page_class(@obj)).to eq('')
    end
  end

  context '.previous_page_class 1' do
    before do
      @obj = double('obj')
      allow(@obj).to receive(:current_page)
                      .and_return(1)
    end

    it 'should return \'class="disabled"\'' do
      expect(previous_page_class(@obj)).to eq(' class="disabled"')
    end
  end

  context '.previous_page_class 2' do
    before do
      @obj = double('obj')
      allow(@obj).to receive(:current_page)
                      .and_return(10)
    end

    it 'should return ""' do
      expect(previous_page_class(@obj)).to eq('')
    end
  end

  context '.next_page_link 1' do
    before do
      @obj = double('obj')
      allow(@obj).to receive(:current_page)
                      .and_return(10)
      allow(@obj).to receive(:total_pages)
                      .and_return(10)
    end

    it 'should return \'#\'' do
      expect(next_page_link(@obj, '', '')).to eq('#')
    end
  end

  context '.next_page_link 2' do
    before do
      @obj    = double('obj')
      allow(@obj).to receive(:current_page)
                      .and_return(1)
      allow(@obj).to receive(:total_pages)
                      .and_return(10)
      allow(@obj).to receive(:next_page)
                      .and_return(2)
      @uri    = 'http://localhost/test'
      @param  = { foo: 'bar' }
      @result = 'http://localhost/test?foo=bar&page=2'
    end

    it "should return #{@result}" do
      expect(next_page_link(@obj, @uri, @param)).to eq(@result)
    end
  end

  context '.previous_page_link 1' do
    before do
      @obj = double('obj')
      allow(@obj).to receive(:current_page)
                      .and_return(1)
    end

    it 'should return \'#\'' do
      expect(previous_page_link(@obj, '', '')).to eq('#')
    end
  end

  context '.previous_page_link 2' do
    before do
      @obj    = double('obj')
      allow(@obj).to receive(:current_page)
                      .and_return(4)
      allow(@obj).to receive(:previous_page)
                      .and_return(3)
      @uri    = 'http://localhost/test'
      @param  = { foo: 'bar' }
      @result = 'http://localhost/test?foo=bar&page=3'
    end

    it "should return #{@result}" do
      expect(previous_page_link(@obj, @uri, @param)).to eq(@result)
    end
  end

  context '.make_array_from_params' do
    before do
      @hash   = { foo: 'bar', bar: 'baz' }
      @result = %w{ foo=bar bar=baz }
    end

    it "should be #{@result}" do
      expect(make_array_from_params(@hash)).to eq(@result)
    end
  end

  context 'make_li_selector_from_params' do
    before do
      @uri    = 'http://localhost/test'
      @page   = 4
      @params = { foo: 'bar', bar: 'baz' }
      @result = "<li><a href='#{@uri}?foo=bar&bar=baz&page=#{@page}'>#{@page}</a></li>"
    end
    it 'should be' do
      expect(make_li_selector_from_params(@uri, @params, @page)).to eq(@result)
    end
  end

  context '.paginate_link' do

    context 'less than 7' do
      before do
        @obj    = double('obj')

        allow(@obj).to receive(:current_page)
                        .and_return(3)
        allow(@obj).to receive(:total_pages)
                        .and_return(6)

        @uri    = 'http://localhost/test'
        @param  = { foo: 'bar' }
        @result = %Q{<li><a href='#{@uri}?foo=bar&page=1'>1</a></li>
<li><a href='#{@uri}?foo=bar&page=2'>2</a></li>
<li class='active'><a href='#'>3 <span class='sr-only'>(current)</span></a></li>
<li><a href='#{@uri}?foo=bar&page=4'>4</a></li>
<li><a href='#{@uri}?foo=bar&page=5'>5</a></li>
<li><a href='#{@uri}?foo=bar&page=6'>6</a></li>}
      end

      it "should be " do
        expect(paginate_link(@obj, @uri, @param)).to eq(@result)
      end
    end

    context 'greater than 7' do

      context 'left ...' do
        before do
          @obj    = double('obj')
          allow(@obj).to receive(:current_page)
                          .and_return(7)
          allow(@obj).to receive(:total_pages)
                          .and_return(8)
          @uri    = 'http://localhost/test'
          @param  = { foo: 'bar' }
          @result = %Q{<li><a href='#{@uri}?foo=bar&page=1'>1</a></li>
<li class="disabled"><span aria-hidden="true">..</span></li>
<li><a href='#{@uri}?foo=bar&page=5'>5</a></li>
<li><a href='#{@uri}?foo=bar&page=6'>6</a></li>
<li class='active'><a href='#'>7 <span class='sr-only'>(current)</span></a></li>
<li><a href='#{@uri}?foo=bar&page=8'>8</a></li>}
        end

        it "should be " do
          expect(paginate_link(@obj, @uri, @param)).to eq(@result)
        end
      end

      context 'both ...' do
        before do
          @obj    = double('obj')
          allow(@obj).to receive(:current_page)
                          .and_return(7)
          allow(@obj).to receive(:total_pages)
                          .and_return(12)
          @uri    = 'http://localhost/test'
          @param  = { foo: 'bar' }
          @result = %Q{<li><a href='#{@uri}?foo=bar&page=1'>1</a></li>
<li class="disabled"><span aria-hidden="true">..</span></li>
<li><a href='#{@uri}?foo=bar&page=5'>5</a></li>
<li><a href='#{@uri}?foo=bar&page=6'>6</a></li>
<li class='active'><a href='#'>7 <span class='sr-only'>(current)</span></a></li>
<li><a href='#{@uri}?foo=bar&page=8'>8</a></li>
<li><a href='#{@uri}?foo=bar&page=9'>9</a></li>
<li class="disabled"><span aria-hidden="true">..</span></li>
<li><a href='#{@uri}?foo=bar&page=12'>12</a></li>}
        end

        it "should be " do
          expect(paginate_link(@obj, @uri, @param)).to eq(@result)
        end
      end

      context 'right ...' do
        before do
          @obj    = double('obj')
          allow(@obj).to receive(:current_page)
                          .and_return(2)
          allow(@obj).to receive(:total_pages)
                          .and_return(12)
          @uri    = 'http://localhost/test'
          @param  = { foo: 'bar' }
          @result = %Q{<li><a href='#{@uri}?foo=bar&page=1'>1</a></li>
<li class='active'><a href='#'>2 <span class='sr-only'>(current)</span></a></li>
<li><a href='#{@uri}?foo=bar&page=3'>3</a></li>
<li><a href='#{@uri}?foo=bar&page=4'>4</a></li>
<li class="disabled"><span aria-hidden="true">..</span></li>
<li><a href='#{@uri}?foo=bar&page=12'>12</a></li>}
        end

        it "should be " do
          expect(paginate_link(@obj, @uri, @param)).to eq(@result)
        end
      end

    end

  end

end
