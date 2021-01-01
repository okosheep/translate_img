# frozen_string_literal: true

# Definitions for TranslateImg settings.
module TranslateImg
  class << self
    # @example
    #   # config/initializers/translate_img_cli.rb
    #   TranslateImg.configure do |config|
    #     config.aws_textract_region = 'us-east-1'
    #     config.aws_translate_region = 'ap-northeast-1'
    #     config.font_face = 'MigMix 1M'
    #     config.font_size = 16
    #     config.font_color_rgba = { red: 255, green: 0, blue: 0, alpha: 1 }
    #   end
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    # Configurations for TranslateImg.
    class Configuration
      # Set region for Amazon Textract. Default is 'us-east-1'
      attr_accessor :aws_textract_region

      # Set region for Amazon Translate. Default is 'ap-northeast-1'
      attr_accessor :aws_translate_region

      # Set font face for destination image. Default is 'Mig Mix 1M'
      # {https://mix-mplus-ipa.osdn.jp/migmix/}
      attr_accessor :font_face

      # Set font size for destination image. Default is 16.
      attr_accessor :font_size

      # Sets the font color as RGBA. Default is `{ red: 255, green: 0, blue: 0, alpha: 1 }`
      attr_accessor :font_color_rgba

      # Set default value to accessors.
      def initialize
        @aws_textract_region = 'us-east-1'
        @aws_translate_region = 'ap-northeast-1'
        @font_face = 'MigMix 1M'
        @font_size = 16
        @font_color_rgba = { red: 255, green: 0, blue: 0, alpha: 1 }
      end
    end
  end
end
