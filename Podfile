platform :ios, '9.3'
use_frameworks!

target 'BeaconTerminal' do
    
    #ui pods
    pod 'Material', :git => 'https://github.com/CosmicMind/Material.git', :branch => 'development'
    
    #db
    pod 'Realm', git: 'git@github.com:realm/realm-cocoa.git', branch: 'master', :submodules => true
	pod 'RealmSwift', git: 'git@github.com:realm/realm-cocoa.git', branch: 'master', :submodules => true

    #pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git', :branch => 'swift3'
    pod 'XCGLogger', :git => 'https://github.com/aperritano/XCGLogger.git', :branch => 'swift3_xcode8_6'

    #state machinepod
    pod 'Transporter', :git => 'https://github.com/DenHeadless/Transporter.git', :branch => 'swift3'
end

target 'BeaconTerminalModelTests' do
    #db
    pod 'Realm', git: 'git@github.com:realm/realm-cocoa.git', branch: 'master', :submodules => true
    pod 'RealmSwift', git: 'git@github.com:realm/realm-cocoa.git', branch: 'master', :submodules => true
    
    #pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git', :branch => 'swift3'
    pod 'XCGLogger', :git => 'https://github.com/aperritano/XCGLogger.git', :branch => 'swift3_xcode8_6'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        # Configure Pod targets for Xcode 8 compatibility
        config.build_settings['SWIFT_VERSION'] = '3.0'
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = 'CN8G286W67/'
        config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
    end
end
