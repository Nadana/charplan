
class AddPowerEntry < TableEntry

    FILENAME = "addpowerobject"
    attr_accessor :bonus
    attr_accessor :group

    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)

        raise "unknown bonus stat" if @bonus.HasInvalidStat?
#        $log.info("addpower #{@id} has no name") if $de[@id].nil?
    end

    def IsValid?
        return ((not @bonus.HasInvalidStat?) and @bonus.HasStats?)
    end

    def ExportDesc(data)
        @bonus.ExportDesc(data)
        data.push( "grp")
    end

    def ExportData(data)
        @bonus.ExportData(data)
        data.push(@group)  if @group
    end
end


class AddPower < Table

    FILENAME = "addpowerobject"

    def initialize()
        super(AddPowerEntry, FILENAME)
    end

    def AssignGroup(local)

        groups = Hash.new
        grp_idx = 1
        each { |r|

            name = local[r.id]
            next if name.nil?
            matchdata = /^(.+)\s+(\w+)$/.match(name)
            name = matchdata[1] if not matchdata.nil?

            if groups.key?(name) then
                found = nil
                groups[name].each { |gid,boni|
                    found = gid if boni.SameEffects?(r.bonus)
                }
                if found then
                    r.group = found
                else
                    groups[name][grp_idx] = r.bonus
                    r.group = grp_idx
                    grp_idx += 1
                end
            else
                groups[name] = {[grp_idx] => r.bonus}
                r.group = grp_idx
                grp_idx += 1
            end
        }
    end

end