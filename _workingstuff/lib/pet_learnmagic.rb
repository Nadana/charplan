require 'csv'
require_relative 'rom_utilities'

class PET_LearnmagicEntry
    attr_reader :level
    attr_reader :skill
    attr_reader :skill_level

    def initialize(csv_row)
        @level = csv_row['pet_level'].to_i
        @skill = csv_row['skill'].to_i
        @skill_level = csv_row['skill_level'].to_i
    end

     def ExportDesc(data)
        data.push("level")
        data.push("skill")
        data.push("skill_level")
    end

    def ExportData(data)
        data.push(@level)
        data.push(@skill)
        data.push(@skill_level)
    end
end

class PET_Learnmagic  < Table
    FILENAME = "cultivatepetlearnmagic"

    def initialize()
        super(PET_LearnmagicEntry, FILENAME)
    end

end