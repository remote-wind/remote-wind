require 'spec_helper'

describe StationsController do

  # This should return the minimal set of attributes required to create a valid
  # Station. As you add validations to Station, be sure to
  # adjust the attributes here as well.

  let(:valid_attributes) { FactoryGirl.attributes_for(:station) }
  let(:invalid_attributes) { { :name => 'foo' } }
  let(:station) { create(:station, slug: 'xxx', speed_calibration: 0.5) }

  before :each do
    sign_out :user
  end

  describe "GET index" do

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
      expect(assigns(:stations).first.latest_observation.direction).to eq 90
    end

    context 'http-caching' do

      subject(:last_response) do
        get :index
        response
      end

      context "given a station" do
        context "on the first request" do
          its(:code) { should eq '200' }
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

            its(:code) { should eq '304' }
          end
          context "if station has been updated" do
            before do
              station.update_attribute(:last_observation_received_at, Time.now + 1.hour)
              request.env['HTTP_IF_NONE_MATCH'] = @etag
              request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
            end
            its(:code) { should eq '200' }
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
        its(:code) { should eq '200' }
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

          its(:code) { should eq '304' }
        end
        context "if station has been updated" do
          before do
            station.update_attribute(:last_observation_received_at, Time.now + 1.hour)
            request.env['HTTP_IF_NONE_MATCH'] = @etag
            request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
            get :show, id: station.to_param
          end

          it "should return 200/OK" do
            expect(response.code).to eq '200'
          end


        end
      end
    end
  end

  describe "POST create" do
    context "as unpriveleged user" do
      before { sign_in create(:user) }

      it "does not create station" do
        expect do
          post :create, {:station => valid_attributes}
        end.to_not change(Station, :count)
      end

      it "should not allow stations to be created without authorization" do
        bypass_rescue
        expect do
          post :create, {:station => valid_attributes}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "as admin" do
      before { sign_in create(:admin) }

      describe "with valid params" do
        it "creates a new Station" do
          expect {
            post :create, {:station => valid_attributes}
          }.to change(Station, :count).by(1)
        end

        it "assigns a newly created station as @station" do
          post :create, {:station => valid_attributes}
          expect(assigns(:station)).to be_a(Station)
          expect(assigns(:station)).to be_persisted
        end

        it "redirects to the created station" do
          post :create, {:station => valid_attributes}
          expect(response).to redirect_to(Station.last)
        end

        it "creates a station with a custom slug" do
          valid_attributes[:slug] = 'custom_slug'
          post :create, {:station => valid_attributes}
          get :show, id: 'custom_slug'
          expect(response).to be_success
        end

        it "creates a visible station" do
          valid_attributes[:show] = "yes"
          post :create, {:station => valid_attributes}
          expect(assigns(:station).show).to be_true
        end

        it "creates a hidden station" do
          valid_attributes[:show] = "no"
          post :create, {:station => valid_attributes}
          expect(assigns(:station).show).to be_false
        end

      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved station as @station" do
          # Trigger the behavior that occurs when invalid params are submitted
          Station.any_instance.stub(:save).and_return(false)
          post :create, {:station => invalid_attributes}
          expect(assigns(:station)).to be_a_new(Station)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Station.any_instance.stub(:save).and_return(false)
          post :create, {:station => invalid_attributes}
          expect(assigns(:station)).to render_template("new")
        end
      end
    end
  end

  describe "PUT update" do

    context "as unpriveleged user, it" do
      before { sign_in create(:user) }

      it "does not change station" do
        station = Station.create(attributes_for(:station))
        put :update, {:id => station.to_param, :station => { "name" => "foo" }}
        expect(station.reload.name).to_not eq "foo"
      end

      it "does not allow stations to be updated" do
        bypass_rescue
        station = Station.create(attributes_for(:station))
        expect do
          put :update, {:id => station.to_param, :station => { "name" => "foo" }}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "when an admin" do
      before { sign_in create(:admin) }

      describe "with valid params, it" do

        it "updates the requested station" do
          Station.any_instance.should_receive(:update).with({ "name" => "foo" })
          put :update, {:id => station.to_param, :station => { "name" => "foo" }}
        end

        it "assigns the requested station as @station" do
          put :update, {:id => station.to_param, :station => { latitude: 999 }}
          assigns(:station).should eq(station)
        end

        it "redirects to the station" do
          put :update, {:id => station.to_param, :station => { latitude: 999 }}
          response.should redirect_to(station)
        end

        it "updates the assigned station" do
          put :update, {:id => station.to_param, :station => { latitude: 999 }}
          expect(assigns(:station).lat).to eq 999
        end

        it "updates the slug" do
          put :update, {:id => station.to_param, :station => { slug: 'custom_slug' }}
          get :show, id: 'custom_slug'
          expect(response).to be_success
        end

        it "makes station hidden when show = no" do
          station.show = true
          station.save!
          put :update, {:id => station.to_param, :station => { show: 'no' }}
          expect(assigns(:station).show).to be_false
        end

        it "makes station visible when show = yes" do
          station.show = false
          station.save!
          put :update, {:id => station.to_param, :station => { show: 'yes' }}
          expect(assigns(:station).show).to be_true
        end

      end

      describe "with invalid params, it" do
        it "assigns the station as @station" do
          station = Station.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          Station.any_instance.stub(:save).and_return(false)
          put :update, {:id => station.to_param, :station => invalid_attributes}
          assigns(:station).should eq(station)
        end

        it "re-renders the 'edit' template" do
          station = Station.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          Station.any_instance.stub(:save).and_return(false)
          put :update, {:id => station.to_param, :station => invalid_attributes}
          response.should render_template("edit")
        end
      end

    end
  end

  describe "DELETE destroy" do

    context "when an unpriveleged user" do
      before { sign_in create(:user) }

      it "does not destroy station" do
        station = Station.create! valid_attributes
        expect do
          delete :destroy, {:id => station.to_param}
        end.to_not change(Station, :count)
      end

      it "should not allow stations to be destoyed" do
        bypass_rescue
        station = Station.create! valid_attributes
        expect do
          delete :destroy, {:id => station.to_param}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "when an admin" do

      let!(:station) { create(:station) }

      before(:each) do
        sign_in create(:admin)

      end

      it "destroys the requested station" do
        expect {
          delete :destroy, {:id => station.to_param}
        }.to change(Station, :count).by(-1)
      end

      it "redirects to the stations list" do
        delete :destroy, {:id => station.to_param}
        response.should redirect_to(stations_url)
      end

    end
  end

  describe "GET search" do
    let!(:machu_pichu)  { create(:station, name: 'Machu Pichu',  lat:  -13.163392, lon:  -72.546368) }
    let!(:red_square)   { create(:station, name: 'Red Square',   lat:  55.754144,  lon:  37.620403) }
    let!(:chernobyl)    { create(:station, name: 'Chernobyl',    lat:  51.38737,   lon: 30.094887) }

    it 'finds Machu Pichu given a position 20km away' do
      get :search, :lat => -13.10924, :lon => -72.602146
      expect(assigns(:stations)[0].name).to eq 'Machu Pichu'
    end

    it 'takes a radius parameter' do
      # Minsk, Belarus, ca 700km from Moscow
      get :search, :lat => 53.884916, :lon => 27.53088, :radius => 1000
      expect(assigns(:stations).count(:all)).to be > 0
    end

    it 'ranks stations by proximity' do
      # Minsk, Belarus, ca 700km from Moscow
      get :search, :lat => 53.884916, :lon => 27.53088, :radius => 1000
      expect(assigns(:stations)[0].name).to eq 'Chernobyl'
    end

    it 'finds only stations within the radius' do
      # Ankor Wat in not whithin 1000 km of Moscow or Peru
      get :search, :lat => 13.412643, :lon => 103.861782, :radius => 1000
      expect(assigns(:stations).count(:all)).to eq 0
    end

    it 'renders the correct template' do
      get :search, :lat => 53.884916, :lon => 27.53088, :radius => 1000
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
      expect(assigns(:embed_options)[:css]).to be_true
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
  end

  describe "GET find" do
    before do
      station
    end

    it "should return HTTP success" do
      get :find, hw_id: station.hw_id, format: "yaml"
      expect(response).to be_success
    end

    it "should not render a template" do
      get :find, hw_id: station.hw_id, format: "yaml"
      expect(response).to render_template nil
    end
  end

  describe "PUT edit_balance" do

    before :each do
      station
    end




    context 'with valid params' do

      let(:params) { { id: station.id, s: { b: 90 } } }


      it "should take b (balance) parameter" do
        put :update_balance, params
        expect(assigns(:station).balance).to eq 90
      end

      it "should update balance" do
        put :update_balance, params
        station.reload
        expect(station.balance).to eq 90
      end

      it "should return 200/OK with valid input" do
        put :update_balance, params
        expect(response.status).to eq 200
      end

      it "should check station balance" do
        Station.any_instance.should_receive(:check_balance)
        put :update_balance, params
      end

    end



    it "should return 422 - Unprocessable Entity when given an invalid balance" do
      put :update_balance, id: station.id, s: { b: "nan" }
      expect(response.status).to eq 422
    end

    it "should log error if given an invalid balance" do
      Rails.logger.should_receive(:error).with("Someone attemped to update #{station.name} balance with invalid data ('nan') from 0.0.0.0")
      put :update_balance, id: station.id, s: { b: "nan" }
    end



  end
end
