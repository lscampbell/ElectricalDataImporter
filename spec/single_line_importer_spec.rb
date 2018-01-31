require_relative '../lib/single_line_importer'
# frozen_string_literal: true
describe SingleLineImporter do
  let(:publisher) { instance_double('publisher') }
  let(:importer) { described_class.new(publisher, meta) }

  before do
    allow(publisher).to receive(:publish)
    importer.import(input)
  end

  context 'when estimate flag exists' do
    let(:input) do
      [
        '1012427125178, kWh, 20/01/2017, 145.6, A, 34.2, A, 55.3, E',
        '1012427125178, kWh, 21/01/2017, 1.6, A, 7.2, A, 2.3, E',
        '1012427125178, kWh, 22/01/2017, 4.5, A, 3.4, E, 6.8, E',
        '1012427125176, kWh, 21/01/2017, 1.6, A, 7.2, A, 2.3, E',
        '1012427125174, kWh, 22/01/2017, 4.5, A, 3.4, E, 6.8, E'
      ]
        .map { |srt| srt.split(',') }
        .map { |array| array.map { |v| v == '' ? nil : v.strip } }
    end

    let(:meta) do
      {
        mpan:            0,
        measurement:     1,
        date:            2,
        readings:        3..8,
        date_format:     '%d/%m/%Y',
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
                { start:     DateTime.new(2017, 1, 20, 0, 0),
                  end:       DateTime.new(2017, 1, 20, 0, 30),
                  kwh:       145.6,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 20, 0, 30),
                  end:       DateTime.new(2017, 1, 20, 1, 0),
                  kwh:       34.2,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 20, 1, 0),
                  end:       DateTime.new(2017, 1, 20, 1, 30),
                  kwh:       55.3,
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
                  estimated: false },
                { start:     DateTime.new(2017, 1, 21, 0, 30),
                  end:       DateTime.new(2017, 1, 21, 1, 0),
                  kwh:       7.2,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 21, 1, 0),
                  end:       DateTime.new(2017, 1, 21, 1, 30),
                  kwh:       2.3,
                  estimated: true }
              ]
      }
    end
    let(:expected_3) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 22),
        data:
              [
                { start:     DateTime.new(2017, 1, 22, 0, 0),
                  end:       DateTime.new(2017, 1, 22, 0, 30),
                  kwh:       4.5,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 22, 0, 30),
                  end:       DateTime.new(2017, 1, 22, 1, 0),
                  kwh:       3.4,
                  estimated: true },
                { start:     DateTime.new(2017, 1, 22, 1, 0),
                  end:       DateTime.new(2017, 1, 22, 1, 30),
                  kwh:       6.8,
                  estimated: true }
              ]
      }
    end
    let(:expected_4) do
      {
        mpan: '1012427125176',
        date: DateTime.new(2017, 1, 21),
        data:
              [
                { start:     DateTime.new(2017, 1, 21, 0, 0),
                  end:       DateTime.new(2017, 1, 21, 0, 30),
                  kwh:       1.6,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 21, 0, 30),
                  end:       DateTime.new(2017, 1, 21, 1, 0),
                  kwh:       7.2,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 21, 1, 0),
                  end:       DateTime.new(2017, 1, 21, 1, 30),
                  kwh:       2.3,
                  estimated: true }
              ]
      }
    end
    let(:expected_5) do
      {
        mpan: '1012427125174',
        date: DateTime.new(2017, 1, 22),
        data:
              [
                { start:     DateTime.new(2017, 1, 22, 0, 0),
                  end:       DateTime.new(2017, 1, 22, 0, 30),
                  kwh:       4.5,
                  estimated: false },
                { start:     DateTime.new(2017, 1, 22, 0, 30),
                  end:       DateTime.new(2017, 1, 22, 1, 0),
                  kwh:       3.4,
                  estimated: true },
                { start:     DateTime.new(2017, 1, 22, 1, 0),
                  end:       DateTime.new(2017, 1, 22, 1, 30),
                  kwh:       6.8,
                  estimated: true }
              ]
      }
    end

    it 'yields the correct data for the first mpan' do
      expect(publisher).to have_received(:publish).with(
        [expected_1, expected_2, expected_3]
      )
    end

    it 'yields the correct data for the second mpan' do
      expect(publisher).to have_received(:publish).with(
        [expected_4]
      )
    end

    it 'yields the correct data for the third mpan' do
      expect(publisher).to have_received(:publish).with(
        [expected_5]
      )
    end
  end
  context 'when the estimate flag does not exist' do
    let(:input) do
      [
        '1012427125178, 20/01/17, 145.6, 34.2, 55.3',
        '1012427125178, 21/01/17, 1.6, 7.2, 2.3',
        '1012427125178, 22/01/17, 4.5, 3.4, 6.8',
        '1012427125176, 21/01/17, 1.6, 7.2, 2.3',
        '1012427125174, 22/01/17, 4.5, 3.4, 6.8'
      ]
        .map { |srt| srt.split(',') }
        .map { |array| array.map { |v| v == '' ? nil : v.strip } }
    end
    let(:meta) do
      {
        mpan:            0,
        date:            1,
        readings:        2..4,
        date_format:     '%d/%m/%y',
        estimated_flags: false,
        header_row:      false
      }
    end
    let(:expected_1) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 20),
        data:
              [
                { start: DateTime.new(2017, 1, 20, 0, 0),
                  end:   DateTime.new(2017, 1, 20, 0, 30),
                  kwh:   145.6 },
                { start: DateTime.new(2017, 1, 20, 0, 30),
                  end:   DateTime.new(2017, 1, 20, 1, 0),
                  kwh:   34.2 },
                { start: DateTime.new(2017, 1, 20, 1, 0),
                  end:   DateTime.new(2017, 1, 20, 1, 30),
                  kwh:   55.3 }
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
                  kwh:   1.6 },
                { start: DateTime.new(2017, 1, 21, 0, 30),
                  end:   DateTime.new(2017, 1, 21, 1, 0),
                  kwh:   7.2 },
                { start: DateTime.new(2017, 1, 21, 1, 0),
                  end:   DateTime.new(2017, 1, 21, 1, 30),
                  kwh:   2.3 }
              ]
      }
    end
    let(:expected_3) do
      {
        mpan: '1012427125178',
        date: DateTime.new(2017, 1, 22),
        data:
              [
                { start: DateTime.new(2017, 1, 22, 0, 0),
                  end:   DateTime.new(2017, 1, 22, 0, 30),
                  kwh:   4.5 },
                { start: DateTime.new(2017, 1, 22, 0, 30),
                  end:   DateTime.new(2017, 1, 22, 1, 0),
                  kwh:   3.4 },
                { start: DateTime.new(2017, 1, 22, 1, 0),
                  end:   DateTime.new(2017, 1, 22, 1, 30),
                  kwh:   6.8 }
              ]
      }
    end
    let(:expected_4) do
      {
        mpan: '1012427125176',
        date: DateTime.new(2017, 1, 21),
        data:
              [
                { start: DateTime.new(2017, 1, 21, 0, 0),
                  end:   DateTime.new(2017, 1, 21, 0, 30),
                  kwh:   1.6 },
                { start: DateTime.new(2017, 1, 21, 0, 30),
                  end:   DateTime.new(2017, 1, 21, 1, 0),
                  kwh:   7.2 },
                { start: DateTime.new(2017, 1, 21, 1, 0),
                  end:   DateTime.new(2017, 1, 21, 1, 30),
                  kwh:   2.3 }
              ]
      }
    end
    let(:expected_5) do
      {
        mpan: '1012427125174',
        date: DateTime.new(2017, 1, 22),
        data:
              [
                { start: DateTime.new(2017, 1, 22, 0, 0),
                  end:   DateTime.new(2017, 1, 22, 0, 30),
                  kwh:   4.5 },
                { start: DateTime.new(2017, 1, 22, 0, 30),
                  end:   DateTime.new(2017, 1, 22, 1, 0),
                  kwh:   3.4 },
                { start: DateTime.new(2017, 1, 22, 1, 0),
                  end:   DateTime.new(2017, 1, 22, 1, 30),
                  kwh:   6.8 }
              ]
      }
    end

    it 'yields the correct data for the first mpan' do
      expect(publisher).to have_received(:publish).with(
        [expected_1, expected_2, expected_3]
      )
    end

    it 'yields the correct data for the second mpan' do
      expect(publisher).to have_received(:publish).with(
        [expected_4]
      )
    end

    it 'yields the correct data for the third mpan' do
      expect(publisher).to have_received(:publish).with(
        [expected_5]
      )
    end
  end
end
