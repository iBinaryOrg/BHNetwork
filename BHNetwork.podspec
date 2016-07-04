Pod::Spec.new do |s|
    s.name         = "BHNetwork"
    s.version      = "0.0.1"
    s.summary      = "离散式请求，对AFNetworking的二次封装"
    s.license      = 'MIT'
    s.author       = { "阿宝" => "zhanxuebao@outlook.com" }
    s.homepage     = "https://github.com/iBinaryOrg/BHNetwork"
    s.platform     = :ios,'7.0'
    s.ios.deployment_target = '7.0'
    s.source       = { :git => "https://github.com/iBinaryOrg/BHNetwork.git", :tag => s.version.to_s, :submodules => true}
    s.requires_arc = true

    s.subspec 'BHNetworkLogger' do |ss|
        ss.source_files = 'BHNetwork/BHNetworkLogger/*.{h,m}'
    end

    s.subspec 'BHNetworkProtocol' do |ss|
        ss.source_files = 'BHNetwork/BHNetworkProtocol/*.{h,m}'
    end

    s.subspec 'BHNetwork' do |ss|
        ss.source_files = 'BHNetwork/BHNetwork/*.{h,m}'
        ss.dependency 'BHNetwork/BHNetworkProtocol'
        ss.dependency 'BHNetwork/BHNetworkLogger'
    end

    s.dependency 'PINCache', '~> 2.2.2'
    s.dependency 'AFNetworking', '~> 3.0'
end
