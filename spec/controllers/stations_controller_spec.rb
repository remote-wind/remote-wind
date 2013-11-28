require 'spec_helper'

describe StationsController do

  # This should return the minimal set of attributes required to create a valid
  # Station. As you add validations to Station, be sure to
  # adjust the attributes here as well.

  let(:valid_attributes) { FactoryGirl.attributes_for(:station) }
  let(:invalid_attributes) { { :name => 'foo' } }
  let(:station) { FactoryGirl.create(:station, slug: 'xxx') }


  describe "GET index" do
    it "assigns all stations as @stations" do
      #sign_in create(:user)
      station = create(:station)
      get :index
      expect(assigns(:stations)).to eq([station])
    end
  end


  describe "GET show" do
    it "assigns the requested station as @station" do
      get :show, {:id => station.to_param }
      expect(assigns(:station)).to eq(station)
    end

    it "assigns measures as @measures" do
      get :show, {:id => station.to_param }
      expect(assigns(:measures)).to eq([])
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
      before { sign_in create(:admin) }

      it "destroys the requested station" do
        station = Station.create! valid_attributes
        expect {
          delete :destroy, {:id => station.to_param}
        }.to change(Station, :count).by(-1)
      end

      it "redirects to the stations list" do
        station = Station.create! valid_attributes
        delete :destroy, {:id => station.to_param}
        response.should redirect_to(stations_url)
      end
    end
  end

  describe "GET measures" do

    before :each do
      3.times do
        station.measures.create attributes_for(:measure)
      end
    end

    it "assigns station" do
      get :measures, :station_id => station.to_param
      expect(assigns(:station)).to be_a(Station)
    end

    it "assigns measures" do
      get :measures, :station_id => station.to_param
      expect(assigns(:measures).count).to eq 3
    end

  end

  describe "DELETE clear" do

    before :each do
      3.times do
        station.measures.create attributes_for(:measure)
      end
    end

    context "when an unpriveleged user" do
      before { sign_in create(:user) }
      it "does not allow measures to be destoyed" do
        expect do
          delete :destroy_measures, {:station_id => station.to_param}
        end.to_not change(Measure, :count)
        bypass_rescue
      end

      it "does not allow measures to be destoyed" do
        expect do
          bypass_rescue
          delete :destroy_measures, {:station_id => station.to_param}
        end.to raise_error CanCan::AccessDenied
      end

    end

    context "when an admin" do
      before { sign_in create(:admin) }

      it "destroys the related measures" do
        delete :destroy_measures, {:station_id => station.to_param}
        expect(Measure.where("station_id = #{station.id}").count).to eq 0
      end

      it "redirects to the station" do
        delete :destroy_measures, {:station_id => station.to_param}
        response.should redirect_to(station_url(station.to_param))
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
      expect(assigns(:stations)).to_not be_empty
    end

    it 'ranks stations by proximity' do
      # Minsk, Belarus, ca 700km from Moscow
      get :search, :lat => 53.884916, :lon => 27.53088, :radius => 1000
      expect(assigns(:stations)[0].name).to eq 'Chernobyl'
    end

    it 'finds only stations within the radius' do
      # Ankor Wat in not whithin 1000 km of Moscow or Peru
      get :search, :lat => 13.412643, :lon => 103.861782, :radius => 1000
      expect(assigns(:stations)).to be_empty
    end

    it 'renders the correct template' do
      get :search, :lat => 53.884916, :lon => 27.53088, :radius => 1000
      expect(response).to render_template :search
    end
  end

  describe "GET embed" do

    before do
      station
      get :embed, station_id: station.to_param
    end

    it "returns http success" do
      expect(response).to be_success
    end

    it "assigns station as @station" do
      expect(assigns(:station)).to eq station
    end

    it "takes a css param" do
      get :embed, station_id: station.to_param, css: "true"
      expect(assigns(:css)).to be_true
    end

    it "defaults to table type" do
      expect(assigns(:type)).to eq "table"
    end

    it "takes a type param" do
      get :embed, station_id: station.to_param, type: "chart"
      expect(assigns(:type)).to eq "chart"
    end

    it "enforces validity of type param" do
      get :embed, station_id: station.to_param, type: "gogeligook"
      expect(response).to render_template "stations/embeds/error"
    end

    it "displays a message if the type is invalid" do
      get :embed, station_id: station.to_param, type: "gogeligook"
      expect(assigns(:message)).to match /Sorry buddy, I don´t know how to render "gogeligook"/i
    end

    it "takes a height param" do
      get :embed, station_id: station.to_param, height: 300
      expect(assigns(:height)).to eq "300"
    end

    it "takes a width param" do
      get :embed, station_id: station.to_param, width: 250
      expect(assigns(:width)).to eq "250"
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

    it "should return HTTP success" do
      get :find, hw_id: station.hw_id, format: "yaml"
    end

  end
end
