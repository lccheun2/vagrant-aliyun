module VagrantPlugins
  module AliyunECS
    module Action
      class MessageWillNotDestroy
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t("vagrant_aliyun.will_not_destroy", name: env[:machine].name))
          @app.call(env)
        end
      end
    end
  end
end
