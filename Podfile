platform :ios, '9.3'
use_frameworks!

target 'BeaconTerminal' do
    
    #ui pods
    pod 'Material', :git => 'https://github.com/CosmicMind/Material.git', :branch => 'development'
    #pod 'Realm', git: 'git@github.com:realm/realm-cocoa.git', branch: 'master', :submodules => true
	#pod 'RealmSwift', git: 'git@github.com:realm/realm-cocoa.git', branch: 'master', :submodules => true
    
    pod 'Realm'
    pod 'RealmSwift'
    pod 'HockeySDK', '~> 4.1.1'
    pod 'NVActivityIndicatorView'

    pod 'Nutella', :git => 'https://github.com/aperritano/Nutella', :branch => 'master'
    #pod 'XCGLogger', :git => 'https://github.com/aperritano/XCGLogger.git', :branch => 'swift3_xcode8_6'

#pod 'RealmSwift'
    #Logger
#    pod 'XCGLogger'

    #state machinepod
    pod 'Transporter'
    pod 'EstimoteSDK'
    pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift.git', :branch => 'feature/swift-3'
    pod 'XCGLogger', '~> 4.0.0'

    #upload
    pod 'CryptoSwift', :git => "https://github.com/krzyzanowskim/CryptoSwift", :branch => "master"
    pod 'Alamofire', '~> 4.0'
end

target 'BeaconTerminalModelTests' do
    #db
#    pod 'Realm', git: 'git@github.com:realm/realm-cocoa.git', branch: 'master', :submodules => true
#    pod 'RealmSwift', git: 'git@github.com:realm/realm-cocoa.git', branch: 'master', :submodules => true
#    
#    pod 'XCGLogger', :git => 'https://github.com/aperritano/XCGLogger.git', :branch => 'swift3_xcode8_6'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        # Configure Pod targets for Xcode 8 compatibility
        config.build_settings['SWIFT_VERSION'] = '3.0'
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = 'CN8G286W67/'
        config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
    end
end
