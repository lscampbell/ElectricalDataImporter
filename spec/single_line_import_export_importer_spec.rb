require_relative '../lib/single_line_import_export_importer'
# frozen_string_literal: true

describe SingleLineImportExportImporter do
  before do
    allow(publisher).to receive(:publish)
    importer.import(input)
  end

  context 'when the estimated comes in one column' do
    let(:input) do
      ['1012427125178, 20/01/2017, AI, 1.6, A, 1.2, A, 5.3, E',
       '1012427125178, 21/01/2017, AI, 1.3, A, 1.1, E, 1.3, A',
       '1012427125178, 22/01/2017, AE, 4.3, A, 3.2, A, 1.1, A',
       '1012427125179, 20/01/2017, AE, 0.4, A, 0.7, A, 0.1, A',
       '1012427125179, 21/01/2017, AI, 4.3, A, 4.2, A, 4.6, A',
       '1012427125179, 22/01/2017, AI, 6.3, A, 6.2, E, 6.1, A',
       '1012427125179, 23/01/2017, AE, 0.3, A, 0.2, A, 0.7, A',]
        .map { |srt| srt.split(',') }.map { |array| array.map { |v| v == '' ? nil : v.strip } }
    end

    let(:publisher) { instance_double('publisher') }
    let(:importer) { described_class.new(publisher, meta) }
    let(:meta) do
      {
        mpan:            0,
        date:            1,
        measurement:     2,
        readings:        3..99,
        date_format: '%d/%m/%Y',
        estimated_flags: true,
        header_row:      false
      }
    end
    let(:expected_1) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 20),
        data:
              [
                { kwh:       1.6,
                  start:     DateTime.new(2017, 1, 20, 0, 0),
                  end:       DateTime.new(2017, 1, 20, 0, 30),
                  estimated: false },
                { kwh:       1.2,
                  start:     DateTime.new(2017, 1, 20, 0, 30),
                  end:       DateTime.new(2017, 1, 20, 1, 0),
                  estimated: false },
                { kwh:       5.3,
                  start:     DateTime.new(2017, 1, 20, 1, 0),
                  end:       DateTime.new(2017, 1, 20, 1, 30),
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
                { kwh:       1.3,
                  start:     DateTime.new(2017, 1, 21, 0, 0),
                  end:       DateTime.new(2017, 1, 21, 0, 30),
                  estimated: false },
                { kwh:       1.1,
                  start:     DateTime.new(2017, 1, 21, 0, 30),
                  end:       DateTime.new(2017, 1, 21, 1, 0),
                  estimated: true },
                { kwh:       1.3,
                  start:     DateTime.new(2017, 1, 21, 1, 0),
                  end:       DateTime.new(2017, 1, 21, 1, 30),
                  estimated: false }
              ]
      }
    end
    let(:expected_3) do
      {
        mpan: '1012427125179',
        date: DateTime.new(2017, 1, 21),
        data:
              [
                { kwh:       4.3,
                  start:     DateTime.new(2017, 1, 21, 0, 0),
                  end:       DateTime.new(2017, 1, 21, 0, 30),
                  estimated: false },
                { kwh:       4.2,
                  start:     DateTime.new(2017, 1, 21, 0, 30),
                  end:       DateTime.new(2017, 1, 21, 1, 0),
                  estimated: false },
                { kwh:       4.6,
                  start:     DateTime.new(2017, 1, 21, 1, 0),
                  end:       DateTime.new(2017, 1, 21, 1, 30),
                  estimated: false }
              ]
      }
    end
    let(:expected_4) do
      {
        mpan: '1012427125179',
        date: DateTime.new(2017, 1, 22),
        data:
              [
                { kwh:       6.3,
                  start:     DateTime.new(2017, 1, 22, 0, 0),
                  end:       DateTime.new(2017, 1, 22, 0, 30),
                  estimated: false },
                { kwh:       6.2,
                  start:     DateTime.new(2017, 1, 22, 0, 30),
                  end:       DateTime.new(2017, 1, 22, 1, 0),
                  estimated: true },
                { kwh:       6.1,
                  start:     DateTime.new(2017, 1, 22, 1, 0),
                  end:       DateTime.new(2017, 1, 22, 1, 30),
                  estimated: false }
              ]
      }
    end
    it 'yields the correct data for the first mpan posted' do
      expect(publisher).to have_received(:publish).with([expected_1, expected_2])
    end

    it 'yields the correct data for the second mpan posted' do
      expect(publisher).to have_received(:publish).with([expected_3, expected_4])
    end
  end
end