require_relative 'table'
require_relative 'items'

class KeyItemEntry < ItemsEntry

    def initialize(csv_row)
        super(csv_row)
    end

    def IsValid?
        return super()
    end

    def ExportDesc(data)
        data.push("magic")
    end

    def ExportData(data)
        data.push(@spell)
    end
end


class KeyItems < Table
    FILENAME = "keyitemobject"

    def initialize()
        super(KeyItemEntry, FILENAME)
    end

end