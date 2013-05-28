require 'plugin_job'

module CadUtil
  module Utility
    class SavePreview < PluginJob::Worker
      include Connection::App

      attr_reader :model

      def valid?
        !model.nil?
      end

      def setup
        @model ||= active_model
      end

      def run
        @model ||= active_model
        set_preview
        model.save
      end

      def meta
        {:silent => true}.merge(super)
      end

      private

      def set_preview
        show_isometric
        zoom_fit
      end

      def show_isometric
        model.ShowNamedView2 "*Isometric", -1
      end

      def zoom_fit
        model.ViewZoomtofit2
      end
    end # class SaveCopy
  end # module Utility

end # module CadUtil
