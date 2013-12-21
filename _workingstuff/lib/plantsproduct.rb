require_relative 'table'

class PlantProductEntry < TableEntry
    attr_reader :seed
    attr_reader :treasure

    def initialize(csv_row)
        super(csv_row)

        @seed = csv_row['seed'].to_i

        @treasure=[
            {
            min_water: csv_row['c1'].to_i,
            min_mature: csv_row['c2'].to_i,
            treasure_nrl: csv_row['tid1'].to_i,
            treasure_rare: csv_row['tid2'].to_i,
            treasure_unk: csv_row['tid3'].to_i,
            bonus: csv_row['bonus'].to_f
            }
        ]
    end

    def Merge(r)
        raise "illegal seed" if @seed!=r.seed
        @treasure += r.treasure
    end

    def IsValid?
        return super()
    end

    def ExportDesc(data)
    end

    def ExportData(data)
    end
end

class PlantProducts < Table
    FILENAME = "plantproduct"

    def initialize()
        super(PlantProductEntry, FILENAME)
    end

    def Load(filename)
        print("#{filename}: Extracting")
        base_dir = TempPath()+"data\\"
        base_dir = Extract("data\\","#{filename}.db",{:fdb_filter=>"data.fdb"})  unless File.exists?(base_dir+"#{filename}.db.csv")

        print(",Reading")
        csv = CSV.read(base_dir+"#{filename}.db.csv", {:col_sep=>";", :headers=>true, :converters => :numeric})

        print(",Parsing")
        csv.each { |row|
            r = @ent_obj.new(row)
            next if not r.IsValid?

            if @db.include? r.seed
                @db[r.seed].Merge(r)
            else
                @db[r.seed] = r
            end
        }

        print(",Evaluating")
        AfterLoad()

        print(",done\n")
    end
end