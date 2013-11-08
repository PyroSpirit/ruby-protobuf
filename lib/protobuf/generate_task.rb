require 'rubygems'
require 'rake'
require 'protobuf/compiler/compiler'

module Protobuf
  class GenerateTask < Rake::TaskLib
    attr_accessor :dest_dir, :prefix
    attr_reader :output

    def initialize(*proto_paths, &block)
      init(proto_paths)

      yield self if block_given?
      define
    end

    def init(*proto_paths)
      @proto_paths = Rake::FileList.new(proto_paths)
      @dest_dir = "lib"
      @prefix = ""
      @output = []
    end

    def define
      @proto_paths.each do |protobuf|
        unless protobuf.start_with?(@prefix)
          raise ArgumentError, "Specified prefix '#{@prefix}' does not match the start of protobuf path '#{protobuf}'"
        end

        ruby_protobuf = File.join(
          @dest_dir,
          File.dirname(protobuf)[@prefix.length..-1],
          File.basename(protobuf, File.extname(protobuf)) + ".pb.rb"
        )

        compile_task = file ruby_protobuf => protobuf do
          Protobuf::Compiler.compile(protobuf, File.dirname(protobuf), File.dirname(ruby_protobuf))
        end

        task :protobuf => [ compile_task ]

        @output << ruby_protobuf
      end
    end
  end
end
