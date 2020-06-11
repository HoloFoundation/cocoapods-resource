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
      self.summary = 'Resource file management configuration tool for Pod.'

      self.description = <<-DESC
        Configure the pod with Preprocessor Macros to get the name of the current Pod at the line of code execution. By default, add configuration to all current Pods.
      DESC

      self.arguments = [
        CLAide::Argument.new('MACRO_NAME', true)
      ]

      def self.options
        [
          ['--pods=POD_NAME', 'Pass in the Pod name array, and configure the Preprocessor Macros for these specified Pods.']
        ]
      end
            

      def initialize(argv)
        @macro_name = argv.shift_argument
        @target_pods = argv.option('pods', '')
        super
      end

      def validate!
        super
        help! 'A macro name for Pod is required.' unless @macro_name
      end

      def run

        raise Informative, "No 'Pods' folder found in the project directory." unless Dir.exists? "Pods"

        macro_name = @macro_name

        completed_pods = Array.new
        already_pods = Array.new
        target_pods = Array.new
        @target_pods.split(',').each do |pod|
          target_pods.push(pod.gsub(' ',''))
        end


        xcconfig_paths = File.expand_path('Pods/**/*.*.xcconfig')
        Dir.glob(xcconfig_paths) do |xcconfig|

          pod_name = File.basename(xcconfig, ".*")
          pod_name = File.basename(pod_name, ".*")

          # Pods- start, next
          next if /^Pods-/ =~ pod_name
          
          # The target Pod is passed in and no match, next
          next if target_pods.length > 0 and target_pods.index(pod_name) == nil

          gcc_line = ''
          xcconfig_file = File.open(xcconfig)
          xcconfig_file.each_line do |line|
            if line.include?('GCC_PREPROCESSOR_DEFINITIONS') then
              gcc_line = line
              break
            end
          end
          xcconfig_file.close

          # no found GCC_PREPROCESSOR_DEFINITIONS line, next
          next if gcc_line.empty?
          # GCC_PREPROCESSOR_DEFINITIONS line already contains the target Preprocessor Macros, next
          if gcc_line.include?(macro_name) then
            already_pods.push(pod_name) unless already_pods.index(pod_name)
            next
          end 

          pre_macro = "#{macro_name}=@(\\\"#{pod_name}\\\")"
          macro_line = gcc_line.chomp + " " + pre_macro + "\n"
          xcconfig_text = File.read(xcconfig)
          xcconfig_text = xcconfig_text.gsub(gcc_line, macro_line)
        
          File.open(xcconfig, "w") do |file|
            file.syswrite(xcconfig_text)
          end

          completed_pods.push(pod_name) unless completed_pods.index(pod_name)

        end
        
        if completed_pods.length > 0 then
          UI.puts "Pod resource complete! These pods have been changed: #{completed_pods}."
        end
        
        if already_pods.length > 0 then
          UI.puts "These pods already have current macro: #{already_pods}."
        end

        if completed_pods.length <= 0 and already_pods.length <= 0 then
          UI.puts "No pod has been changed."
        end

      end
    end
  end
end
