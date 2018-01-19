#!/usr/bin/env ruby

require_relative '../vex/motor.rb'
require 'unitwise'

print "Robot Weight (lbs): "
weight = Unitwise(gets.to_f, 'pound')
print "Spool Radius (in): "
radius = Unitwise(gets.to_f, 'inch')

mass = weight.to_kg
radius = radius.to_m
accel_g = Unitwise(9.81, 'm') / (Unitwise(1, 's') ** 2)
force_g = (mass * accel_g).to_newton
torque = force_g * radius

puts "Lift Torque Required: #{torque.to_f}"

puts "40 Amp Max Calculations"
cim = CIM.new
motor_torque = Unitwise(cim.torque(current: 40), 'N.m')
ratio = torque.to_f / motor_torque.to_f
puts "Ratio: #{ratio}"

puts "Peak Power Calculations (2670 RPM)"
motor_torque = Unitwise(cim.torque(speed: 2670), 'N.m')
ratio = torque.to_f / motor_torque.to_f
puts "Ratio: #{ratio}"
