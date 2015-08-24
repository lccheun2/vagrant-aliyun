require "log4r"

module VagrantPlugins
  module AliyunECS
    module Action
      # This stops the running instance.
      class StopInstance
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aliyun::action::stop_instance")
        end

        def call(env)
          stop_instance(env[:machine], env)

          @app.call(env)
        end

        def stop_instance(machine, env)
          return nil if machine.id.nil?

          config = machine.provider_config
          options = {
            :access_key_id => config.access_key_id,
            :access_key_secret => config.access_key_secret
          }
          Aliyun.config options
          ecs = Aliyun::ECS.new

          if machine.state.id == :stopped
            env[:ui].info(I18n.t("vagrant_aliyun.already_status", :status => machine.state.id))
          else
            env[:ui].info(I18n.t("vagrant_aliyun.stopping"))
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
          end

        end
      end
    end
  end
end
