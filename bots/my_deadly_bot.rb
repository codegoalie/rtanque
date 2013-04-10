class MyDeadlyBot < RTanque::Bot::Brain
  NAME = 'my_deadly_bot'
  include RTanque::Bot::BrainHelper

  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 15.0
  MAX_SPEED = MAX_BOT_SPEED
  CRUISING_SPEED = MAX_SPEED / 2

  def tick!
    if @target
      # Destroy

      @target = acquire

      if @target.distance < 300
        puts "Target acquired: #{@target.name}"
        persue
        fire
      else
        ignore
        recon
      end
    else
      recon
    end
  end

  def acquire
    sensors.radar.sort_by(&:distance).first
  end

  def persue
    command.radar_heading = @target.heading
    command.turret_heading = @target.heading
    command.heading = @target.heading
    command.speed = MAX_SPEED
  end

  def fire
    if (@target.heading.delta(sensors.turret_heading)).abs < TURRET_FIRE_RANGE
      command.fire(@target.distance > 200 ? MAX_FIRE_POWER : MIN_FIRE_POWER)
    end
  end

  def ignore
    puts "Ignoring target"
    @target = nil
  end

  def recon
    puts "Initiating Recon"
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    command.speed = CRUISING_SPEED

    redirect
  end

  def redirect
    command.heading = sensors.heading + (RTanque::Heading::EIGHTH_ANGLE * (rand(3).round - 1))
  end
end
