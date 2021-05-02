local entmeta = FindMetaTable("Entity")

function entmeta:Horde_AddBurst(damage, inflictor, attacker)
    if not self.Horde_BurstPower then self.Horde_BurstPower = 0 end
    self.Horde_BurstPower = self.Horde_BurstPower + damage
    if self.Horde_BurstPower >= 100 then
        self.Burstned = true
        self.Horde_BurstPower = 0
        local dmginfo = DamageInfo()
        dmginfo:SetInflictor(inflictor)
		dmginfo:SetAttacker(attacker)
		dmginfo:SetDamageType(DMG_BURN)
		dmginfo:SetDamage(50)
        util.BlastDamageInfo(dmginfo, inflictor:GetPos(), 150)
        local e = EffectData()
        e:SetOrigin(inflictor:GetPos())
        util.Effect("Explosion", e)
    end
end

hook.Add("Horde_ResetStatus", "Horde_BurstReset", function(ply)
    ply.Horde_Burst = 0
end)