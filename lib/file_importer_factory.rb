# frozen_string_literal: true

# creates the correct class for the file format
class FileImporterFactory
  def initialize(publisher)
    @lookup = {
      BGBElec:
        bgb_elec(publisher),
      BGlobal:
        b_global(publisher),
      Clarity:
        clarity(publisher),
      ClaritySN:
        clarity_sn(publisher),
      DataserveElec:
        dataserve_elec(publisher),
      EDFElec:
        edf_elec(publisher),
      EDFEnergyZone:
        edf_energy_zone(publisher),
      EDFMyAccount:
        edf_my_account(publisher),
      EON:
        eon(publisher),
      G4SElec:
        g4s_elec(publisher),
      GazpromIM6:
        gazprom_im6(publisher),
      Haven:
        haven(publisher),
      Imserv:
        imserv(publisher),
      NPower:
        n_power(publisher),
      PowerGen:
        powergen(publisher),
      SSEClarity:
        sse_clarity(publisher),
      SparkElec:
        spark_elec(publisher),
      TMA:
        tma(publisher),
      UPL:
        upl(publisher),
    }
  end

  def b_global(publisher)
    SingleLineImporter.new(
      publisher,
      mpan:            0,
      date:            1,
      readings:        2..50,
      estimated_flags: false,
      header_row:      false
    )
  end

  def edf_elec(publisher)
    SingleLineImporter.new(
      publisher,
      mpan:            0,
      date:            3,
      readings:        4..100,
      estimated_flags: true,
      header_row:      false
    )
  end

  def sse_clarity(publisher)
    TripleLineImporter.new(
      publisher,
      mpan:            2,
      measurement:     4,
      date:            5,
      readings:        6..102,
      estimated_flags: true,
      header_row:      true
    )
  end

  def imserv(publisher)
    TripleLineImporter.new(
      publisher,
      mpan:            0,
      date:            1,
      measurement:     2,
      readings:        3..99,
      estimated_flags: true,
      header_row:      false
    )
  end

  def upl(publisher)
    SingleLineImporter.new(
      publisher,
      mpan:            0,
      date:            1,
      readings:        2..50,
      estimated_flags: false,
      header_row:      false
    )
  end

  def clarity(publisher)
    TripleLineImporter.new(
      publisher,
      mpan:            0,
      date:            1,
      measurement:     2,
      readings:        3..99,
      estimated_flags: true,
      header_row:      false
    )
  end

  def bgb_elec(publisher)
    SingleLineImporter.new(
      publisher,
      mpan:            0,
      date:            1,
      readings:        2..50,
      estimated_flags: false,
      header_row:      false
    )
  end

  def clarity_sn(publisher)
    SingleLineImporter.new(
      publisher,
      mpan:            0,
      date:            2,
      readings:        4..100,
      estimated_flags: true,
      header_row:      false
    )
  end

  def eon(publisher)
    SingleLineWithDifferentEstimateImporter.new(
      publisher,
      mpan:            1,
      date:            2,
      estimated_flags: 3,
      readings:        4..100,
      header_row:      true
    )
  end

  def n_power(publisher)
    SingleLineHybridImporter.new(
      publisher,
      mpan:            0,
      date:            1,
      readings:        [4..52, 53..101, 102..150],
      estimated_flags: false,
      header_row:      true
    )
  end

  def edf_energy_zone(publisher)
    SingleLineWithDifferentEstimateImporter.new(
      publisher,
      mpan:            1,
      date:            2,
      readings:        4..52,
      estimated_flags: 53..101,
      header_row:      true
    )
  end

  def spark_elec(publisher)
    SingleLineImporter.new(
      publisher,
      mpan:            1,
      date:            4,
      readings:        5..101,
      estimated_flags: true,
      header_row:      true
    )
  end

  def gazprom_im6(publisher)
    SingleLineImporter.new(
      publisher,
      mpan:            0,
      date:            2,
      readings:        5..53,
      estimated_flags: false,
      header_row:      true
    )
  end

  def g4s_elec(publisher)
    SingleLineImporter.new(
      publisher,
      mpan:            0,
      date:            2,
      readings:        3..51,
      estimated_flags: false,
      header_row:      true
    )
  end

  def powergen(publisher)
    SingleLineImporter.new(
      publisher,
      mpan:            0,
      date:            1,
      readings:        2..50,
      estimated_flags: false,
      header_row:      true
    )
  end

  def dataserve_elec(publisher)
    SingleLineImportExportImporter.new(
      publisher,
      mpan:            0,
      date:            1,
      measurement:     2,
      readings:        3..99,
      estimated_flags: true,
      header_row:      false
    )
  end

  def tma(publisher)
    SingleLineImportExportImporter.new(
      publisher,
      mpan:            0,
      date:            1,
      measurement:     2,
      readings:        3..51,
      estimated_flags: false,
      header_row:      false
    )
  end

  def edf_my_account(publisher)
    SingleLineWithDifferentEstimateImporter.new(
      publisher,
      meta:            2,
      date:            3,
      measurement:     4,
      readings:        5..53,
      estimated_flags: 54..102,
      header_row:      true
    )
  end

  def haven(publisher)
    SingleLineImporter.new(
      publisher,
      mpan:            0,
      date:            1,
      readings:        3..99,
      estimated_flags: true,
      header_row:      true
    )
  end

  def find(key)
    meta = @lookup[key.to_sym]
    raise "Invalid file format - valid options are #{@lookup.keys}" if meta.nil?
    meta
  end
end
