require 'spec_helper'

describe Rovi::Api do

  before do
    @api = api_with_frozen_time
  end
  
  describe "A call to the data service release info endpoint" do

    before do
      params = {
        :upcid => '081227995119'
      }
    end

    after do
      Timecop.return
    end

    it 'should know the right endpoint for the releaes service' do
      @api.instance_variable_set(:@api_function, "release")
      @api.instance_variable_set(:@api_function_request, "info")
      @api.send(:endpoint).should == 'http://api.rovicorp.com/data/v1.1/release/info'
    end

  end

  describe "A call to the data service album info endpoint" do
    before do
      params = {
        :albumid => "MW0000111184" 
      }
      
    end
    
    after do
      Timecop.return
    end
    
    it 'should know the right endpoint for the data service' do
      @api.instance_variable_set(:@api_function, "album")
      @api.instance_variable_set(:@api_function_request, "info")
      @api.send(:endpoint).should == "http://api.rovicorp.com/data/v1.1/album/info"
    end
    
    it 'should calculate the sig from the MD5 of the access key, secret and the current unix time' do
      Timecop.freeze(Time.local(2014, 1, 1)) do
        @api.send(:generate_sig).should == '66b85a590cc398174ee650ad6711f30e'
      end
    end
  
    describe 'GET the response from the API' do
      before do
        mock_response = mock()
        mock_response.expects(:parsed_response).returns({ "value" => { "nested" =>  "hi" }})        
        
        Rovi::Api.expects(:get).with('http://api.rovicorp.com/data/v1.1/album/info', { 
        :query => { :albumid => 'MW0000111184', :apikey => '12345', 
        :sig => '66b85a590cc398174ee650ad6711f30e'}}).returns(mock_response)

        Timecop.freeze(Time.local(2014, 1, 1)) do
          @response = @api.get("album", "info", { :albumid => "MW0000111184" })
        end
      end
      
      it "should return a JsonResponse wrapper" do
        @response.is_a?(Rovi::JsonResponse).should == true
      end
      
      it "should access hash keys using methods" do
        @response.value.nested.should == "hi"
      end
    end
  end
end
