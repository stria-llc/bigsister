require "bigsister/monitor"
require "bigsister/file_info"
require "bigsister/directory_info"

module BigSister
  class LocalMonitor < BigSister::Monitor
    def initialize(config, i)
      @config = config
      @id = i
      @path = config.fetch("path", nil)
      super(config, i)
    end

    def files
      res = Dir.entries(@path).reject { |file|
        File.directory?(File.join(@path, file))
      }.map { |file|
        file_path = File.join(@path, file)
        FileInfo.new(
          name: file,
          path: file_path,
          file_size: File.size(file_path)
        )
      }
      res
    end

    def directories
      res = Dir.entries(@path).select { |file|
        File.directory?(File.join(@path, file))
      }.reject { |dir|
        dir == "." || dir == ".."
      }.map { |dir|
        dir_path = File.join(@path, dir)
        file_count = Dir.entries(dir_path).reject { |file| File.directory?(File.join(dir_path, file)) }.size
        directory_count = Dir.entries(dir_path).select { |file| File.directory?(File.join(dir_path, file)) }.size
        DirectoryInfo.new(
          name: dir,
          path: dir_path,
          file_count: file_count,
          directory_count: directory_count
        )
      }
      res
    end
  end
end
