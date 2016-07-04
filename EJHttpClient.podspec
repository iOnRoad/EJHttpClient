Pod::Spec.new do |s|
        s.name             = "EJHttpClient"
        s.version          = "1.0.1"
        s.summary          = "This is a convenient network framework."
        s.description      = <<-DESCRIPTION
                          Using the object as the parameter of the network request, the block asynchronous callback automatically assigned to the response object, encapsulating the errorView and the loadView. In a word, you can request the network, the pop up loadingView and the errorView prompt.
                          DESCRIPTION

        s.homepage         = "https://github.com/iOnRoad/EJHttpClient"
        s.license          = 'MIT'
        s.author           = { "iOnRoad" => "xuwenchao_15@163.com" }
        s.source           = { :git => "https://github.com/iOnRoad/EJHttpClient.git", :tag => s.version }

        s.platform     = :ios, '7.0'
        s.requires_arc = true

        s.subspec 'EJHttpClient' do |ss|
            ss.source_files = 'Pod/Classes/EJHttpClient/*'
            ss.public_header_files = 'Pod/Classes/EJHttpClient/*.h'
               
            ss.frameworks = 'UIKit','QuartzCore'

            ss.dependency 'Reachability', '~> 3.2'
            ss.dependency 'AFNetworking', '~> 2.6.3'
            ss.dependency 'AFgzipRequestSerializer', '~> 0.0.2'
            ss.dependency 'MJExtension', '~> 3.0.10'
        end

end
