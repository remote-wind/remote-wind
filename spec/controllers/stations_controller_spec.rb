require 'spec_helper'

describe StationsController do

  # This should return the minimal set of attributes required to create a valid
  # Station. As you add validations to Station, be sure to
  # adjust the attributes here as well.

  let(:valid_attributes) { FactoryGirl.attributes_for(:station) }
  let(:invalid_attributes) { { :name => 'foo' } }
  let(:station) { FactoryGirl.create(:station) }

  before :each do
    Station.stub(:find_timezone).and_return('London')
  end

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
      #sign_in create(:user)
      station = create(:station)
      get :show, {:id => station.id }
      expect(assigns(:station)).to eq(station)
    end
  end

  describe "POST create" do
    context "as unpriveleged user" do
      before { sign_in create(:user) }
      it "should not allow stations to be created without authorization" do
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

    context "as unpriveleged user" do
      before { sign_in create(:user) }
      it "should not allow stations to be updated without authorization" do
        expect do
          put :update, {:id => station.to_param, :station => { "name" => "foo" }}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "as admin" do
      before { sign_in create(:admin) }

      describe "with valid params" do
        it "updates the requested station" do
          Station.any_instance.should_receive(:update).with({ "name" => "foo" })
          put :update, {:id => station.to_param, :station => { "name" => "foo" }}
        end

        it "assigns the requested station as @station" do
          put :update, {:id => station.to_param, :station => valid_attributes}
          assigns(:station).should eq(station)
        end

        it "redirects to the station" do
          put :update, {:id => station.to_param, :station => valid_attributes}
          response.should redirect_to(station)
        end
      end

      describe "with invalid params" do
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

    context "as unpriveleged user" do
      before { sign_in create(:user) }
      it "should not allow stations to be destoyed without authorization" do
        station = Station.create! valid_attributes
        expect do
          delete :destroy, {:id => station.to_param}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "as admin" do
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


    context "as unpriveleged user" do
      before { sign_in create(:user) }
      it "should not allow stations to be destoyed without authorization" do
        expect do
          delete :destroy_measures, {:station_id => station.to_param}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "as admin" do
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


end
