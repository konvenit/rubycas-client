require "spec_helper"

describe CASClient::Client do
  context "with standard URL scheme" do
    let(:client) { CASClient::Client.new cas_base_url: "https://login.somewhere.com" }

    describe "login_url" do
      it "should return correct URL" do
        expect(client.login_url).to eq "https://login.somewhere.com/login"
      end
    end

    describe "internal_login_url" do
      it "should return correct URL" do
        expect(client.internal_login_url).to eq "https://login.somewhere.com/login"
      end
    end

    describe "validate_url" do
      it "should return correct URL" do
        expect(client.validate_url).to eq "https://login.somewhere.com/proxyValidate"
      end
    end

    describe "login_ticket_url" do
      it "should return correct URL" do
        expect(client.login_ticket_url).to eq "https://login.somewhere.com/loginTicket"
      end
    end

    describe "logout_url" do
      it "should return correct URL" do
        expect(client.logout_url).to eq "https://login.somewhere.com/logout"
      end
    end

    describe "cas_server_is_up?" do
      it "should use internal_login_url" do
        http_response = double(:http_response, :body => "", :kind_of? => Net::HTTPSuccess)
        http          = double(:http, :use_ssl= => nil, :use_ssl? => true, :start => http_response)
        expect(Net::HTTP).to receive(:new).with("login.somewhere.com", 443).and_return(http)
        client.cas_server_is_up?
      end
    end

    describe "login_to_service" do
      it "should use internal_login_url" do
        http_response = double(:http_response, :body => "", :kind_of? => Net::HTTPSuccess, :to_hash => {})
        http          = double(:http, :use_ssl= => nil, :use_ssl? => true, :start => http_response)
        expect(http).to receive(:post).with("/loginTicket", ";").and_return(http_response)
        expect(Net::HTTP).to receive(:new).with("login.somewhere.com", 443).and_return(http).exactly(2).times
        client.login_to_service({}, "https://elsewhere")
      end
    end
  end

  context "with internal login url" do
    let(:client) do
      CASClient::Client.new cas_base_url:       "https://login.somewhere.com",
                            internal_login_url: "http://internal_login/login"
    end

    describe "login_url" do
      it "should return correct URL" do
        expect(client.login_url).to eq "https://login.somewhere.com/login"
      end
    end

    describe "internal_login_url" do
      it "should return correct URL" do
        expect(client.internal_login_url).to eq "http://internal_login/login"
      end
    end

    describe "validate_url" do
      it "should return correct URL" do
        expect(client.validate_url).to eq "https://login.somewhere.com/proxyValidate"
      end
    end

    describe "login_ticket_url" do
      it "should return correct URL" do
        expect(client.login_ticket_url).to eq "http://internal_login/loginTicket"
      end
    end

    describe "logout_url" do
      it "should return correct URL" do
        expect(client.logout_url).to eq "https://login.somewhere.com/logout"
      end
    end

    describe "cas_server_is_up?" do
      it "should use internal_login_url" do
        http_response = double(:http_response, :body => "", :kind_of? => Net::HTTPSuccess)
        http          = double(:http, :use_ssl= => nil, :use_ssl? => false, :start => http_response)
        expect(Net::HTTP).to receive(:new).with("internal_login", 80).and_return(http)
        client.cas_server_is_up?
      end
    end

    describe "login_to_service" do
      it "should use internal_login_url" do
        http_response = double(:http_response, :body => "", :kind_of? => Net::HTTPSuccess, :to_hash => {})
        http          = double(:http, :use_ssl= => nil, :use_ssl? => false, :start => http_response)
        expect(http).to receive(:post).with("/loginTicket", ";").and_return(http_response)
        expect(Net::HTTP).to receive(:new).with("internal_login", 80).and_return(http).exactly(2).times
        client.login_to_service({}, "https://elsewhere")
      end
    end
  end
end
