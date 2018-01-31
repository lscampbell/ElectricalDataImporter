require_relative '../lib/single_line_hybrid_importer'
# frozen_string_literal: true

describe SingleLineHybridImporter do
  before do
    allow(publisher).to receive(:publish)
    importer.import(input)
  end

  context 'when the consumption, lead & lag come out in one row' do
    let(:input) do
      ['1012427125178, 20/01/2017, 34.2, 15.6, 15.6, 3.2, 5.3, 0.1, 0.4, 0.2, 1.2, 1.3, 1.2',
       '1012427125178, 21/01/2017, 7.8, 1.8, 1.6, 1.2, 1.3, 0.2, 0.3, 0.4, 1.6, 1.8, 1.1',
       '1012427125173, 21/01/2017, 7.8, 1.8, 1.6, 1.2, 1.3, 0.2, 0.3, 0.4, 1.6, 1.8, 1.1']
        .map { |srt| srt.split(',') }.map { |array| array.map { |v| v == '' ? nil : v.strip } }
    end

    let(:publisher) { instance_double('publisher') }
    let(:importer) { described_class.new(publisher, meta) }
    let(:meta) do
      {
        mpan:            0,
        date:            1,
        readings:        [4..6, 7..9, 10..12],
        estimated_flags: false,
        header_row:      true
      }
    end
    let(:expected_1) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 20),
        data:
          [
            { kwh:   15.6,
              start: DateTime.new(2017, 1, 20, 0, 0),
              end:   DateTime.new(2017, 1, 20, 0, 30),
              lag:   0.1,
              lead:  1.2 },
            { kwh:   3.2,
              start: DateTime.new(2017, 1, 20, 0, 30),
              end:   DateTime.new(2017, 1, 20, 1, 0),
              lag:   0.4,
              lead:  1.3 },
            { kwh:   5.3,
              start: DateTime.new(2017, 1, 20, 1, 0),
              end:   DateTime.new(2017, 1, 20, 1, 30),
              lag:   0.2,
              lead:  1.2 }
          ]
      }
    end
    let(:expected_2) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 21),
        data:
          [
            { kwh:   1.6,
              start: DateTime.new(2017, 1, 21, 0, 0),
              end:   DateTime.new(2017, 1, 21, 0, 30),
              lag:   0.2,
              lead:  1.6 },
            { kwh:   1.2,
              start: DateTime.new(2017, 1, 21, 0, 30),
              end:   DateTime.new(2017, 1, 21, 1, 0),
              lag:   0.3,
              lead:  1.8 },
            { kwh:   1.3,
              start: DateTime.new(2017, 1, 21, 1, 0),
              end:   DateTime.new(2017, 1, 21, 1, 30),
              lag:   0.4,
              lead:  1.1 }
          ]
      }
    end
    let(:expected_3) do
      {
        mpan: '1012427125173',
        date: DateTime.new(2017, 1, 21),
        data:
              [
                { kwh:   1.6,
                  start: DateTime.new(2017, 1, 21, 0, 0),
                  end:   DateTime.new(2017, 1, 21, 0, 30),
                  lag:   0.2,
                  lead:  1.6 },
                { kwh:   1.2,
                  start: DateTime.new(2017, 1, 21, 0, 30),
                  end:   DateTime.new(2017, 1, 21, 1, 0),
                  lag:   0.3,
                  lead:  1.8 },
                { kwh:   1.3,
                  start: DateTime.new(2017, 1, 21, 1, 0),
                  end:   DateTime.new(2017, 1, 21, 1, 30),
                  lag:   0.4,
                  lead:  1.1 }
              ]
      }
    end

    it 'yields the correct data for first mpan posted' do
      expect(publisher).to have_received(:publish).with([expected_1, expected_2])
    end
    it 'yields the correct data for second mpan posted' do
      expect(publisher).to have_received(:publish).with([expected_3])
    end
  end
end
