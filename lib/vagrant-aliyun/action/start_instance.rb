require "log4r"
require 'json'
require "aliyun"

module VagrantPlugins
  module AliyunECS
    module Action
      # This runs the configured instance.
      class StartInstance

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aliyun::action::start_instance")
        end

        def call(env)
          start_instance(env[:machine], env)

          @app.call(env)
        end

        def start_instance(machine, env)
          return nil if machine.id.nil?

          config = machine.provider_config
          options = {
            :access_key_id => config.access_key_id,
            :access_key_secret => config.access_key_secret
          }
          Aliyun.config options
          ecs = Aliyun::ECS.new

          env[:ui].info(I18n.t("vagrant_aliyun.starting"))
          ecs.start_instance :instance_id=>machine.id

          # Wait for the instance to be ready first
          env[:ui].info(I18n.t("vagrant_aliyun.waiting_for_ready"))
          begin
            instance = ecs.describe_instance_attribute :instance_id=>machine.id
            Timeout.timeout(config.instance_ready_timeout) do
              until instance["Status"] == "Running"
                sleep 2
                instance = ecs.describe_instance_attribute :instance_id=>machine.id
              end
            end
          rescue Timeout::Error
            env[:result] = false # couldn't reach state in time
            # Delete the instance
            terminate(env)

            # Notify the user
            raise Errors::InstanceReadyTimeout,
              timeout: config.instance_ready_timeout
          end

          if !env[:interrupted]
            # Wait for SSH to be ready.
            env[:ui].info(I18n.t("vagrant_aliyun.waiting_for_ssh"))
            network_ready_retries = 0
            network_ready_retries_max = 10
            while true
              # If we're interrupted then just back out
              break if env[:interrupted]
              # When an ECS instance comes up, it's networking may not be ready
              # by the time we connect.
              begin
                break if env[:machine].communicate.ready?
              rescue Exception => e
                if network_ready_retries < network_ready_retries_max then
                  network_ready_retries += 1
                  @logger.warn(I18n.t("vagrant_aliyun.waiting_for_ssh, retrying"))
                else
                  raise e
                end
              end
              sleep 2
            end

            # Ready and booted!
            env[:ui].info(I18n.t("vagrant_aliyun.ready"))
          end

          # Terminate the instance if we were interrupted
          terminate(env) if env[:interrupted]
        end

      end
    end
  end
end
