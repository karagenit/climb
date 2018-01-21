#!/usr/bin/env ruby

require 'vex-motors'
require 'unitwise'

print "Robot Weight (lbs): "
weight = Unitwise(gets.to_f, 'pound')
print "Spool Radius (in): "
radius = Unitwise(gets.to_f, 'inch')

mass = weight.to_kg
radius = radius.to_m
accel_g = Unitwise(9.81, 'meter') / (Unitwise(1, 'second') ** 2)
force_g = (mass * accel_g).to_newton
torque = force_g * radius

puts "Lift Torque Required: #{torque.to_f.round(2)} Nm"

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

  print "Target Amperage (total, all motors): "
  amps = gets.to_i

  motor_torque = Unitwise(motor.torque(current: amps), 'N.m')
  ratio = (torque.to_f / motor_torque.to_f).to_i
  puts "Ratio: 1:#{ratio}"
  out_rpm = motor.speed(current: amps).to_f / ratio
  circumference = 2 * Math::PI * radius.to_foot.to_f
  speed = out_rpm * circumference / 60 # convert ft/min -> ft/sec, unitwise can't do this
  puts "Speed: #{speed.round(2)} ft/s"
end
