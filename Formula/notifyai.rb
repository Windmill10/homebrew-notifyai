class Notifyai < Formula
  desc "Archive macOS notifications for AI agents through a read-only MCP server"
  homepage "https://github.com/Windmill10/NotifyAI"
  url "https://github.com/Windmill10/NotifyAI/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "32690d1225c734adafda55a12238ffbd96f7267a4966eb30cec0812daf9c3a88"
  license "Apache-2.0"
  head "https://github.com/Windmill10/NotifyAI.git", branch: "main"

  # Builds with the system Swift 6.1+, from the Command Line Tools or Xcode 16.3+. `depends_on xcode:`
  # would demand the full Xcode.app.
  depends_on macos: :ventura
  uses_from_macos "swift" => :build

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/notifyai-collector", ".build/release/notifyai-mcp"
  end

  def caveats
    <<~EOS
      Choose apps, then install the background collector:
        notifyai-collector list-apps
        notifyai-collector install --allow-app BUNDLE_ID
      install opens the Full Disk Access settings for NotifyAI Collector.app and
      prints the command that registers the MCP server with your agent.

      After `brew upgrade notifyai`, refresh the installed copy with:
        notifyai-collector upgrade
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/notifyai-collector --version").strip
    assert_equal version.to_s, shell_output("#{bin}/notifyai-mcp --version").strip
    system bin/"notifyai-collector", "demo", "--directory", testpath/"demo"
    health = shell_output("#{bin}/notifyai-mcp --archive #{testpath}/demo/notifyai.db " \
                          "--allow-app com.notifyai.demo.chat --health-check")
    assert_match '"capture_state":"ok"', health
  end
end
