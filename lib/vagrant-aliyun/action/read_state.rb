require "log4r"
require "aliyun"

module VagrantPlugins
  module AliyunECS
    module Action
      # This action reads the state of the machine and puts it in the
      # `:machine_state_id` key in the environment.
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aliyun::action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state(env[:machine], env)

          @app.call(env)
        end

        def read_state(machine, env)
          return :not_created if machine.id.nil?

          config = env[:machine].provider_config
          options = {
            :access_key_id => config.access_key_id,
            :access_key_secret => config.access_key_secret
          }
          Aliyun.config options
          ecs = Aliyun::ECS.new
          instance = ecs.describe_instance_attribute :instance_id=>machine.id

          # Return the state
          if instance["Status"] == "Stopped"
            return :stopped
          elsif instance["Status"] == "Running"
            return :running
          elsif instance["Status"] == "Starting"
            return :starting
          else
            return :not_created
          end
        end
      end
    end
  end
end
