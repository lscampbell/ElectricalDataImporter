require_relative '../lib/triple_line_importer'
# frozen_string_literal: true

describe TripleLineImporter do
  before do
    allow(publisher).to receive(:publish)
    importer.import(input)
  end
  context 'when the estimate flag exists' do
    let(:input) do
      ['Some thing,1012427125178, Consumption,Nothing useful, 20/01/2017, 145.6, A, 34.2, A, 55.3, E',
       'Some thing,1012427125178, Consumption,Nothing useful, 21/01/2017, 1.6, A, 7.2, A, 2.3, E',
       'Some thing,1012427125178, Consumption,Nothing useful, 22/01/2017,,,,,,',
       'Some thing,1012427125178, Reactive Energy (Lag),Nothing useful, 20/01/2017, 1.6, A, 1.2, A, 1.3, E',
       'Some thing,1012427125178, Reactive Energy (Lag),Nothing useful, 21/01/2017, 2.6, A, 2.2, A, 2.3, E',
       'Some thing,1012427125178, Reactive Energy (Lag),Nothing useful, 22/01/2017,,,,,,',
       'Some thing,1012427125178, Reactive Energy (Lead),Nothing useful, 20/01/2017, 0.3, A, 0.2, A, 0.1, E',
       'Some thing,1012427125178, Reactive Energy (Lead),Nothing useful, 21/01/2017, 0.0, A, 0.1, A, 0.3, E',
       'Some thing,1012427125178, Reactive Energy (Lead),Nothing useful, 22/01/2017,,,,,,']
        .map { |srt| srt.split(',') }.map { |array| array.map { |v| v == '' ? nil : v.strip } }
    end
    let(:publisher) { instance_double('publisher') }
    let(:meta) do
      {
        mpan:            1,
        measurement:     2,
        date:            4,
        readings:        5..10,
        estimated_flags: true,
        header_row:      true
      }
    end

    let(:importer) { described_class.new(publisher, meta) }
    let(:expected_1) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 20),
        data:
              [
                { start:     DateTime.new(2017, 1, 20, 0, 0),
                  end:       DateTime.new(2017, 1, 20, 0, 30),
                  kwh:       145.6,
                  lag:       1.6,
                  lead:      0.3,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 20, 0, 30),
                  end:       DateTime.new(2017, 1, 20, 1, 0),
                  kwh:       34.2,
                  lag:       1.2,
                  lead:      0.2,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 20, 1, 0),
                  end:       DateTime.new(2017, 1, 20, 1, 30),
                  kwh:       55.3,
                  lag:       1.3,
                  lead:      0.1,
                  estimated: true }
              ]
      }
    end
    let(:expected_2) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 21),
        data:
              [
                { start:     DateTime.new(2017, 1, 21, 0, 0),
                  end:       DateTime.new(2017, 1, 21, 0, 30),
                  kwh:       1.6,
                  lag:       2.6,
                  lead:      0.0,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 21, 0, 30),
                  end:       DateTime.new(2017, 1, 21, 1, 0),
                  kwh:       7.2,
                  lag:       2.2,
                  lead:      0.1,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 21, 1, 0),
                  end:       DateTime.new(2017, 1, 21, 1, 30),
                  kwh:       2.3,
                  lag:       2.3,
                  lead:      0.3,
                  estimated: true }
              ]
      }
    end
    it 'yields the correct data for the first mpan' do
      expect(publisher).to have_received(:publish).with([expected_1, expected_2])
    end
  end

  context 'when the estimate flag does not exist' do
    let(:input) do
      ['Some thing,1012427125178, Consumption,Nothing useful, 20/01/2017, 145.6, 34.2, 55.3',
       'Some thing,1012427125178, Consumption,Nothing useful, 21/01/2017, 1.6, 7.2, 2.3',
       'Some thing,1012427125178, Consumption,Nothing useful, 22/01/2017,,,',
       'Some thing,1012427125178, Reactive Energy (Lag),Nothing useful, 20/01/2017, 1.6, 1.2, 1.3',
       'Some thing,1012427125178, Reactive Energy (Lag),Nothing useful, 21/01/2017, 2.6, 2.2, 2.3',
       'Some thing,1012427125178, Reactive Energy (Lag),Nothing useful, 22/01/2017,,,',
       'Some thing,1012427125178, Reactive Energy (Lead),Nothing useful, 20/01/2017, 0.3, 0.2, 0.1',
       'Some thing,1012427125178, Reactive Energy (Lead),Nothing useful, 21/01/2017, 0.0, 0.1, 0.3',
       'Some thing,1012427125178, Reactive Energy (Lead),Nothing useful, 22/01/2017,,,']
        .map { |srt| srt.split(',') }.map { |array| array.map { |v| v == '' ? nil : v.strip } }
    end
    let(:publisher) { instance_double('publisher') }
    let(:meta) do
      {
        mpan:            1,
        measurement:     2,
        date:            4,
        readings:        5..7,
        estimated_flags: false,
        header_row:      true
      }
    end

    let(:importer) { described_class.new(publisher, meta) }
    let(:expected_1) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 20),
        data:
              [
                { start: DateTime.new(2017, 1, 20, 0, 0),
                  end:   DateTime.new(2017, 1, 20, 0, 30),
                  kwh:   145.6,
                  lag:   1.6,
                  lead:  0.3 },
                { start: DateTime.new(2017, 1, 20, 0, 30),
                  end:   DateTime.new(2017, 1, 20, 1, 0),
                  kwh:   34.2,
                  lag:   1.2,
                  lead:  0.2 },
                { start: DateTime.new(2017, 1, 20, 1, 0),
                  end:   DateTime.new(2017, 1, 20, 1, 30),
                  kwh:   55.3,
                  lag:   1.3,
                  lead:  0.1 }
              ]
      }
    end
    let(:expected_2) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 21),
        data:
              [
                { start: DateTime.new(2017, 1, 21, 0, 0),
                  end:   DateTime.new(2017, 1, 21, 0, 30),
                  kwh:   1.6,
                  lag:   2.6,
                  lead:  0.0 },
                { start: DateTime.new(2017, 1, 21, 0, 30),
                  end:   DateTime.new(2017, 1, 21, 1, 0),
                  kwh:   7.2,
                  lag:   2.2,
                  lead:  0.1 },
                { start: DateTime.new(2017, 1, 21, 1, 0),
                  end:   DateTime.new(2017, 1, 21, 1, 30),
                  kwh:   2.3,
                  lag:   2.3,
                  lead:  0.3 }
              ]
      }
    end
    it 'yields the correct data for the first mpan' do
      expect(publisher).to have_received(:publish).with([expected_1, expected_2])
    end
  end
end
