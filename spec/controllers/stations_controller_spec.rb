require 'spec_helper'

describe StationsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Station. As you add validations to Station, be sure to
  # adjust the attributes here as well.

  let(:valid_params) { FactoryGirl.attributes_for(:station) }
  let(:invalid_params) { { name: 'foo' } }
  let(:station) { create(:station, slug: 'xxx', speed_calibration: 0.5) }

  before :each do
    sign_out :user
  end

  describe "GET index" do
    subject { response }
    describe "ETag" do
      before { get :index, format: 'json' }

      it "should not use the same ETag for different content types" do
        get :index, format: 'json'
        first_response = response.headers.clone
        get :index, format: 'html'
        expect(first_response['ETag']).to_not eq (response.headers['ETag'])
      end
    end

    before :each do
      station
      create(:observation, station: station, direction: 0)
      create(:observation, station: station, direction: 90)
      get :index
    end

    it "assigns all stations as @stations" do
      expect(assigns(:stations)).to eq([station])
    end

    it "renders the index template" do
      expect(response).to render_template :index
    end

    it "gets the latest observation for station" do
      expect(assigns(:stations).first.observations.loaded?).to be_truthy
    end

    it "enables CORS" do
      expect(response.headers['Access-Control-Allow-Origin']).to eq "*"
    end

    context 'http-caching' do
      subject(:last_response) do
        get :index
        response
      end
      context "given a station" do
        context "on the first request" do
          it { should have_http_status :ok }
          its(:headers) { should have_key 'ETag' }
          its(:headers) { should have_key 'Last-Modified' }

        end
        context "on a subsequent request" do

          before do
            get :index
            @etag = response.headers['ETag']
            @last_modified = response.headers['Last-Modified']
          end

          context "if it is not stale" do
            before do
              request.env['HTTP_IF_NONE_MATCH'] = @etag
              request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
            end

            it { should have_http_status :not_modified }

          end
          context "if station has been updated" do
            before do
              station.update_attribute(:last_observation_received_at, Time.now + 1.hour)
              request.env['HTTP_IF_NONE_MATCH'] = @etag
              request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
            end

            it { should have_http_status :ok }
          end
        end
      end
    end
  end

  describe "GET show" do
    it "assigns the requested station as @station" do
      get :show, id: station.to_param
      expect(assigns(:station)).to eq(station)
    end

    it "enables CORS" do
      get :show, id: station.to_param
      expect(response.headers['Access-Control-Allow-Origin']).to eq "*"
    end

    context 'given station has several measures' do
      before do
        observation = create(:observation, station: station)
        observation2 = create(:observation, station: station)
        observation2.update_attribute('created_at', 1.hour.ago)
      end

      it "orders observations by creation in descending order" do
        get :show, id: station.to_param
        expect(assigns(:observations).first.created_at).to be > assigns(:observations).last.created_at
      end
    end

    context 'http-caching' do
      subject(:last_response) do
        get :show, id: station.to_param
        response
      end

      context "on the first request" do
        it { should have_http_status :ok }
        its(:headers) { should have_key 'ETag' }
        its(:headers) { should have_key 'Last-Modified' }
      end
      context "on a subsequent request" do
        before do
          get :show, id: station.to_param
          @etag = response.headers['ETag']
          @last_modified = response.headers['Last-Modified']
        end
        context "if it is not stale" do
          before do
            request.env['HTTP_IF_NONE_MATCH'] = @etag
            request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
          end
          it { should have_http_status :not_modified }
        end
        context "if station has been updated" do
          before do
            station.update_attribute(:last_observation_received_at, Time.now + 1.hour)
            request.env['HTTP_IF_NONE_MATCH'] = @etag
            request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
            get :show, id: station.to_param
          end
          it { should have_http_status :ok }
        end
      end
    end
  end

  describe "POST create" do

    context "as unpriveleged user" do
      before { sign_in create(:user) }

      it "does not create station" do
        expect do
          post :create, {station: valid_params}
        end.to_not change(Station, :count)
      end

      it "should not allow stations to be created without authorization" do
        bypass_rescue
        expect do
          post :create, {station: valid_params}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "as admin" do
      before { sign_in create(:admin) }

      describe "with valid params" do

        let(:params) { |example|
          valid_params.merge(example.metadata[:params] || {})
        }
        before do |example|
          post :create, {station: params} unless example.metadata[:skip_request]
        end

        it "creates a new Station" do
          expect(Station.count).to eq 1
        end

        it "redirects to the created station" do
          expect(response).to redirect_to(Station.last)
        end

        it "creates a station with a custom slug", params: { slug: 'custom_slug' } do
          expect(assigns(:station).slug).to eq 'custom_slug'
        end

        it "creates a visible station when show checkbox is checked", params: { show: '1' } do
          expect(assigns(:station).show).to be_truthy
        end

        it "creates a hidden station show checkbox is unchecked", params: { show: '0' } do
          expect(assigns(:station).show).to be_falsey
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved station as @station" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Station).to receive(:save).and_return(false)
          post :create, {station: invalid_params}
          expect(assigns(:station)).to be_a_new(Station)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Station).to receive(:save).and_return(false)
          post :create, {station: invalid_params}
          expect(assigns(:station)).to render_template("new")
        end
      end
    end
  end

  describe "PUT update" do


    let!(:station) { create(:station) }

    context "as unpriveleged user, it" do
      before { sign_in create(:user) }

      it "does not change station" do
        put :update, {id: station.to_param, station: { "name" => "foo" }}
        expect(station.reload.name).to_not eq "foo"
      end

      it "does not allow stations to be updated" do
        bypass_rescue
        expect do
          put :update, {id: station.to_param, station: { "name" => "foo" }}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "when an admin" do
      before { sign_in create(:admin) }

      describe "with valid params, it" do

        let(:params) { |example| {id: station.to_param, station: { latitude: 999 }.merge(example.metadata[:params] || {}) }}

        before(:each) {
          put :update, params
        }

        it "updates the requested station", params: { name: 'foo' } do
          expect(assigns(:station).name).to eq 'foo'
        end

        it "redirects to the station" do
          expect(response).to redirect_to(station)
        end

        it "updates the assigned station" do
          expect(assigns(:station).lat).to eq 999
        end

        it "updates the slug", params: { slug: 'custom_slug' } do
          get :show, id: 'custom_slug'
          expect(response).to be_success
        end
      end

      describe "with invalid params, it" do
        before(:each) do
          allow_any_instance_of(Station).to receive(:save).and_return(false)
          put :update, {id: station.to_param, station: invalid_params}
        end

        it "assigns the station as @station" do
          expect(assigns(:station)).to eq(station)
        end

        it "re-renders the 'edit' template" do
          expect(response).to render_template "edit"
        end
      end

    end
  end

  describe "DELETE destroy" do

    let!(:station) { create(:station) }

    context "when an unpriveleged user" do
      before { sign_in create(:user) }

      it "does not destroy station" do
        expect { delete :destroy, {id: station.to_param} }.to_not change(Station, :count)
      end

      it "should not allow stations to be destoyed" do
        bypass_rescue
        expect { delete :destroy, {id: station.to_param} }.to raise_error CanCan::AccessDenied
      end
    end

    context "when an admin" do
      before(:each) { sign_in create(:admin) }

      it "destroys the requested station" do
        expect { delete :destroy, {id: station.to_param} }.to change(Station, :count).by(-1)
      end

      it "redirects to the stations list" do
        delete :destroy, {id: station.to_param}
        expect(response).to redirect_to(stations_url)
      end
    end
  end

  describe "GET search" do
    let!(:machu_pichu)  { create(:station, name: 'Machu Pichu',  lat:  -13.163392, lon:  -72.546368) }
    let!(:red_square)   { create(:station, name: 'Red Square',   lat:  55.754144,  lon:  37.620403) }
    let!(:chernobyl)    { create(:station, name: 'Chernobyl',    lat:  51.38737,   lon: 30.094887) }

    it 'finds Machu Pichu given a position 20km away' do
      get :search, lat: -13.10924, lon: -72.602146
      expect(assigns(:stations)[0].name).to eq 'Machu Pichu'
    end

    it 'takes a radius parameter' do
      # Minsk, Belarus, ca 700km from Moscow
      get :search, lat: 53.884916, lon: 27.53088, radius: 1000
      expect(assigns(:stations).count(:all)).to be > 0
    end

    it 'ranks stations by proximity' do
      # Minsk, Belarus, ca 700km from Moscow
      get :search, lat: 53.884916, lon: 27.53088, radius: 1000
      expect(assigns(:stations)[0].name).to eq 'Chernobyl'
    end

    it 'finds only stations within the radius' do
      # Ankor Wat in not whithin 1000 km of Moscow or Peru
      get :search, lat: 13.412643, lon: 103.861782, radius: 1000
      expect(assigns(:stations).count(:all)).to eq 0
    end

    it 'renders the correct template' do
      get :search, lat: 53.884916, lon: 27.53088, radius: 1000
      expect(response).to render_template :search
    end
  end

  describe "GET embed" do

    let(:params) { { id: station.to_param } }

    it "returns http success" do
      get :embed, params
      expect(response).to be_success
    end

    it "assigns station as @station" do
      get :embed, params
      expect(assigns(:station)).to eq station
    end

    it "takes a css param" do
      get :embed, params.merge!( css: "true" )
      expect(assigns(:embed_options)[:css]).to be_truthy
    end

    it "defaults to table type" do
      get :embed, params
      expect(assigns(:embed_options)[:type]).to eq "table"
    end

    it "takes a type param" do
      get :embed, params.merge!( type: "chart" )
      expect(assigns(:embed_options)[:type]).to eq "chart"
    end

    it "enforces validity of type param" do
      get :embed, params.merge!(type: "gogeligook" )
      expect(response).to render_template "stations/embeds/error"
    end

    it "displays a message if the type is invalid" do
      get :embed, params.merge!( type: "gogeligook" )
      expect(assigns(:message)).to match /Sorry buddy, I don´t know how to render "gogeligook"/i
    end

    it "takes a height param" do
      get :embed, params.merge!( height: 300 )
      expect(assigns(:embed_options)[:height]).to eq "300"
    end

    it "takes a width param" do
      get :embed, params.merge!( width: 250 )
      expect(assigns(:embed_options)[:width]).to eq "250"
    end

    it "sends X-Frame-Options header" do
      get :embed, params.merge!( width: 250 )
      expect(response.headers['X-Frame-Options']).to eq 'ALLOW-FROM http://www.gotlandssurfcenter.se'
    end

  end

  describe "GET find" do

    render_views

    let(:json) { JSON.parse(response.body) }

    before do
      station
      get :find, hw_id: station.hw_id, format: :json
    end

    it "should return HTTP success" do
      expect(response).to be_success
    end

    it "should not render a template" do
      expect(response).to render_template nil
    end

    it "contains the id" do
      expect(json["id"]).to eq station.id
    end
  end
end
