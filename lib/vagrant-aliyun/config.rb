require "vagrant"

module VagrantPlugins
  module AliyunECS
    class Config < Vagrant.plugin("2", :config)
      
      attr_accessor :access_key_id
      attr_accessor :access_key_secret
      attr_accessor :region_id
      attr_accessor :image_id
      attr_accessor :instance_type
      attr_accessor :internet_max_bandwidth_out
      attr_accessor :security_group_id
      attr_accessor :password
      attr_accessor :instance_charge_type
      attr_accessor :instance_period
      attr_accessor :instance_ready_timeout

      def initialize()
        @access_key_id = UNSET_VALUE
        @access_key_secret = UNSET_VALUE
        @region_id = UNSET_VALUE
        @image_id = UNSET_VALUE
        @instance_type = UNSET_VALUE
        @internet_max_bandwidth_out = UNSET_VALUE
        @security_group_id = UNSET_VALUE
        @password = UNSET_VALUE
        @instance_charge_type = UNSET_VALUE
        @instance_period = UNSET_VALUE
        @instance_ready_timeout = UNSET_VALUE
      end

      def finalize!
        @access_key_id = nil if @access_key_id == UNSET_VALUE
        @access_key_secret = nil if @access_key_secret == UNSET_VALUE
        @region_id = nil if @region_id == UNSET_VALUE
        @image_id = nil if @image_id == UNSET_VALUE
        @instance_type = nil if @instance_type == UNSET_VALUE
        @internet_max_bandwidth_out = nil if @internet_max_bandwidth_out == UNSET_VALUE
        @security_group_id = nil if @security_group_id == UNSET_VALUE
        @password = nil if @password == UNSET_VALUE
        @instance_charge_type = nil if @instance_charge_type == UNSET_VALUE
        @instance_period = nil if @instance_period == UNSET_VALUE
        @instance_ready_timeout = 120 if @instance_ready_timeout == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors
        errors << I18n.t("vagrant_aliyun.config.access_key_id_required") if @access_key_id.nil?
        errors << I18n.t("vagrant_aliyun.config.access_key_secret_required") if @access_key_secret.nil?
        errors << I18n.t("vagrant_aliyun.config.region_id_required") if @region_id.nil?
        errors << I18n.t("vagrant_aliyun.config.image_id_required") if @image_id.nil?
        errors << I18n.t("vagrant_aliyun.config.instance_type_required") if @instance_type.nil?
        errors << I18n.t("vagrant_aliyun.config.internet_max_bandwidth_out_required") if @internet_max_bandwidth_out.nil?
        errors << I18n.t("vagrant_aliyun.config.security_group_id_required") if @security_group_id.nil?
        errors << I18n.t("vagrant_aliyun.config.password_required") if @password.nil?
        errors << I18n.t("vagrant_aliyun.config.instance_charge_type_required") if @instance_charge_type.nil?
        if @instance_charge_type != nil && @instance_charge_type == 'PrePaid' && @instance_period == nil
          errors << I18n.t("vagrant_aliyun.config.instance_period_required")
        end
        { "Aliyun Provider" => errors }
      end
    end
  end
end
