require 'csv'
require_relative 'rom_utilities.rb'

class Table_EXP
    attr_reader :data

    def initialize()
        base_dir = TempPath()+"data/"
        base_dir = Extract("data\\","exptable.db",{:fdb_filter=>"data.fdb"}) unless File.exists?(TempPath()+"data\\exptable.db.csv")
        temp = CSV.read(base_dir+'exptable.db.csv', {:col_sep=>";", :headers=>true})

        @data = Hash.new()
        temp.each { |row| @data[row['level'].to_i] = row }
    end

    def [](level)
        return @data[level]
    end
end

