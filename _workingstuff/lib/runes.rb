
class RunesEntry < TableEntry
    attr_accessor :bonus
    attr_accessor :level, :group

    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
        @group = 10000+csv_row['runegroup'].to_i

        raise "unknown bonus stat" if @bonus.HasInvalidStat?
#        $log.info("rune #{@id} has no name") if $de[@id].nil?
    end

    def IsValid?
        return (not @bonus.HasInvalidStat? and @bonus.HasStats?)
    end

    def ExportDesc(data)
        @bonus.ExportDesc(data)
        data.push( "grp")
    end

    def ExportData(data)
        @bonus.ExportData(data)
        data.push(@group) if @group
    end
end


class Runes < Table
    FILENAME = "runeobject"

    def initialize()
        super(RunesEntry, FILENAME)
    end

   def AssignGroup(local)

        groups = Hash.new
        each { |r|

            name = local[r.id]
            if name.nil? then
                r.NotUsed
                next
            end
            matchdata = /^(.+)\s+(\w+)$/.match(name)

            if groups.key?(r.group) then
                raise "different bonis in group #{r.group}" unless r.bonus.SameEffects?(groups[r.group][:boni])
                raise "name differs" if matchdata[1] != groups[r.group][:name]
            else
                groups[r.group] ={:boni => r.bonus, :name=>matchdata[1] }
            end
        }
    end

end