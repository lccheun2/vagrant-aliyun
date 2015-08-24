require "log4r"
require "aliyun"

module VagrantPlugins
  module AliyunECS
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aliyun::action::read_ssh_info")
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env[:machine], env)

          @app.call(env)
        end

        def read_ssh_info(machine, env)
          return nil if machine.id.nil?
   
          config = env[:machine].provider_config
          options = {
            :access_key_id => config.access_key_id,
            :access_key_secret => config.access_key_secret
          }
          Aliyun.config options
          ecs = Aliyun::ECS.new
          instance = ecs.describe_instance_attribute :instance_id=>machine.id

          return { :host => instance["PublicIpAddress"]["IpAddress"][0], :port => 22 }
        end
      end
    end
  end
end
