require_relative 'table'

class PlantEntry < TableEntry
    attr_reader :seed
    attr_reader :results

    def initialize(id, plant_data, products)
        @id = id
        @seed = plant_data
        @used = true
        @results = products[@id].treasure if products[@id]
    end

    #~ def ExportDesc(data)
    #~ end

    #~ def ExportData(data)
    #~ end
end


class Plants < Table

    def initialize(items)
        @ent_obj = PlantEntry
        @db = Hash.new(PlantEntry)

        products = PlantProducts.new()

        items.each { |i|
            next if i.type != ItemsEntry::IT_SEED

            item = PlantEntry.new(i.id,i.plant,products)

            @db[i.id]=item
        }
    end
end