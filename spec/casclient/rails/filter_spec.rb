require "spec_helper"

describe CASClient::Frameworks::Rails::Filter do
  before :each do
    @client = double(:client, username_session_key: :cas_user, add_service_to_login_url: "https://cas.example.com/login?service=http://myapp.example.com/")
    @log = double(:log, error: nil, warn: nil, debug: nil, info: nil)
    
    CASClient::Frameworks::Rails::Filter.log = @log
    CASClient::Frameworks::Rails::Filter.config = { authenticate_on_every_request: false }
    CASClient::Frameworks::Rails::Filter.client = @client
  end

  describe ".read_service_url" do
    context "when controller has default_url_options" do
      it "should merge default_url_options with params" do
        params = ActionController::Parameters.new(controller: 'test', action: 'index', id: '123')
        default_options = { host: 'myapp.example.com', protocol: 'https' }
        
        controller = double(:controller, 
          params: params,
          default_url_options: default_options,
          url_for: "https://myapp.example.com/test/123"
        )
        
        expect(controller).to receive(:respond_to?).with(:default_url_options).and_return(true)
        expect(controller).to receive(:url_for).with(hash_including(
          'controller' => 'test',
          'action' => 'index', 
          'id' => '123',
          host: 'myapp.example.com',
          protocol: 'https'
        ))
        
        service_url = CASClient::Frameworks::Rails::Filter.read_service_url(controller)
        expect(service_url).to eq("https://myapp.example.com/test/123")
      end
    end

    context "when controller does not have default_url_options" do
      it "should use params only" do
        params = ActionController::Parameters.new(controller: 'test', action: 'index', id: '123')
        
        controller = double(:controller, 
          params: params,
          url_for: "http://localhost:3000/test/123"
        )
        
        expect(controller).to receive(:respond_to?).with(:default_url_options).and_return(false)
        expect(controller).to receive(:url_for).with(hash_including(
          'controller' => 'test',
          'action' => 'index', 
          'id' => '123'
        ))
        
        service_url = CASClient::Frameworks::Rails::Filter.read_service_url(controller)
        expect(service_url).to eq("http://localhost:3000/test/123")
      end
    end

    context "when service_url is explicitly configured" do
      it "should use the configured service_url" do
        CASClient::Frameworks::Rails::Filter.config[:service_url] = "https://explicit.example.com/service"
        
        controller = double(:controller)
        
        service_url = CASClient::Frameworks::Rails::Filter.read_service_url(controller)
        expect(service_url).to eq("https://explicit.example.com/service")
      end
    end

    context "when service_url is a Proc" do
      it "should call the Proc with the controller" do
        service_proc = proc { |controller| "https://dynamic.example.com/#{controller.params[:id]}" }
        CASClient::Frameworks::Rails::Filter.config[:service_url] = service_proc
        
        params = ActionController::Parameters.new(id: '456')
        controller = double(:controller, params: params)
        
        service_url = CASClient::Frameworks::Rails::Filter.read_service_url(controller)
        expect(service_url).to eq("https://dynamic.example.com/456")
      end
    end
  end

  describe ".login_url" do
    it "should generate login url using read_service_url" do
      params = ActionController::Parameters.new(controller: 'test', action: 'index')
      default_options = { host: 'myapp.example.com', protocol: 'https' }
      
      controller = double(:controller, 
        params: params,
        default_url_options: default_options,
        url_for: "https://myapp.example.com/test"
      )
      
      expect(controller).to receive(:respond_to?).with(:default_url_options).and_return(true)
      expect(@client).to receive(:add_service_to_login_url).with("https://myapp.example.com/test").and_return("https://cas.example.com/login?service=https://myapp.example.com/test")
      
      login_url = CASClient::Frameworks::Rails::Filter.login_url(controller)
      expect(login_url).to eq("https://cas.example.com/login?service=https://myapp.example.com/test")
    end
  end
end 