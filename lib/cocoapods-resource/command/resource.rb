module Pod
  class Command
    # This is an example of a cocoapods plugin adding a top-level subcommand
    # to the 'pod' command.
    #
    # You can also create subcommands of existing or new commands. Say you
    # wanted to add a subcommand to `list` to show newly deprecated pods,
    # (e.g. `pod list deprecated`), there are a few things that would need
    # to change.
    #
    # - move this file to `lib/pod/command/list/deprecated.rb` and update
    #   the class to exist in the the Pod::Command::List namespace
    # - change this class to extend from `List` instead of `Command`. This
    #   tells the plugin system that it is a subcommand of `list`.
    # - edit `lib/cocoapods_plugins.rb` to require this file
    #
    # @todo Create a PR to add your plugin to CocoaPods/cocoapods.org
    #       in the `plugins.json` file, once your plugin is released.
    #
    class Resource < Command
      self.summary = '组件化资源文件管理配置工具。'

      self.description = <<-DESC
        为组件配置预编译宏（Preprocessor Macros），以实现在代码执行行获取当前所在 Pod 的名称。若不传递 --target-pods 参数默认给当前所有 Pod 添加配置。
      DESC

      self.arguments = [
        CLAide::Argument.new('MACRO_NAME', true)
      ]

      def self.options
        [
          ['--target-pods=POD_NAME', '传入 Pod 名称数组，给指定的 Pod 配置预编译宏（Preprocessor Macros）。']
        ]
      end
            

      def initialize(argv)
        @macro_name = argv.shift_argument
        @target_pods = argv.option('target-pods', '')
        super
      end

      def validate!
        super
        help! 'A macro name for Pod is required.' unless @macro_name
      end

      def run

        raise Informative, "No 'Pods' found in the project directory." unless Dir.exists? "Pods"

        macro_name = @macro_name

        completed_pods = Array.new
        target_pods = Array.new
        @target_pods.split(',').each do |pod|
          target_pods.push(pod.gsub(' ',''))
        end


        file_paths = File.expand_path('Pods/**/*.*.xcconfig')
        Dir.glob(file_paths) do |xcconfig|

          pod_name = File.basename(xcconfig, ".*")
          pod_name = File.basename(pod_name, ".*")

          # Pods- 开头，跳过 
          next if /^Pods-/ =~ pod_name

          # 传入目标 Pod 并且未匹配到，跳过
          if target_pods.length > 0 then
            next unless target_pods.index(pod_name)
          end

          pre_macro = " #{macro_name}=@(\\\"#{pod_name}\\\")"

          gcc_line = ''
          xcconfig_file = File.open(xcconfig)
          xcconfig_file.each_line do |line|
            if line.include?('GCC_PREPROCESSOR_DEFINITIONS') then
              gcc_line = line
              break
            end
          end
          xcconfig_file.close

          # 未找到 GCC_PREPROCESSOR_DEFINITIONS 行，跳过
          next if gcc_line.empty?
          # GCC_PREPROCESSOR_DEFINITIONS 行已包含目标预编译宏（Preprocessor Macros），跳过
          next if gcc_line.include?(macro_name)

          macro_line = gcc_line.chomp + pre_macro + "\n"
          xcconfig_text = File.read(xcconfig)
          xcconfig_text = xcconfig_text.gsub(gcc_line, macro_line)
        
          File.open(xcconfig, "w") do |file|
            file.syswrite(xcconfig_text)
          end

          completed_pods.push(pod_name) unless completed_pods.index(pod_name)

        end

        if completed_pods.length > 0 then
          UI.puts "Pod resource complete! These pods have been changed: #{completed_pods}."
        else
          UI.puts "No pod has been changed."
        end

      end
    end
  end
end
