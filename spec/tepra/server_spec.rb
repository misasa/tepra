require 'spec_helper'
require 'tepra/server'
require 'rack/test'
require 'json'

RSpec.describe Tepra::Server do
  include Rack::Test::Methods

  let(:printer) { 'KING JIM WR1000' }
  let(:template) { '50x80' }

  def app
    Tepra::Server
  end

  before do
    Tepra.config = { printer: [{ name: printer, nickname: 'Lab printer', template: template }] }
  end

  it 'renders the print form with configured printers and available templates' do
    get '/', data: 'hello,world'

    expect(last_response).to be_ok
    expect(last_response.body).to include('/print', 'Lab printer', printer, template)
    expect(last_response.body).to match(/<nav\b/)
    expect(last_response.body).to match(/<form\b/)
    expect(last_response.body).to match(/<input\b[^>]*name=['"]data['"]/)
    expect(last_response.body).not_to match(/&lt;(nav|form)\b/)
  end

  it 'escapes configured printer names while rendering the form as HTML' do
    Tepra.config = { printer: [{ name: printer, nickname: '<script>alert(1)</script>' }] }

    get '/'

    expect(last_response.body).to match(/<form\b/)
    expect(last_response.body).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
    expect(last_response.body).not_to include('<script>alert(1)</script>')
  end

  it 'renders without template adapter warnings' do
    expect { get '/' }.not_to output.to_stderr
  end

  it 'shows the detected IPv4 address with the request port' do
    allow(Tepra).to receive(:ip_address).and_return(['192.0.2.10'])

    get 'http://example.org:9999/info'

    expect(last_response).to be_ok
    expect(last_response.body).to include('192.0.2.10:9999')
    expect(last_response.body).to match(/<form\b/)
  end

  it 'returns printer names, nicknames, and templates as JSON' do
    get '/printers.json'

    expect(last_response).to be_ok
    expect(last_response.content_type).to include('application/json')
    expect(JSON.parse(last_response.body)).to eq([
      { 'name' => printer, 'nickname' => 'Lab printer', 'template' => template }
    ])
  end

  it 'lists selectable templates as JSON and omits the default template' do
    get '/templates.json'

    expect(last_response).to be_ok
    expect(last_response.content_type).to include('application/json')
    expect(JSON.parse(last_response.body)).to match_array(
      %w[18x18 18x50 18x290 24x50 36x50 50x50 50x80 100x100].map { |name| { 'name' => name } }
    )
  end

  describe 'POST /print' do
    it 'passes form input and print options through and redirects to the form' do
      expect(Tepra).to receive(:print).with('id,name', { printer_name: printer, template: template })

      post '/print', data: 'id,name', printer: printer, template: template

      expect(last_response.status).to eq(302)
      expect(URI.parse(last_response['Location']).path).to eq('/')
    end

    it 'omits blank selections so the printer and template defaults apply' do
      expect(Tepra).to receive(:print).with('id,name', {})

      post '/print', data: 'id,name', printer: '', template: ''

      expect(last_response).to be_redirect
    end

    it 'redirects without printing when data is missing' do
      expect(Tepra).not_to receive(:print)

      post '/print', printer: printer

      expect(last_response).to be_redirect
    end

    it 'still redirects when the print job times out' do
      expect(Tepra).to receive(:print).with('id,name', {}).and_raise(Tepra::TimeoutError.new('timed out'))

      post '/print', data: 'id,name'

      expect(last_response.status).to eq(302)
    end
  end

  describe 'GET /Format/Print' do
    it 'combines UID and NAME and forwards printer and template selections' do
      expect(Tepra).to receive(:print).with('12345,試料', { printer_name: printer, template: template })

      get '/Format/Print', UID: '12345', NAME: '試料', printer: printer, template: template

      expect(last_response).to be_ok
    end

    it 'uses defaults when selections are absent' do
      expect(Tepra).to receive(:print).with('12345,sample', {})

      get '/Format/Print', UID: '12345', NAME: 'sample'

      expect(last_response).to be_ok
    end

    it 'forwards the printer when the template selection is blank' do
      expect(Tepra).to receive(:print).with('12345,sample', { printer_name: printer })

      get '/Format/Print', UID: '12345', NAME: 'sample', printer: printer, template: ''

      expect(last_response).to be_ok
    end

    [{ UID: '12345' }, { NAME: 'sample' }, {}].each do |params|
      it "returns OK without printing when required fields are missing from #{params.inspect}" do
        expect(Tepra).not_to receive(:print)

        get '/Format/Print', params

        expect(last_response).to be_ok
      end
    end
  end
end
