require 'fileutils'
require 'protobuf/compiler/proto_parser'
require 'protobuf/compiler/nodes'
require 'protobuf/compiler/visitors'

module Protobuf
  class Compiler
    def self.compile(proto_file, proto_dir='.', out_dir='.', file_create=true)
      self.new.compile proto_file, proto_dir, out_dir, file_create
    end

    def compile(proto_file, proto_dir='.', out_dir='.', file_create=true)
      #create_message proto_file, proto_dir, out_dir, file_create
create_rpc proto_file, proto_dir, out_dir, file_create
    end

    def create_message(proto_file, proto_dir='.', out_dir='.', file_create=true)
      rb_file = "#{out_dir}/#{proto_file.sub(/\.proto$/, '.rb')}"
      proto_path = validate_existence proto_file, proto_dir

      message_visitor = Protobuf::Visitor::CreateMessageVisitor.new proto_dir, out_dir
      File.open proto_path, 'r' do |file|
        message_visitor.visit Protobuf::ProtoParser.new.parse(file)
      end
      if file_create
        puts "#{rb_file} writing..."
        FileUtils.mkpath File.dirname(rb_file)
        File.open(rb_file, 'w') {|f| f.write message_visitor.to_s}
      else
        message_visitor.to_s
      end
    end

    def create_rpc(proto_file, proto_dir='.', out_dir='.', file_create=true)
      rb_file = "#{out_dir}/#{proto_file.sub(/\.proto$/, '.rb')}"
      proto_path = validate_existence proto_file, proto_dir

      rpc_visitor = Protobuf::Visitor::CreateRpcVisitor.new# proto_dir, out_dir
      File.open proto_path, 'r' do |file|
        rpc_visitor.visit Protobuf::ProtoParser.new.parse(file)
      end
      #if file_create
      #  puts "#{rb_file} writing..."
      #  FileUtils.mkpath File.dirname(rb_file)
      #  File.open(rb_file, 'w') {|f| f.write rpc_visitor.to_s}
      #else
        rpc_visitor.create_files rb_file, out_dir
      #end
    end

    def validate_existence(path, base_dir)
      if File.exist? path
      elsif File.exist?(path = "#{base_dir or '.'}/#{path}")
      else
        raise ArgumentError.new("File does not exist: #{path}")
      end
      path
    end
  end
end