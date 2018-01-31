require_relative '../lib/publisher'
require_relative '../lib/import_service_client'

describe Publisher do
  let(:client) { instance_double('ImportServiceClient') }
  let(:publisher) { described_class.new(client) }
  let(:data1) do
    {
      mpan: '1012427125178',
      date: DateTime.new(2017, 1, 20),
      data:
            [
              { start: DateTime.new(2017, 1, 20, 0, 0),
                end:   DateTime.new(2017, 1, 20, 0, 30),
                kwh: 145.6,
                lag: 1.6,
                lead: 0.3,
                estimated: false },
              { start: DateTime.new(2017, 1, 20, 0, 30),
                end:   DateTime.new(2017, 1, 20, 1, 0),
                kwh: 34.2,
                lag: 1.2,
                lead: 0.2,
                estimated: false },
              { start: DateTime.new(2017, 1, 20, 1, 0),
                end: DateTime.new(2017, 1, 20, 1, 30),
                kwh: 55.3,
                lag: 1.3,
                lead: 0.1,
                estimated: true }
            ]
    }
  end
  let(:data2) do
    {
      mpan: '1012427125178',
      date: DateTime.new(2017, 1, 21),
      data:
            [
              { start: DateTime.new(2017, 1, 21, 0, 0),
                end: DateTime.new(2017, 1, 21, 0, 30),
                kwh: 1.6,
                lag: 2.6,
                lead: 0.0,
                estimated: false },
              { start: DateTime.new(2017, 1, 21, 0, 30),
                end: DateTime.new(2017, 1, 21, 1, 0),
                kwh: 7.2,
                lag: 2.2,
                lead: 0.1,
                estimated: false },
              { start: DateTime.new(2017, 1, 21, 1, 0),
                end: DateTime.new(2017, 1, 21, 1, 30),
                kwh: 2.3,
                lag: 2.3,
                lead: 0.3,
                estimated: true }
            ]
    }
  end
  let(:data_to_publish) { [data1, data2] }
  before :each do
    allow(client).to receive(:post)
    publisher.publish(data_to_publish)
  end

  it 'publishes the first day' do
    expect(client).to have_received(:post).with('/profile', data1.to_json)
  end

  it 'publishes the second day' do
    expect(client).to have_received(:post).with('/profile', data2.to_json)
  end
end