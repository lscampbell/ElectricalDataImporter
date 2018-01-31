require_relative '../lib/single_line_with_different_estimate_importer'
# frozen_string_literal: true

describe SingleLineWithDifferentEstimateImporter do
  before do
    allow(publisher).to receive(:publish)
    importer.import(input)
  end

  context 'when the estimated comes in one column' do
    let(:input) do
      ['Some thing, 1012427125178, 20/01/2017, AAA, 145.6, 34.2, 55.3',
       'Some thing, 1012427125178, 21/01/2017, AAE, 1.6, 1.2, 1.3',
       'Some thing, 1012427125179, 22/01/2017, EAA, 0.3, 0.2, 0.1']
        .map { |srt| srt.split(',') }.map { |array| array.map { |v| v == '' ? nil : v.strip } }
    end

    let(:publisher) { instance_double('publisher') }
    let(:importer) { described_class.new(publisher, meta) }
    let(:meta) do
      {
        mpan:            1,
        date:            2,
        estimated_flags: 3,
        readings:        4..6,
        header_row:      true
      }
    end
    let(:expected_1) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 20),
        data:
              [
                { kwh:       145.6,
                  start:     DateTime.new(2017, 1, 20, 0, 0),
                  end:       DateTime.new(2017, 1, 20, 0, 30),
                  estimated: false },
                { kwh:       34.2,
                  start:     DateTime.new(2017, 1, 20, 0, 30),
                  end:       DateTime.new(2017, 1, 20, 1, 0),
                  estimated: false },
                { kwh:       55.3,
                  start:     DateTime.new(2017, 1, 20, 1, 0),
                  end:       DateTime.new(2017, 1, 20, 1, 30),
                  estimated: false }
              ]
      }
    end
    let(:expected_2) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 21),
        data:
              [
                { kwh:       1.6,
                  start:     DateTime.new(2017, 1, 21, 0, 0),
                  end:       DateTime.new(2017, 1, 21, 0, 30),
                  estimated: false },
                { kwh:       1.2,
                  start:     DateTime.new(2017, 1, 21, 0, 30),
                  end:       DateTime.new(2017, 1, 21, 1, 0),
                  estimated: false },
                { kwh:       1.3,
                  start:     DateTime.new(2017, 1, 21, 1, 0),
                  end:       DateTime.new(2017, 1, 21, 1, 30),
                  estimated: true }
              ]
      }
    end
    let(:expected_3) do
      {
        mpan: '1012427125179',
        date: DateTime.new(2017, 1, 22),
        data:
              [
                { kwh:       0.3,
                  start:     DateTime.new(2017, 1, 22, 0, 0),
                  end:       DateTime.new(2017, 1, 22, 0, 30),
                  estimated: true },
                { kwh:       0.2,
                  start:     DateTime.new(2017, 1, 22, 0, 30),
                  end:       DateTime.new(2017, 1, 22, 1, 0),
                  estimated: false },
                { kwh:       0.1,
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
      expect(publisher).to have_received(:publish).with([expected_3])
    end
  end
  context 'when the estimated comes in a range of columns' do
    let(:input) do
      ['Some thing, 1012427125178, 20/01/2017, KWH, 145.6, 34.2, 55.3, N, N, N',
       'Some thing, 1012427125178, 21/01/2017, KWH, 1.6, 1.2, 1.3, N, N, N',
       'Some thing, 1012427125178, 22/01/2017, KWH, 0, 0, 0, E, E, E',
       'Some thing, 1012427125178, 23/01/2017, KVARH, 0, 0, 0, E, E, E',
       'Some thing, 1012427125178, 24/01/2017, KWH, 0, 0, 0, X, X, X',
       'Some thing, 1012427125179, 20/01/2017, KWH, 0.3, 0.2, 0.1, N, N, N']
        .map { |srt| srt.split(',') }.map { |array| array.map { |v| v == '' ? nil : v.strip } }
    end

    let(:publisher) { instance_double('publisher') }
    let(:importer) { described_class.new(publisher, meta) }
    let(:meta) do
      {
        mpan:            1,
        date:            2,
        measurement:     3,
        readings:        4..6,
        estimated_flags: 7..9,
        header_row:      true
      }
    end
    let(:expected_1) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 20),
        data:
              [
                { kwh:       145.6,
                  start:     DateTime.new(2017, 1, 20, 0, 0),
                  end:       DateTime.new(2017, 1, 20, 0, 30),
                  estimated: false },
                { kwh:       34.2,
                  start:     DateTime.new(2017, 1, 20, 0, 30),
                  end:       DateTime.new(2017, 1, 20, 1, 0),
                  estimated: false },
                { kwh:       55.3,
                  start:     DateTime.new(2017, 1, 20, 1, 0),
                  end:       DateTime.new(2017, 1, 20, 1, 30),
                  estimated: false }
              ]
      }
    end
    let(:expected_2) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 21),
        data:
              [
                { kwh:       1.6,
                  start:     DateTime.new(2017, 1, 21, 0, 0),
                  end:       DateTime.new(2017, 1, 21, 0, 30),
                  estimated: false },
                { kwh:       1.2,
                  start:     DateTime.new(2017, 1, 21, 0, 30),
                  end:       DateTime.new(2017, 1, 21, 1, 0),
                  estimated: false },
                { kwh:       1.3,
                  start:     DateTime.new(2017, 1, 21, 1, 0),
                  end:       DateTime.new(2017, 1, 21, 1, 30),
                  estimated: false }
              ]
      }
    end
    let(:expected_3) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 22),
        data:
              [
                { kwh:       0.0,
                  start:     DateTime.new(2017, 1, 22, 0, 0),
                  end:       DateTime.new(2017, 1, 22, 0, 30),
                  estimated: true },
                { kwh:       0.0,
                  start:     DateTime.new(2017, 1, 22, 0, 30),
                  end:       DateTime.new(2017, 1, 22, 1, 0),
                  estimated: true },
                { kwh:       0.0,
                  start:     DateTime.new(2017, 1, 22, 1, 0),
                  end:       DateTime.new(2017, 1, 22, 1, 30),
                  estimated: true }
              ]
      }
    end
    let(:expected_4) do
      {
        mpan: '1012427125179',
        date: DateTime.new(2017, 1, 20),
        data:
              [
                { kwh:       0.3,
                  start:     DateTime.new(2017, 1, 20, 0, 0),
                  end:       DateTime.new(2017, 1, 20, 0, 30),
                  estimated: false },
                { kwh:       0.2,
                  start:     DateTime.new(2017, 1, 20, 0, 30),
                  end:       DateTime.new(2017, 1, 20, 1, 0),
                  estimated: false },
                { kwh:       0.1,
                  start:     DateTime.new(2017, 1, 20, 1, 0),
                  end:       DateTime.new(2017, 1, 20, 1, 30),
                  estimated: false }
              ]
      }
    end
    it 'yields the correct data for the first mpan posted' do
      expect(publisher).to have_received(:publish).with([expected_1, expected_2, expected_3])
    end

    it 'yields the correct data for the second mpan posted' do
      expect(publisher).to have_received(:publish).with([expected_4])
    end
  end
end
