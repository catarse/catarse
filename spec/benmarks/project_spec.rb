# coding: utf-8
# Uncomment to run ;) we don't need to run this in every test
# require 'rails_helper'
#
# class FakeProject
#   @@routes = Rails.application.routes.routes
#
#   def self.permalink_on_routes_new_way?(permalink)
#     permalink && self.get_routes_new_way.include?(permalink.downcase)
#   end
#
#   def self.get_routes_new_way
#     @@mapped_routes ||= @@routes.inject(Set.new) do |memo, item|
#       memo << $1 if item.path.spec.to_s.match /^\/([\w]+)\S/
#       memo
#     end
#   end
#
#   def self.permalink_on_routes_old_way?(permalink)
#     permalink && self.get_routes_without_old_way.include?(permalink.downcase)
#   end
#
#   def self.get_routes_without_old_way
#     routes = Rails.application.routes.routes.map do |r|
#       r.path.spec.to_s.split('/').second.to_s
#     end
#
#     routes.compact.uniq.reject(&:empty?)
#   end
# end
#
#
# RSpec.describe Project, type: :perfomance do
#   before { require 'benchmark' }
#
#   #         user       system     total     real
#   # Cached  0.010000   0.000000   0.010000  (  0.010875)
#   # OldWay  8.460000   0.080000   8.540000  (  8.635963)
#   describe ".get_routes" do
#     it "Takes time" do
#       Benchmark.bm do |x|
#         x.report("Cached") do
#           3_000.times do
#             FakeProject.permalink_on_routes_new_way? 'projects'
#           end
#         end
#
#         x.report("OldWay") do
#           3_000.times do
#             FakeProject.permalink_on_routes_old_way? 'projects'
#           end
#         end
#       end
#     end
#   end
# end
