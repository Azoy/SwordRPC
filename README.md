# SwordRPC - A Discord Rich Presence Library for Swift

[![Swift Version](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat-square)](https://swift.org) [![Tag](https://img.shields.io/github/tag/Azoy/SwordRPC.svg?style=flat-square&label=release&colorB=)](https://github.com/Azoy/SwordRPC/releases)

## Requirements
1. macOS, Linux
2. Swift 4.0

## Adding SwordRPC
Because this application needs to be used with a GUI application, it is best to install the package and it's dependencies then copy the sources to your own project.

## Example
```swift
import SwordRPC

/// Additional arguments:
/// handlerInterval: Int = 1000 (this decides how fast to check discord for updates, the default is 1 second (1000 ms))
/// autoRegister: Bool = true (this automatically registers your application to discord's game scheme (discord-appid://))
/// steamId: String? = nil (this is for steam games on these platforms)
let rpc = SwordRPC(appId: "123")

rpc.onConnect { rpc in
  var presence = RichPresence()
  presence.details = "Ranked | Mode: \(mode)"
  presence.state = "In a Group"
  presence.timestamps.start = Date()
  presence.timestamps.end = Date() + 600 // 600s = 10m
  presence.assets.largeImage = "map1"
  presence.assets.largeText = "Map 1"
  presence.assets.smallImage = "character1"
  presence.assets.smallText = "Character 1"
  presence.party.max = 5
  presence.party.size = 3
  presence.party.id = "partyId"
  presence.secrets.match = "matchSecret"
  presence.secrets.join = "joinSecret"
  presence.secrets.joinRequest = "joinRequestSecret"

  rpc.setPresence(presence)
}

rpc.onDisconnect { rpc, code, msg in
  print("It appears we have disconnected from Discord")
}

rpc.onError { rpc, code, msg in
  print("It appears we have discovered an error!")
}

rpc.onJoinGame { rpc, secret in
  print("We have found us a join game secret!")
}

rpc.onSpectateGame { rpc, secret in
  print("Our user wants to spectate!")
}

rpc.onJoinRequest { rpc, secret, request in
  print("Some user wants to play with us!")
  print(request.username)
  print(request.avatar)
  print(request.discriminator)
  print(request.userId)
}
```

## Links
Join the [API Channel](https://discord.gg/99a3xNk) to ask questions!
