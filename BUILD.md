# Development

For development, we should open `SibcheStoreKit.xcworkspace` file in Xcode and then edit the plugin.

# Publish

After editing, we should select version for our new release and after then, we should edit `SibcheStoreKit.podspec` file and increment the version. Also we should increment version in Xcode project of plugin to our new version (we should increment Framework file)

After implementing your feature/bug, you should build the plugin (`.framework`) file. For this purpose, you should change your schema to `SBStoreKit Library` (Up left side of xcode). Then build the project. In building process, we will create `SibcheStoreKit.framework` file into `./SibcheStoreKit/Framework/SibcheStoreKit.framework` path. Now you should zip it and upload to github releases.

First you should login to cocoapods with our developer account:

```bash
pod trunk register
pod trunk me # ==> Your identity and your projects
```

Then we should commit and push the release to the git. After making release & tag, we can run cocoapods publishing command on project directory

```bash
pod trunk push SibcheStoreKit.podspec
```