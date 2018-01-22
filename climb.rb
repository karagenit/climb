#!/usr/bin/env ruby

require 'vex-motors'
require 'belir'
require 'unitwise'

values = {}

print "Robot Weight (lbs): "
weight = Unitwise(gets.to_f, 'pound')
print "Spool Radius (in): "
radius = Unitwise(gets.to_f, 'inch')

values[:mass] = weight.to_kg
values[:radius] = radius.to_m
GRAVITY = Unitwise(9.81, 'meter') / (Unitwise(1, 'second') ** 2)

while true
  puts "-----------------------------"
  print "Motors: "
  input = gets.chomp.split(' ')
  motor_type = input[1].downcase
  motor_cnt = input[0].to_i

  motor =
    case motor_type
    when "cim"
      Motor::CIM.new(motor_cnt)
    when "mini"
      Motor::MiniCIM.new(motor_cnt)
    when "775"
      Motor::Pro775.new(motor_cnt)
    else
      puts "Invalid motor type!"
    end

  # required: motor, weight, radius
  # limits (give one, get the others): amps, ratio, speed
  # motor_torque, output_torque, amps, ratio, motor_rpm, output_rpm, output_speed

  equations = []

  equations.push Belir::Equation.new(:output_torque, :mass, :radius) { |mass, radius| ((mass * GRAVITY).to_newton * radius).to_f }
  equations.push Belir::Equation.new(:motor_torque, :amps) { |amps| motor.torque(current: amps) }
  equations.push Belir::Equation.new(:amps, :motor_torque) { |motor_torque| motor.current(torque: motor_torque) }
  equations.push Belir::Equation.new(:ratio, :motor_torque, :output_torque) { |motor_torque, output_torque| output_torque / motor_torque }
  equations.push Belir::Equation.new(:motor_torque, :ratio, :output_torque) { |ratio, output_torque| output_torque / ratio }
  equations.push Belir::Equation.new(:motor_rpm, :amps) { |amps| motor.speed(current: amps) }
  equations.push Belir::Equation.new(:amps, :motor_rpm) { |motor_rpm| motor.current(speed: motor_rpm) }
  equations.push Belir::Equation.new(:output_rpm, :motor_rpm, :ratio) { |motor_rpm, ratio| motor_rpm / ratio }
  equations.push Belir::Equation.new(:motor_rpm, :output_rpm, :ratio) { |output_rpm, ratio| output_rpm * ratio }
  equations.push Belir::Equation.new(:output_speed, :output_rpm, :radius) { |output_rpm, radius| output_rpm * 2 * Math::PI * radius.to_foot.to_f / 60 } # ft/s
  equations.push Belir::Equation.new(:output_rpm, :output_speed, :radius) { |output_speed, radius| output_speed * 60 / (2 * Math::PI * radius.to_foot.to_f) }

  system = Belir::System.new(*equations)

  print "Limitation (Amps, Ratio, Speed): "
  input = gets.chomp.split(' ')
  case input[1].downcase
  when "amps"
    values[:amps] = input[0].to_i
  when "ratio"
    values[:ratio] = input[0].to_i
  when "speed"
    values[:output_speed] = input[0].to_f
  else
    puts "Invalid limitation!"
  end

  values = system.solve(values)
  puts "Amps:  #{values[:amps].to_i} A"
  puts "Ratio: 1:#{values[:ratio].to_i}"
  puts "Speed: #{values[:output_speed].to_f.round(2)} ft/s"
end
