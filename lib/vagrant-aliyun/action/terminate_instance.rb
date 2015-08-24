require "log4r"

module VagrantPlugins
  module AliyunECS
    module Action
      # This stops the running instance.
      class TerminateInstance
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aliyun::action::terminate_instance")
        end

        def call(env)
          terminate_instance(env[:machine], env)

          @app.call(env)
        end

        def terminate_instance(machine, env)
          return nil if machine.id.nil?

          config = machine.provider_config
          options = {
            :access_key_id => config.access_key_id,
            :access_key_secret => config.access_key_secret
          }
          Aliyun.config options
          ecs = Aliyun::ECS.new

          env[:ui].info(I18n.t("vagrant_aliyun.terminating"))
          ecs.stop_instance :instance_id=>machine.id

          begin
            instance = ecs.describe_instance_attribute :instance_id=>machine.id
            Timeout.timeout(config.instance_ready_timeout) do
              until instance["Status"] == "Stopped"
                sleep 2
                instance = ecs.describe_instance_attribute :instance_id=>machine.id
              end
            end
          rescue Timeout::Error
            env[:result] = false # couldn't reach state in time
          end

          ecs.delete_instance :instance_id=>machine.id
          machine.id = nil
        end
      end
    end
  end
end
