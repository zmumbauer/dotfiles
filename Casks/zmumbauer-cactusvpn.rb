cask "zmumbauer-cactusvpn" do
  version :latest
  sha256 :no_check

  url "https://billing.cactusvpn.com/dl.php?id=26&type=d"
  name "CactusVPN"
  desc "VPN client from CactusVPN"
  homepage "https://www.cactusvpn.com/"

  app "CactusVPN.app"

  zap trash: [
    "~/Library/Application Support/CactusVPN",
    "~/Library/Caches/com.cactusvpn.*",
    "~/Library/Preferences/com.cactusvpn.*.plist",
    "~/Library/Saved Application State/com.cactusvpn.*.savedState",
  ]
end
