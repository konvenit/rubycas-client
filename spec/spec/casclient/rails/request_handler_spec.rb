require 'spec_helper'

describe CASClient::Frameworks::Rails::RequestHandler do

  before :each do
    @ticket = CASClient::ServiceTicket.new("my_ticket", "http://service.com")
    @client = mock(:client, :username_session_key => :cas_user,
                            :extra_attributes_session_key => :cas_extra_attributes,
                            :validate_service_ticket => @ticket)

    @session = mock(:session, :[] => nil, :[]=  => nil)

    @request = mock(:request, :headers => { "CONTENT_TYPE" => nil }, :post? => false)
    @controller = mock(:controller, :session => @session, :params => {}, :request => @request, :url_for => "/some_resource/2")
    @request_handler = CASClient::Frameworks::Rails::RequestHandler.new(@controller)

    CASClient::Frameworks::Rails::Filter.log = mock(:log, :error => nil, :warn => nil, :debug => nil, :info => nil)
    CASClient::Frameworks::Rails::Filter.config = {:authenticate_on_every_request => false}
    CASClient::Frameworks::Rails::Filter.client = @client
  end

  describe "single sign out requests" do

    before :each do
      CASClient::Frameworks::Rails::Filter.config.merge!(:enable_single_sign_out => true)
      @request.stub!(:post?).and_return(true)
      ActionController::Base.session_options.stub!(:[]).with(:database_manager).and_return(ActiveRecord::SessionStore)
      ActiveRecord::SessionStore::Session.stub!(:find_by_session_id).and_return(mock(:session_record, :destroy => nil))
    end

    it "should not signal a single sign out for multipart requests" do
      @request.headers.stub!(:[]).with("CONTENT_TYPE").and_return("multipart/form-data")
      @request_handler.handle_request.should == :to_login
    end

    it "should signal single signout" do
      @controller.params.stub!(:[]).with("logoutRequest").and_return("<samlp:LogoutRequest><samlp:SessionIndex>my_session_id</samlp:SessionIndex></samlp:LogoutRequest>")
      @request_handler.handle_request.should == :single_sign_out
    end

  end

  describe "requests without existing session" do

    before :each do
      @session.stub!(:[]).with(:cas_last_valid_ticket).and_return(nil)
      @controller.params.stub!(:[]).with(:renew).and_return(nil)
    end

    it "should allow access with valid ticket" do
      @controller.params.stub!(:[]).with(:ticket).and_return("valid")
      @ticket.stub!(:is_valid?).and_return(true)
      @ticket.stub!(:response).and_return(mock(:response, :user => "12345", :extra_attributes => "", :pgt_iou => false))

      @session.should_receive(:[]=).with(:cas_user, "12345")
      @session.should_receive(:[]=).with(:casfilteruser, "12345")
      @session.should_receive(:[]=).with(:cas_extra_attributes, {})
      @session.should_receive(:[]=).with(:cas_last_valid_ticket, @ticket)
      @request_handler.handle_request.should == :new_session
    end

    it "should allow acces without ticket if returning from gateway and gatewaying is enabled" do
      @controller.params.stub!(:[]).with(:ticket).and_return(nil)
      @session.stub!(:[]).with(:cas_sent_to_gateway).and_return(true)
      @request_handler.use_gatewaying = true
      @request_handler.handle_request.should == :new_session
    end

    it "should redirect to_login if no ticket is present in the params" do
      @controller.params.stub!(:[]).with(:ticket).and_return(nil)
      @request_handler.handle_request.should == :to_login
    end

    it "should redirect to_login if ticket in the params is invalid" do
      @controller.params.stub!(:[]).with(:ticket).and_return("invalid")
      @ticket.stub!(:is_valid?).and_return(false)
      @ticket.stub!(:response).and_return(mock(:response, :failure_code => 404, :failure_message => "some failure message"))
      @request_handler.handle_request.should == :validation_failed
    end

  end

  describe "requests with existing session" do

    before :each do
      @session.stub!(:[]).with(:cas_last_valid_ticket).and_return(@ticket)
      @session.stub!(:[]).with(:cas_user).and_return(12354)
    end

    describe "which has not been invalidated remotely" do

      before :each do
        @ticket.response = mock(:response, :pgt_iou => false, :is_success? => true, :user => "my_user_name", :extra_attributes => {})
      end

      it "should allow access if not authenticating on every request " do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = false
        @request_handler.handle_request.should == :allow
      end

      it "should allow access if authenticating on every request" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = true
        @ticket.response.stub!(:is_success?).and_return(true)
        @ticket.response.stub!(:user).and_return("12345")
        @ticket.response.stub!(:extra_attributes).and_return("")
        @request_handler.handle_request.should == :allow
      end

    end

    describe "which has been invalidated remotely" do

      before :each do
        @ticket.response = mock(:response, :is_success? => false, :failure_code => 404, :failure_message => "some message")
      end

      it "should allow access if not authenticating on every request" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = false
        @ticket.response = mock(:response, :pgt_iou => false, :is_success? => true, :user => "my_user_name", :extra_attributes => {})
        @request_handler.handle_request.should == :allow
      end

      it "should redirect to login if authenticating on every request" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = true
        @request_handler.handle_request.should == :validation_failed
      end

    end

  end

end
