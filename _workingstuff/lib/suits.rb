class SuitEntry < TableEntry

    attr_accessor :totalcount
    attr_accessor :set_items
    #attr_accessor :bonis

    def initialize(csv_row)
        super(csv_row)
        @totalcount = csv_row['totalcount'].to_i

        @set_items=[]
        for i in 1..10

            item = csv_row['suitlist'+i.to_s].to_i

            if item>0 then
                @set_items.push(item)
            end
        end

        $log << "set #{id} -> count #{@totalcount} not equal item list:#{@set_items.size}\n" if @totalcount != @set_items.size
        #p "#{id} -> more items #{@set_items.size} in set as possible #{@totalcount}" if @totalcount != @set_items.size


        @bonis=[]
        for b in 1..9
            @bonis[b] = []
            for i in 1..3
                type = csv_row["basetype#{b}_#{i}"].to_i
                value = csv_row["basetypevalue#{b}_#{i}"].to_i

                if type>0 and value>0 then
                    @bonis[b].push(type,value)

                    $log << "set #{id} -> unknown stat #{type}\n" if not $STATLIST.key?(type)
                    @has_unknown_stat=type if not $STATLIST.key?(type)
                end
            end
        end

        #~ max =0
        #~ for b in 1..9
            #~ max = b if @bonis[b][:eff].size>0
        #~ end

        #~ raise "#{id} -> more bonuses #{max+1} in set as possible #{@totalcount}" if @totalcount != max+1
    end

    def HasBonis?
        for b in 1..9
            return true if @bonis[b].size>0
        end
        return false
    end

    def IsValid?
        $log << "set #{id} -> without set items\n" if @totalcount==0

        return  ((not @has_unknown_stat) and @totalcount!=0 and HasBonis? )
    end

    def ExportDesc(data)
        for b in 1..9
            data.push( "[count]={effect}")
        end
    end

    def ExportData(data)
        for b in 1..9
            if @bonis[b].size>0 then
                data.push("[#{b}]={#{@bonis[b].join(",")}}")
            end
        end
    end

end



class Suits < Table
    FILENAME = "suitobject"

    def initialize()
        super(SuitEntry, FILENAME)
    end
end