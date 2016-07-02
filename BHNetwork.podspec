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
  s.public_header_files = 'BHNetwork/BHNetwork.h'
  s.source_files = 'BHNetwork/BHNetwork.h'

  s.subspec 'BHNetworkConfig' do |ss|
    ss.source_files = 'BHNetwork/BHNetworkConfig/*.{h,m}'
    ss.dependency 'BHNetwork/BHNetworkRequest'
  end

  s.subspec 'BHNetworkProtocol' do |ss|
    ss.source_files = 'BHNetwork/BHNetworkProtocol/*.{h,m}'
  end

  s.subspec 'BHNetworkResponse' do |ss|
    ss.source_files = 'BHNetwork/BHNetworkResponse/*.{h,m}'
    ss.dependency 'BHNetwork/BHNetworkProtocol'
    ss.dependency 'BHNetwork/BHNetworkConfig'
  end

  s.subspec 'BHNetworkRequest' do |ss|
    ss.source_files = 'BHNetwork/BHNetworkRequest/*.{h,m}'
    ss.subspec 'BHNetworkPrivate' do |sss|
        sss.source_files = 'BHNetwork/BHNetworkRequest/BHNetworkPrivate*.{h,m}'
        sss.dependency 'BHNetwork/BHNetworkResponse'
        sss.dependency 'BHNetwork/BHNetworkProtocol'
        sss.dependency 'BHNetwork/BHNetworkLogger'
        sss.dependency 'BHNetwork/BHNetworkRequest'
        sss.dependency 'PINCache', '~> 2.2.2'
    end
    ss.dependency 'BHNetwork/BHNetworkRequest/BHNetworkPrivate'
  end

  s.dependency 'AFNetworking', '~> 3.0'
end
