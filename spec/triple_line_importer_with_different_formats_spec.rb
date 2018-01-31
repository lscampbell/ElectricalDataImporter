require_relative '../lib/triple_line_importer'
# frozen_string_literal: true

describe TripleLineImporter do
  before do
    allow(publisher).to receive(:publish)
    importer.import(input)
  end

  context 'where kwh is found in the measurement column' do
    let(:input) do
      ['Some thing,1012427125178, KWH,Nothing useful, 20/01/2017, 145.6, 34.2, 55.3',
       'Some thing,1012427125178, Reactive Energy (Lag),Nothing useful, 20/01/2017, 1.6, 1.2, 1.3',
       'Some thing,1012427125178, Reactive Energy (Lead),Nothing useful, 20/01/2017, 0.3, 0.2, 0.1']
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
        header_row:      false
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

    it 'yields the correct data for mpan posted' do
      expect(publisher).to have_received(:publish).with([expected_1])
    end
  end
end
