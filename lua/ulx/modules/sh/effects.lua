if SERVER then
    util.AddNetworkString( "ulx_particles" )
    util.AddNetworkString( "ulx_particles_remove" )

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

    local particles = { "superrare_beams1", "superrare_burning1", "superrare_burning2", "superrare_circling_heart", "superrare_circling_peacesign", "superrare_circling_skull", "superrare_circling_tf", "superrare_confetti_green", "superrare_confetti_purple", "superrare_ghosts", "superrare_flies", "superrare_plasma1", "superrare_plasma2", "superrare_greenenergy", "superrare_purpleenergy", "unusual_orbit_planets", "unusual_storm", "unusual_blizzard", "unusual_smoking", "unusual_bubbles", "unusual_orbit_shells", "unusual_orbit_nutsnbolts", "unusual_orbit_fire", "unusual_orbit_fire_dark", "unusual_fullmoon_cloudy", "unusual_orbit_jack_flaming", "unusual_bubbles_green", "unusual_storm_knives", "unusual_skull_misty", "unusual_fullmoon_cloudy_green", "unusual_storm_spooky", "unusual_storm_blood" }
    concommand.Add( "particlehats_print_particles", function() PrintTable( particles ) end )
end

if CLIENT then
    -- Recursively include all .pcf files
    local files = file.Find( "particles/*.pcf", "GAME" )
    for i=1, #files do
        game.AddParticles( "particles/" .. files[i] )
    end

    -- Net hooks
    net.Receive( "ulx_particles", function()
        local target = net.ReadEntity()
        local particle = net.ReadString()
        local attachment = target:LookupAttachment( "anim_attachment_head" )
        target:StopParticleEmission()
        timer.Simple( 0, function() ParticleEffectAttach( particle, PATTACH_POINT_FOLLOW, target, attachment ) end )
    end )

    net.Receive( "ulx_particles_remove", function()
        local target = net.ReadEntity()
        target:StopParticleEmission()
    end)
end

local particles = { "superrare_beams1", "superrare_burning1", "superrare_burning2", "superrare_circling_heart", "superrare_circling_peacesign", "superrare_circling_skull", "superrare_circling_tf", "superrare_confetti_green", "superrare_confetti_purple", "superrare_ghosts", "superrare_flies", "superrare_plasma1", "superrare_plasma2", "superrare_greenenergy", "superrare_purpleenergy", "unusual_orbit_planets", "unusual_storm", "unusual_blizzard", "unusual_smoking", "unusual_bubbles", "unusual_orbit_shells", "unusual_orbit_nutsnbolts", "unusual_orbit_fire", "unusual_orbit_fire_dark", "unusual_fullmoon_cloudy", "unusual_orbit_jack_flaming", "unusual_bubbles_green", "unusual_bubbles_green", "unusual_storm_knives", "unusual_skull_misty", "unusual_fullmoon_cloudy_green", "unusual_storm_secret", "unusual_storm_spooky", "unusual_storm_blood", "generic_smoke" }

for i=1, #particles do
    PrecacheParticleSystem( particles[i] )
end

function ulx.particle( player, target, particle, should_remove )
    if should_remove then
        net.Start( "ulx_particles_remove" )
        net.WriteEntity( target )
        net.Broadcast()
        return
    end

    if not particle then
        ULib.tsayError( player, "No particle given! Particles printed to your console!" )
        ULib.console( player, table.concat( particles, ", " ) )
        return
    end

    target.ulx_particle = particle
    net.Start( "ulx_particles" )
    net.WriteEntity( target )
    net.WriteString( particle )
    net.Broadcast()

    ulx.fancyLogAdmin( player, "#A gave #T the particle effects #s!", target, particle )
end

local particle = ulx.command( "Particle Effects", "ulx particle", ulx.particle, "!particle" )
particle:addParam{ type=ULib.cmds.PlayerArg }
particle:addParam{ type=ULib.cmds.StringArg, completes=particles, error="Invalid particle! \"%s\" specified!", ULib.cmds.optional }
particle:defaultAccess( ULib.ACCESS_ADMIN )
particle:help( "Gives yourself/or a target, a tf2 particle hat effect." )
particle:setOpposite( "ulx stopparticle", {_, _, _, true}, "!stopparticle" )
