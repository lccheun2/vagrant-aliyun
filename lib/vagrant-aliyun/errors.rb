require "vagrant"

module VagrantPlugins
  module AliyunECS
    module Errors
      class VagrantAliyunError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_aliyun.errors")
      end

      class InstanceReadyTimeout < VagrantAliyunError
        error_key(:instance_ready_timeout)
      end

      class RsyncError < VagrantAliyunError
        error_key(:rsync_error)
      end

      class MkdirError < VagrantAliyunError
        error_key(:mkdir_error)
      end

    end
  end
end
