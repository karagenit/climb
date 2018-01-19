#!/usr/bin/env ruby

require_relative '../vex/motor.rb'
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

puts "Lift Torque Required: #{torque.to_f}"
puts "-----------------------------"

print "Motor Type (CIM, mini, 775): "
motor_type = gets.chomp.downcase
print "Motor #: "
motor_cnt = gets.to_i

motor =
  case motor_type
  when "cim"
    CIM.new(motor_cnt)
  when "mini"
    MiniCIM.new(motor_cnt)
  when "775"
    Pro775.new(motor_cnt)
  else
    puts "Invalid motor type!"
  end

print "Target Amperage (total, all motors): "
amps = gets.to_i

motor_torque = Unitwise(motor.torque(current: amps), 'N.m')
ratio = (torque.to_f / motor_torque.to_f).to_i
puts "Ratio: 1:#{ratio}"
out_rpm = motor.speed(current: amps).to_f / ratio
puts "Resulting motor RPM: #{motor.speed(current: amps).to_f} -> #{out_rpm}"
circumference = 2 * Math::PI * radius.to_foot.to_f
speed = out_rpm * circumference / 60 # convert ft/min -> ft/sec, unitwise can't do this
puts "Speed: #{speed} ft/s"
