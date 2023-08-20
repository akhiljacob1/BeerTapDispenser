require 'rails_helper'

RSpec.describe 'Dispensers', type: :request do
  #----- FACTORIES -----#
  let(:dispenser) { FactoryBot.create(:dispenser, flow_volume: 0.2) }

  describe 'GET #index' do
    before do
      2.times { FactoryBot.create(:dispenser, flow_volume: 0.1) }
    end

    it 'returns a list of all dispensers' do
      get dispensers_path

      expect(response).to have_http_status(:success)
      expect(json.size).to eq(2)
      expect(json.first.keys).to match_array(%w[id flow_volume cost_per_litre status updated_at created_at])
    end
  end

  describe 'GET #show' do
    it 'returns a success response with the dispenser JSON' do
      get dispenser_path(dispenser)

      expect(response).to have_http_status(:success)
      expect(json.keys).to match_array(%w[id flow_volume cost_per_litre status updated_at created_at])
      expect(json['flow_volume']).to eq(0.2)
      expect(json['status']).to eq('closed')
    end

    it 'returns a 404 response when dispenser is not found' do
      non_existent_id = dispenser.id + 100  # Assuming this doesn't exist

      get dispenser_path(non_existent_id)

      expect(response).to have_http_status(:not_found)
      expect(json['error']).to eq('Dispenser not found')
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { dispenser: { flow_volume: 0.1, cost_per_litre: 5.5 } } }

      it 'creates a new dispenser and returns a success response' do
        expect { post dispensers_path, params: valid_params }.to change { Dispenser.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json.keys).to match_array(%w[id flow_volume cost_per_litre status updated_at created_at])
        expect(json['status']).to eq('closed')
        expect(json['flow_volume']).to eq(0.1)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { dispenser: { flow_volume: 'not_a_float', cost_per_litre: 'not_a_float' } } }

      it 'does not create a new dispenser and returns an unprocessable_entity response' do
        expect { post dispensers_path, params: invalid_params }.not_to(change { Dispenser.count })

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a new dispenser and shows an error message' do
        post dispensers_path, params: invalid_params

        expect(json['flow_volume']).to include('is not a number')
      end
    end

    it 'creates and resturns a dispenser' do
      params = { dispenser: { flow_volume: 0.1, cost_per_litre: 5.5 } }

      expect { post dispensers_path, params: }.to change { Dispenser.count }.by(1)

      expect(response).to have_http_status(:created)
      expect(json.keys).to match_array(%w[id flow_volume cost_per_litre status updated_at created_at])
      expect(json['status']).to eq('closed')
      expect(json['flow_volume']).to eq(0.1)
    end
  end

  describe 'POST #open' do
    context 'when tap is closed' do
      before { dispenser.update(status: :closed) }

      it 'creates a TapLog record and sets dispenser to open' do
        expect { post open_dispenser_path(dispenser) }.to change { TapLog.count }.by(1)

        dispenser.reload
        expect(dispenser.status).to eq('open')
      end

      it 'returns a success response and message' do
        post open_dispenser_path(dispenser)

        expect(response).to have_http_status(:success)
        expect(json['message']).to eq('Tap opened successfully.')
      end

      it 'creates a Transaction record' do
        expect { post open_dispenser_path(dispenser) }.to change { Transaction.count }.by(1)
      end
    end

    context 'when tap is already open' do
      before { dispenser.update(status: :open) }

      it 'does not create a TapLog record and keeps dispenser open' do
        expect { post open_dispenser_path(dispenser) }.not_to(change { TapLog.count })

        dispenser.reload
        expect(dispenser.status).to eq('open')
      end

      it 'returns an unprocessable_entity response with error message' do
        post open_dispenser_path(dispenser)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['message']).to eq('Tap is already open.')
      end

      it 'does not create a Transaction record' do
        expect { post open_dispenser_path(dispenser) }.not_to(change { Transaction.count })
      end
    end
  end

  describe 'POST #close' do
    context 'when tap is open' do
      before do
        dispenser.update(status: :closed)
        Timecop.freeze(DateTime.parse('3rd Sep 2023 02:00:00'))
        post open_dispenser_path(dispenser)
      end

      after { Timecop.return }

      it 'creates a TapLog record and sets dispenser to closed' do
        expect { post close_dispenser_path(dispenser) }.to change { TapLog.count }.by(1)

        dispenser.reload
        expect(dispenser.status).to eq('closed')
      end

      it 'returns a success response and message' do
        post close_dispenser_path(dispenser)

        expect(response).to have_http_status(:success)
        expect(json['message']).to eq('Tap closed successfully.')
      end

      it 'updates the Transaction record' do
        Timecop.freeze(DateTime.parse('3rd Sep 2023 02:00:06'))
        post close_dispenser_path(dispenser)

        expect(dispenser.transactions.last.total_time).to eq(6)
        expect(dispenser.transactions.last.total_volume).to eq(6 * dispenser.flow_volume)
        expect(dispenser.transactions.last.total_cost).to eq(6 * dispenser.flow_volume * dispenser.cost_per_litre)
      end

      it 'does not create a Transaction record' do
        expect { post open_dispenser_path(dispenser) }.not_to(change { Transaction.count })
      end
    end

    context 'when tap is already closed' do
      before { dispenser.update(status: :closed) }

      it 'does not create a TapLog record and keeps dispenser closed' do
        expect { post close_dispenser_path(dispenser) }.not_to(change { TapLog.count })

        dispenser.reload
        expect(dispenser.status).to eq('closed')
      end

      it 'returns an unprocessable_entity response with error message' do
        post close_dispenser_path(dispenser)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['message']).to eq('Tap is already closed.')
      end

      it 'does not create a Transaction record' do
        expect { post close_dispenser_path(dispenser) }.not_to(change { Transaction.count })
      end
    end
  end

  describe 'GET #calculate_spend' do
    context 'when tap is open' do
      before do
        dispenser.update(status: :closed)
        # Tap is open for six seconds before calculating current spend
        Timecop.freeze(DateTime.parse('3rd Sep 2023 02:00:00'))
        post open_dispenser_path(dispenser)
      end

      after { Timecop.return }

      it 'returns a success response with the current spend in JSON' do
        Timecop.freeze(DateTime.parse('3rd Sep 2023 02:00:06'))
        get calculate_spend_dispenser_path(dispenser)

        expect(response).to have_http_status(:success)
        expect(json.keys).to match_array(%w[current_spend])
        # current_spend = time * flow_rate(L/s) * cost/L
        current_spend = (6 * dispenser.flow_volume * dispenser.cost_per_litre).round(2)
        expect(json['current_spend']).to eq(current_spend)
      end

      it 'returns a 404 response when dispenser is not found' do
        non_existent_id = dispenser.id + 100  # Assuming this doesn't exist

        get calculate_spend_dispenser_path(non_existent_id)

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Tap not found')
      end
    end

    context 'when tap is closed' do
      before { dispenser.update(status: :closed) }

      it 'returns an unprocessable_entity response with an error message' do
        get calculate_spend_dispenser_path(dispenser)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['error']).to eq('Tap is not open currently.')
      end

      it 'returns a 404 response when dispenser is not found' do
        non_existent_id = dispenser.id + 100  # Assuming this doesn't exist

        get calculate_spend_dispenser_path(non_existent_id)

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Tap not found')
      end
    end
  end
end
