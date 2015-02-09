require 'etc'

module Explorer
  class Setup
    FIREWALL_PLIST_DST = '/Library/LaunchDaemons/nl.darksecond.explorer.firewall.plist'
    RESOLVER_FILE_DST = '/etc/resolver/dev'
    RESOLVER_DIR_DST = '/etc/resolver'

    def install
      firewall_plist_src = File.join(Explorer::DATADIR, 'setup', 'firewall.plist')
      resolver_file_src = File.join(Explorer::DATADIR, 'setup', 'dev')

      mkdir(RESOLVER_DIR_DST)
      FileUtils.cp resolver_file_src, RESOLVER_FILE_DST
      puts Rainbow("Installed `#{RESOLVER_FILE_DST}`").color(:green).bright

      FileUtils.cp firewall_plist_src, FIREWALL_PLIST_DST
      puts Rainbow("Installed `#{FIREWALL_PLIST_DST}`").color(:green).bright

      unload_firewall
      load_firewall
      puts Rainbow('Loaded firwall rules').color(:green).bright

    rescue Errno::EACCES => e
      puts Rainbow("Something went wrong installing (#{e.message})").color(:red).bright
    end

    def uninstall
      FileUtils.rm RESOLVER_FILE_DST
      puts Rainbow("Removed `#{RESOLVER_FILE_DST}`").color(:green).bright

      unload_firewall
      puts Rainbow("Unloaded firewall rules").color(:green).bright

      FileUtils.rm FIREWALL_PLIST_DST
      puts Rainbow("Removed `#{FIREWALL_PLIST_DST}`").color(:green).bright

    rescue Errno::EACCES => e
      puts Rainbow("Something went wrong uninstalling (#{e.message})").color(:red).bright
    end

    def installed?
      return false unless File.exists? FIREWALL_PLIST_DST
      return false unless File.exists? RESOLVER_FILE_DST
      true
    end

    def suitable?
      return false unless Etc.uname[:sysname] == 'Darwin'
      true
    end

    private

    def unload_firewall
      system("pfctl -a com.apple/250.ExplorerFirewall -F nat 2>/dev/null")
      system("launchctl unload -w #{FIREWALL_PLIST_DST} 2>/dev/null")
    end

    def load_firewall
      system("launchctl load -Fw #{FIREWALL_PLIST_DST} 2>/dev/null")
    end

    def mkdir(dir)
      FileUtils.mkdir(dir) unless Dir.exists? dir
    end
  end
end
