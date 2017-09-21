require 'yaml'
require 'optparse'

DEFAUILT_DOCKER_CONFIG_LOCATION = ENV['userprofile'] + "\\dockerconfig.yml"

class DockerConfig
    DOCKER_CONFIG_ALIASES_KEY = 'aliases'

    def initialize(docker_config_yaml)
        @config = docker_config_yaml
    end

    def self.from_file(path_to_config)
        DockerConfig.from_raw_config(File.open(path_to_config, "rb").read)
    end

    def self.from_raw_config(docker_config_file)
        DockerConfig.new(YAML.load(docker_config_file))
    end

    def aliases
        @config[DOCKER_CONFIG_ALIASES_KEY]
    end
end

def expand_alias_for(docker_command, alias_name, expanded_command)
    docker_command.sub(/[ ]+${alias_name}[ ]+/, " #{expanded_command} ")
end

def expand_aliases_for(docker_command, docker_config)
    docker_config.aliases
                 .map { |k, v| [k, v] }
                 .reduce(docker_command) { |command, alias_defintion| expand_alias_for(command, alias_defintion[0], alias_defintion[1]) }
end

config = DockerConfig.from_file(DEFAUILT_DOCKER_CONFIG_LOCATION)
puts expand_aliases_for("docker c ", config)


