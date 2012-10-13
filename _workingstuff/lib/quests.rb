require_relative 'table'

#EXAMPLE:
#~ xp = Table_EXP.new()
#~ de = Locales.new("de")
#~ quests = Quests.new()
#~ quests.MarkUnusedIfNameInvalid(de)
#~ quests.Export("quests.lua",xp)

class QuestEntry < TableEntry
    attr_accessor :rawdata
    attr_accessor :postquest
    attr_accessor :perquisite
    attr_accessor :start_npcs
    attr_accessor :requests
    attr_accessor :reward

    def initialize(row)
        super(row)
        @rawdata=row

        @postquest=[]
        @perquisite=[]
        for n in ("icheck_objid1".."icheck_objid5")
            qid = row[n].to_i
            @perquisite.push(qid) if qid>0
        end

        @start_npc=[]
        for i in ("iquest_starter1".."iquest_starter5")
            n_id=row[i].to_i
            @start_npc.push(n_id) if n_id>100
        end

        GetRequests(row)
        GetReward(row)
    end

    def IsValid?
        return super()
        #qname = $text[@id]
        #return qname.nil?
    end

    def GetRequests(csv)
        @requests=[]
        for i in 1..10
            item = csv['irequest_itemid'+i.to_s].to_i
            if item>0 then
                prefix =csv['irequest_itemstr'+i.to_s].to_i
                count = csv['irequest_itemval'+i.to_s].to_i
                @requests.push( {:prefix=>prefix,:item=>item,:count=>count} )
            end
        end

        for i in 1..10
            item = csv['irequest_killid'+i.to_s].to_i
            if item>0 then
                prefix =csv['irequest_killstr'+i.to_s].to_i+16
                count = csv['irequest_killval'+i.to_s].to_i
                @requests.push( {:prefix=>prefix,:item=>item,:count=>count} )
            end
        end
    end

    def GetReward(csv)
        @reward=[]

        for i in 1..5
            item = csv['ireward_choiceid'+i.to_s].to_i
            count= csv['ireward_choiceval'+i.to_s].to_i
            if item>0 and count>0 then
                @reward.push( {:item=>item,:count=>count} )
            end
        end

        for i in 1..5
            item = csv['ireward_itemid'+i.to_s].to_i
            count= csv['ireward_itemval'+i.to_s].to_i
            if item>0 and count>0 then
                @reward.push( {:item=>item,:count=>-count} )
            end
        end
    end

    def SetAsFollowerOf(qid)
        @postquest.push(qid)
    end

    def level
        @rawdata["icheck_lv"].to_i
    end

    def level_min
        @rawdata["icheck_lowerlv"]
    end

    def level_max
        @rawdata["icheck_higherlv"]
    end

    def IsLoopable?
        @rawdata["icheck_loop"].to_i>0
    end

    def reward_npc
        npc = @rawdata["irequest_questid"].to_i
        return npc if npc>100
    end

    def reward_exp(exp_vals)
        return (@rawdata["ireward_exp"].to_i * exp_vals["quest_xp_base"].to_i )  /  100
    end

    def reward_money(exp_vals)
        return (@rawdata["ireward_money"].to_i * exp_vals["quest_money_base"].to_i ) / 100
    end

    def catalog
        @rawdata["iquest_catalog"]
    end

    def ExportDesc(data)
        data.push("lvl","lvl_min","lvl_max")
        data.push("npc_reward")
        data.push("npc_start")
        data.push("catalog")
        data.push("pre-quest")
        data.push("pre-flags")
        data.push("post-quest")
        data.push("reward_exp")
        data.push("reward_money")
        data.push("reward_items")
        data.push("reward_item_count")
        data.push("goal_prefix_text")
        data.push("goal_id")
        data.push("goal_count")
        data.push("loopable")
    end

    def ExportData(data, table_quest, table_xp)
        data.push( level,level_min,level_max)   # levels
        data.push( Val(reward_npc) )
        data.push( FormatArray(@start_npcs) )
        data.push( catalog )

        # Prequisit-Quest
        prequest = []
        preobj = []
        @perquisite.each do |pq|
            if table_quest.include?(pq) then
                prequest.push(pq)
            else
                preobj.push(pq)
            end
        end
        data.push(FormatArray(prequest))
        data.push(FormatArray(preobj))

        #follower
        data.push(FormatArray(@postquest))

        #reward
        exp_vals = table_xp[level]
        if exp_vals.nil? then
            data.push(0,0)
        else
            data.push( reward_exp(exp_vals) , reward_money(exp_vals) )
        end

        data.push(FormatArray(@reward.collect {|p| p[:item]},true))
        data.push(FormatArray(@reward.collect {|p| p[:count]},true))

        # goals
        data.push(FormatArray(@requests.collect {|p| p[:prefix]},true))
        data.push(FormatArray(@requests.collect {|p| p[:item]},true))
        data.push(FormatArray(@requests.collect {|p| p[:count]},true))

        data.push( Val(IsLoopable?) ) # Loop-able
    end

end

class Quests < Table
    FILENAME = "questdetailobject"

    def initialize()
        super(QuestEntry, FILENAME)
    end

    def ExportEntry(entry)
        dest = []
        entry.ExportData(dest,self,@table_xp)
        return dest
    end

    def Export(filename, table_xp)
        @table_xp = table_xp
        super(filename)
    end
end






