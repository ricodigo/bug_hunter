module BugHunter
  def self.config_path
    Dir.home+"/.bughunterrc"
  end

  def self.config
    @config ||= YAML.load_file(self.config_path)
  end
end

if !File.exist?(BugHunter.config_path)
  File.open(BugHunter.config_path, "w") do |f|
    f.write YAML.dump("username" => "admin", "password" => "admin", "enable_auth" => true)
  end

  $stdout.puts "Created #{BugHunter.config_path} with username=admin password=admin"
end
