require 'spec_helper'

describe Gracenote do

  def stub_register_api
    @register_api_response = {
      "RESPONSES" => {
        "RESPONSE" => {
          "USER" => "111111111111111111-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        }
      }
    }
    xml =<<EOF
    <RESPONSES>
      <RESPONSE STATUS="OK">
        <USER>111111111111111111-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA</USER>
      </RESPONSE>
    </RESPONSES>
EOF
    Gracenote.any_instance.stub(:post).and_return xml
  end

  it 'should have a version number' do
    Gracenote::VERSION.should_not be_nil
  end

  describe 'Gracenote.initialize' do
    it 'should set @client_id' do
      stub_register_api
      client = Gracenote.new('test-id')
      expect(client.client_id).to eq('test-id')
    end

    it 'should set @user_id' do
      stub_register_api
      client = Gracenote.new('test-id')
      uid = @register_api_response["RESPONSES"]["RESPONSE"]["USER"]
      expect(client.user_id).to eq(uid)
    end
  end
end
