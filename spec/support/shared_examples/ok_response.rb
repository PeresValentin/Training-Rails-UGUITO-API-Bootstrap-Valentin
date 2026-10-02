shared_examples 'ok response' do
  it 'responds with 200 status' do
    expect(response).to have_http_status(:ok)
  end
end
