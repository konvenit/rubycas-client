require "spec/spec_helper"

describe CASClient::Frameworks::Rails::RequestHandler do

  before :each do
    @ticket = CASClient::ServiceTicket.new("my_ticket", "http://service.com")
    @client = double(:client, :username_session_key => :cas_user,
                              :extra_attributes_session_key => :cas_extra_attributes,
                              :validate_service_ticket => @ticket)

    @session = double(:session, :[] => nil, :[]=  => nil)

    @request = double(:request, :headers => { "CONTENT_TYPE" => nil }, :post? => false)
    params = ActionController::Parameters.new
    @controller = double(:controller, session: @session, params: params, request: @request, url_for: "/some_resource/2", reset_session: nil)
    @request_handler = CASClient::Frameworks::Rails::RequestHandler.new(@controller)

    CASClient::Frameworks::Rails::Filter.log = double(:log, :error => nil, :warn => nil, :debug => nil, :info => nil)
    CASClient::Frameworks::Rails::Filter.config = {:authenticate_on_every_request => false}
    CASClient::Frameworks::Rails::Filter.client = @client
  end

  describe "requests without existing session" do

    before :each do
      @session.stub(:[]).with(:cas_last_valid_ticket).and_return(nil)
      @controller.params.stub(:[]).with(:renew).and_return(nil)
    end

    it "should allow access with valid ticket" do
      @controller.params.stub(:[]).with(:ticket).and_return("valid")
      @ticket.stub(:is_valid?).and_return(true)
      @ticket.stub(:response).and_return(double(:response, :user => "12345", :extra_attributes => "", :pgt_iou => false))

      @session.should_receive(:[]=).with(:cas_user, "12345")
      @session.should_receive(:[]=).with(:casfilteruser, "12345")
      @session.should_receive(:[]=).with(:cas_extra_attributes, {})
      pending
      # TODO
      @session.should_receive(:[]=).with(:cas_last_valid_ticket, renew: false, service: "http://service.com", ticket: "my_ticket")
      @request_handler.handle_request.should == :allow
    end

    it "should allow acces without ticket if returning from gateway and gatewaying is enabled" do
      @controller.params.stub(:[]).with(:ticket).and_return(nil)
      @session.stub(:[]).with(:cas_sent_to_gateway).and_return(true)
      @request_handler.use_gatewaying = true
      @request_handler.handle_request.should == :allow
    end

    it "should redirect to_login if no ticket is present in the params" do
      @controller.params.stub(:[]).with(:ticket).and_return(nil)
      @request_handler.handle_request.should == :to_login
    end

    it "should redirect to_login if ticket in the params is invalid" do
      @controller.params.stub(:[]).with(:ticket).and_return("invalid")
      @ticket.stub(:is_valid?).and_return(false)
      @ticket.stub(:response).and_return(double(:response, :failure_code => 404, :failure_message => "some failure message"))
      @request_handler.handle_request.should == :validation_failed
    end

  end

  describe "requests with existing session" do

    before :each do
      @session.stub(:[]).with(:cas_last_valid_ticket).and_return(@ticket)
      @session.stub(:[]).with(:cas_user).and_return(12354)
    end

    describe "which has not been invalidated remotely" do

      before :each do
        @ticket.response = double(:response, :pgt_iou => false, :is_success? => true, :user => "my_user_name", :extra_attributes => {})
      end

      it "should allow access if not authenticating on every request" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = false
        @request_handler.handle_request.should == :allow
      end

      it "should allow access if not authenticating on every request because of proc" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = proc { |c| false }
        @request_handler.handle_request.should == :allow
      end

      it "should allow access if authenticating on every request" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = true
        @ticket.response.stub(:is_success?).and_return(true)
        @ticket.response.stub(:user).and_return("12345")
        @ticket.response.stub(:extra_attributes).and_return("")
        @request_handler.handle_request.should == :allow
      end

      it "should allow access if authenticating on every request because of proc" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = proc { |c| true }
        @ticket.response.stub(:is_success?).and_return(true)
        @ticket.response.stub(:user).and_return("12345")
        @ticket.response.stub(:extra_attributes).and_return("")
        @request_handler.handle_request.should == :allow
      end

    end

    describe "which has been invalidated remotely" do

      before :each do
        @ticket.response = double(:response, :is_success? => false, :failure_code => 404, :failure_message => "some message")
      end

      it "should allow access if not authenticating on every request" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = false
        @ticket.response = double(:response, :pgt_iou => false, :is_success? => true, :user => "my_user_name", :extra_attributes => {})
        @request_handler.handle_request.should == :allow
      end

      it "should allow access if not authenticating on every request because of proc" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = proc { |c| false }
        @ticket.response = double(:response, :pgt_iou => false, :is_success? => true, :user => "my_user_name", :extra_attributes => {})
        @request_handler.handle_request.should == :allow
      end

      it "should redirect to login if authenticating on every request" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = true
        @request_handler.handle_request.should == :to_login
      end

      it "should redirect to login if authenticating on every request because of proc" do
        CASClient::Frameworks::Rails::Filter.config[:authenticate_on_every_request] = proc { |c| true }
        @request_handler.handle_request.should == :to_login
      end

    end

  end

end
