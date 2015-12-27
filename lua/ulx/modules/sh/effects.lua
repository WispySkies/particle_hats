--[[
Coded by:
Timmy - steamcommunity.com/id/timmyws
WispySkies - steamcommunity.com/id/WispySkies
]]--

-- Base list of particles
local particles = { "superrare_beams1", "superrare_burning1", "superrare_burning2", "superrare_confetti_green", "superrare_confetti_purple", "superrare_ghosts", "superrare_flies", "superrare_plasma1", "superrare_plasma2", "superrare_greenenergy", "superrare_purpleenergy", "unusual_storm", "unusual_blizzard", "unusual_smoking", "unusual_bubbles", "unusual_orbit_nutsnbolts", "unusual_orbit_fire", "unusual_orbit_fire_dark", "unusual_bubbles_green", "unusual_storm_knives", "unusual_storm_spooky", "unusual_storm_blood" }

if SERVER then
    util.AddNetworkString( "ulx_particle" )
    util.AddNetworkString( "ulx_particle_clear" )

    hook.Add( "PlayerInitalSpawn", "ulx_particles", function( ply )
        for _, ply in pairs(player.GetAll()) do
            if ply.ulx_particle then
                net.Start( "ulx_particles" )
                net.WriteEntity( ply )
                net.WriteString( particle )
                net.Send( ply )
            end
        end
    end )

    concommand.Add( "particles_print", function()
        PrintTable( particles )
    end )
end

if CLIENT then
    -- Recursively include all .pcf files
    local files = file.Find( "particles/*.pcf", "GAME" )
    for i=1, #files do
        game.AddParticles( "particles/" .. files[i] )
    end

    -- If we're drawing the local player, we draw their particles too
    local drawingSelf = false
    local function drawOwnParticles() -- Clears particles from player view
        if not LocalPlayer().ulx_particle then return end

        if LocalPlayer():ShouldDrawLocalPlayer() and not drawingSelf then
            ParticleEffectAttach( LocalPlayer().ulx_particle, PATTACH_POINT_FOLLOW, LocalPlayer(), LocalPlayer():LookupAttachment( "anim_attachment_head" ) )
            drawingSelf = true
        elseif not LocalPlayer():ShouldDrawLocalPlayer() and drawingSelf then
            LocalPlayer():StopParticleEmission()
            drawingSelf = false
        end
    end

    -- Net hooks
    net.Receive( "ulx_particle", function()
        local target = net.ReadEntity()
        local particle = net.ReadString()
        local attachment = target:LookupAttachment( "anim_attachment_head" )
        target:StopParticleEmission()
        ParticleEffectAttach( particle, PATTACH_POINT_FOLLOW, target, attachment )
        target.ulx_particle = particle
        if target == LocalPlayer() then
            drawingSelf = true
            timer.Pause( "ulx_particles_self" )
            timer.Simple( 1, function()
                timer.Create( "ulx_particles_self", 0.25, 0, drawOwnParticles )
            end )
        end
    end )

    net.Receive( "ulx_particle_clear", function()
        local target = net.ReadEntity()
        target:StopParticleEmission()
        target.ulx_particle = nil
        if target == LocalPlayer() then
            drawingSelf = false
            timer.Destroy( "ulx_particles_self" )
        end
    end )
end

-- Precache particles to be used with !particle
for i=1, #particles do
    PrecacheParticleSystem( particles[i] )
end


function ulx.particle( player, target, particle, should_remove )
    if should_remove then
        net.Start( "ulx_particle_clear" )
        net.WriteEntity( target )
        net.Broadcast()
        ulx.fancyLogAdmin( player, "#A removed particles for #T.", target )
        return
    end

    target.ulx_particle = particle
    net.Start( "ulx_particle" )
    net.WriteEntity( target )
    net.WriteString( particle )
    net.Broadcast()

    ulx.fancyLogAdmin( player, "#A enabled the particle effect #s on #T!", target, particle )
end

local particle = ulx.command( "Particle Effects", "ulx particle", ulx.particle, "!particle" )
particle:addParam{ type=ULib.cmds.PlayerArg }
particle:addParam{ type=ULib.cmds.StringArg, completes=particles, error="Invalid particle! \"%s\" specified!", ULib.cmds.optional, ULib.cmds.restrictToCompletes }
particle:addParam{ type=ULib.cmds.BoolArg, invisible=true }
particle:defaultAccess( ULib.ACCESS_ADMIN )
particle:help( "\"Wears\" a hat with an effect from TF2." )
particle:setOpposite( "ulx stopparticle", {_, _, _, true}, "!stopparticle" )
