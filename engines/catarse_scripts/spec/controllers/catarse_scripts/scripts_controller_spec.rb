require 'rails_helper'

RSpec.describe CatarseScripts::ScriptsController, type: :controller do
  routes { CatarseScripts::Engine.routes }

  described_class.define_method :current_user do
  end

  let(:current_user) { double }
  let(:policy) do
    double(can_read?: true, can_create?: true, can_update?: true, can_destroy?: true, can_execute?: true)
  end

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(ScriptPolicy).to receive(:new).with(user: current_user).and_return(policy)
  end

  describe 'GET scripts#index' do
    context 'when user has permission' do
      let!(:scripts) { create_list(:script, 5, status: :pending) }

      it 'assigns scripts to @script' do
        get :index

        expect(scripts.sort).to eq assigns(:scripts).to_a.sort
      end

      it 'renders index template' do
        get :index

        expect(response).to render_template('catarse_scripts/scripts/index')
      end
    end

    context 'when user doesn`t have permission' do
      let(:policy) { double(can_read?: false) }

      it 'raises routing error' do
        expect do
          get :index
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe 'GET scripts#show' do
    let!(:script) { create(:script) }

    context 'when user has permission' do
      it 'assigns script to @script' do
        get :show, params: { id: script.id }

        expect(assigns(:script)).to eq script
      end

      it 'renders show template' do
        get :show, params: { id: script.id }

        expect(response).to render_template('catarse_scripts/scripts/show')
      end

      it 'has http status 200' do
        get :show, params: { id: script.id }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user doesn`t have permission' do
      let(:policy) { double(can_read?: false) }

      it 'raises routing error' do
        expect do
          get :show, params: { id: script.id }
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe 'GET scripts#new' do
    context 'when user has permission' do
      it 'assigns a new script to @script' do
        get :new

        expect(assigns(:script)).to be_a_new(CatarseScripts::Script)
      end

      it 'assigns tags array to @tags' do
        get :new

        expect(assigns(:tags)).to eq CatarseScripts::Script.pluck(:tags).flatten.uniq.join(', ')
      end

      it 'renders new template' do
        get :new

        expect(response).to render_template('catarse_scripts/scripts/new')
      end

      it 'has http status 200' do
        get :new

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user doesn`t have permission' do
      let(:policy) { double(can_create?: false) }

      it 'raises routing error' do
        expect do
          get :new
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe 'POST scripts#create' do
    let(:current_user) { create(:user) }
    let(:script_params) do
      raw_tags = '[{"value":"tag1"}, { "value": "tag2"}]'
      attributes_for(:script).slice(:title, :description, :code, :ticket_url).merge(tags: raw_tags)
    end

    context 'when user has permission' do
      context 'when attributes are valid' do
        it 'creates a new script' do
          expect do
            post :create, params: { script: script_params }
          end.to change(CatarseScripts::Script, :count).by(1)
        end

        it 'redirects to script details' do
          post :create, params: { script: script_params }

          expect(response).to redirect_to(script_path(assigns(:script)))
        end

        it 'assigns current user as script creator' do
          post :create, params: { script: script_params }

          expect(assigns(:script).creator).to eq current_user
        end

        it 'sets script status to pending' do
          post :create, params: { script: script_params }

          expect(assigns(:script)).to be_pending
        end
      end

      context 'when attributes are invalid' do
        before { script_params.delete(:title) }

        it 'renders new template' do
          post :create, params: { script: script_params }

          expect(response).to render_template('catarse_scripts/scripts/new')
        end

        it 'assigns a new script to @script' do
          post :create, params: { script: script_params }

          expect(assigns(:script)).to be_a_new(CatarseScripts::Script)
        end

        it 'assigns tags array to @tags' do
          post :create, params: { script: script_params }

          expect(assigns(:tags)).to eq CatarseScripts::Script.pluck(:tags).flatten.uniq.join(', ')
        end
      end
    end

    context 'when user doesn`t have permission' do
      let(:policy) { double(can_create?: false) }

      it 'raises routing error' do
        expect do
          post :create, params: { script: script_params }
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end


  describe 'GET scripts#edit' do
    let!(:script) { create(:script) }

    context 'when user has permission' do
      it 'assigns script to @script' do
        get :edit, params: { id: script.id }

        expect(assigns(:script)).to eq script
      end

      it 'renders edit template' do
        get :edit, params: { id: script.id }

        expect(response).to render_template('catarse_scripts/scripts/edit')
      end

      it 'has http status 200' do
        get :edit, params: { id: script.id }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user doesn`t have permission' do
      let(:policy) { double(can_update?: false) }

      it 'raises routing error' do
        expect do
          get :edit, params: { id: script.id }
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe 'PUT scripts#update' do
    let!(:script) { create(:script) }
    let(:script_params) { { title: 'New Title' } }

    context 'when user has permission' do
      context 'when attributes are valid' do
        it 'updates a script' do
          put :update, params: { id: script.id , script: script_params }

          script.reload
          expect(script.title).to eq 'New Title'
        end

        it 'redirects to script details' do
          put :update, params: { id: script.id , script: script_params }

          expect(response).to redirect_to(script_path(script))
        end
      end

      context 'when attributes are invalid' do
        let(:script_params) { { title: '' } }

        it 'renders edit template' do
          put :update, params: { id: script.id , script: script_params }

          expect(response).to render_template('catarse_scripts/scripts/edit')
        end

        it 'assigns given script to @script' do
          put :update, params: { id: script.id , script: script_params }

          expect(assigns(:script)).to eq script
        end

        it 'assigns tags array to @tags' do
          put :update, params: { id: script.id , script: script_params }

          expect(assigns(:tags)).to eq CatarseScripts::Script.pluck(:tags).flatten.uniq.join(', ')
        end
      end
    end

    context 'when user doesn`t have permission' do
      let(:policy) { double(can_update?: false) }

      it 'raises routing error' do
        expect do
          put :update, params: { id: script.id , script: script_params }
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe 'DELETE scripts#destroy' do
    let!(:script) { create(:script) }

    context 'when user has permission' do
      it 'destroys givens script' do
        expect do
          delete :destroy, params: { id: script.id }
        end.to change(CatarseScripts::Script, :count).by(-1)
      end

      it 'renders index template' do
        delete :destroy, params: { id: script.id }

        expect(response).to redirect_to scripts_path
      end
    end

    context 'when user doesn`t have permission' do
      let(:policy) { double(can_destroy?: false) }

      it 'raises routing error' do
        expect do
          delete :destroy, params: { id: script.id }
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe 'POST scripts#execute' do
    let(:current_user) { create(:user) }
    let!(:script) { create(:script) }

    context 'when user has permission' do
      it 'sets current user as script executor' do
        post :execute, params: { id: script.id, executor_id: current_user.id }

        script.reload
        expect(script.executor_id).to eq current_user.id
      end

      it 'enqueues script executor job' do
        expect(CatarseScripts::ScriptExecutorJob).to receive(:perform_later).with(script.id)

        post :execute, params: { id: script.id, executor_id: current_user.id }
      end

      it 'redirects to script details' do
        post :execute, params: { id: script.id, executor_id: current_user.id }

        expect(response).to redirect_to script_path(script)
      end
    end

    context 'when user doesn`t have permission' do
      let(:policy) { double(can_execute?: false) }

      it 'raises routing error' do
        expect do
          post :execute, params: { id: script.id, executor_id: current_user.id }
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
