let Project
    : Type
    = { name : Text, domain : Text, description : Text }

let AWS
    : Type
    = { bucketPrefix : Text, region : Text, accessKey : Text, secretKey : Text }

let AssetAPI
    : Type
    = { domain : Text, token : Text }

let projectConfig
    : Project
    = { name = "marco-daniels-website"
      , domain = "marcodaniels.com"
      , description = "Marco Daniels Website"
      }

let awsConfig
    : AWS
    = { bucketPrefix = "${projectConfig.name}-"
      , region = env:AWS_DEFAULT_REGION as Text
      , accessKey = env:AWS_ACCESS_KEY_ID as Text
      , secretKey = env:AWS_SECRET_ACCESS_KEY as Text
      }

let assetAPIConfig
    : AssetAPI
    = { domain = env:ASSET_DOMAIN as Text, token = env:ASSET_TOKEN as Text }

in  { project = projectConfig, aws = awsConfig, assetAPI = assetAPIConfig }
