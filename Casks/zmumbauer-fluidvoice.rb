cask "zmumbauer-fluidvoice" do
  version "1.5.9"
  sha256 "fbb07b95b29519a3f72da61ada802f8099197ba5a8476d3cdd62114d04bb6e6c"

  url "https://github.com/altic-dev/FluidVoice/releases/download/v#{version}/Fluid-oss-#{version}.dmg"
  name "FluidVoice"
  desc "Offline voice-to-text dictation app"
  homepage "https://github.com/altic-dev/FluidVoice"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: ">= :sonoma"

  app "FluidVoice.app"

  zap trash: [
    "~/Library/Application Support/Fluid",
    "~/Library/Application Support/FluidVoice",
    "~/Library/Caches/WhisperModels",
    "~/Library/Logs/Fluid",
    "~/Library/Preferences/com.FluidApp.app.plist",
    "~/Library/Saved Application State/com.FluidApp.app.savedState",
  ]
end
