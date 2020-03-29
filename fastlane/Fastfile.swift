// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation


class Fastfile: LaneFile {
    
    //        sh(command: "carthage bootsrap --platform iOS Cosmos stripe-ios FSCalendar FirebaseAnalyticsBinary")
    //        sh(command: "carthage bootsrap --platform iOS --no-use-binaries lottie-ios")
    //        sh(command: "carthage bootsrap --platform iOS --no-build carswaddleui carswaddledata")
            
    //        sh(command: "carthage bootsrap --platform iOS Cosmos stripe-ios FSCalendar FirebaseAnalyticsBinary")
    //        sh(command: "carthage bootsrap --platform iOS --no-use-binaries lottie-ios")
    //        sh(command: "carthage bootsrap --platform iOS --no-build carswaddleui carswaddledata")
    
    // MARK: - Full updates
    
    func bootstrapFrameworksLane() {
        desc("Bootstrap all frameworks")
        run(command: .bootstrapThirdParty)
        run(command: .bootstrapNoBinaries)
        run(command: .bootstrapFirstParty)
    }
    
    func updateFrameworksLane() {
        desc("Update all frameworks")
        run(command: .updateThirdParty)
        run(command: .updateNoBinaries)
        run(command: .updateFirstParty)
    }
    
    // MARK: - Bootstrap portions
    
    func bootstrapCarSwaddleFrameworksLane() {
        desc("Bootstrap first party frameworks")
        run(command: .bootstrapFirstParty)
    }
    
    func bootstrapThirdPartyFrameworksLane() {
        desc("Bootstrap first party frameworks")
        run(command: .bootstrapThirdParty)
        run(command: .bootstrapNoBinaries)
    }
    
    // MARK: - Update portions
    
    func updateCarSwaddleFrameworksLane() {
        desc("Update Car Swaddle party frameworks")
        run(command: .updateFirstParty)
    }
    
    func updateThirdPartyFrameworksLane() {
        desc("Update third party frameworks")
        run(command: .updateThirdParty)
        run(command: .updateNoBinaries)
    }
    
    private func run(command: Command) {
        sh(command: command.shString)
    }
    
}


// MARK: - Custom

struct Command {
    
    let updateType: UpdateType
    let parameters: [Parameter]
    let frameworks: [Framework]
    
    public var shString: String {
        return "carthage \(updateType.rawValue) \(parameterString) \(frameworkString)"
    }
    
    private var parameterString: String {
        return parameters.map{ "--\($0.value)" }.joined(separator: " ")
    }
    
    private var frameworkString: String {
        return frameworks.map{ $0.value }.joined(separator: " ")
    }
    
    enum UpdateType: String {
        case bootstrap
        case update
    }
    
    struct Framework {
        public let value: String
    }
    
    enum Parameter {
        case platformiOS
        case noBuild
        case noBinaries
        
        var value: String {
            switch self {
            case .platformiOS: return "platform iOS"
            case .noBuild: return "no-build"
            case .noBinaries: return "no-use-binaries"
            }
        }
    }
    
}



extension Command.Framework {
    static let lottie = Command.Framework(value: "lottie-ios")
    static let stripe = Command.Framework(value: "stripe-ios")
    static let cosmos = Command.Framework(value: "Cosmos")
    static let fsCalendar = Command.Framework(value: "FSCalendar")
    static let firebaseAnalyticsBinary = Command.Framework(value: "FirebaseAnalyticsBinary")
    static let carswaddleUI = Command.Framework(value: "carswaddleui")
    static let carswaddleData = Command.Framework(value: "carswaddledata")
}


extension Command {
    
    static let bootstrapThirdParty: Command = Command(updateType: .bootstrap, parameters: [.platformiOS], frameworks: [.cosmos, .stripe, .fsCalendar, .firebaseAnalyticsBinary])
    static let bootstrapNoBinaries: Command = Command(updateType: .bootstrap, parameters: [.platformiOS, .noBinaries], frameworks: [.lottie])
    static let bootstrapFirstParty: Command = Command(updateType: .bootstrap, parameters: [.platformiOS, .noBuild], frameworks: [.carswaddleUI, .carswaddleData])
    static let updateThirdParty: Command = Command(updateType: .update, parameters: [.platformiOS], frameworks: [.cosmos, .stripe, .fsCalendar, .firebaseAnalyticsBinary])
    static let updateNoBinaries: Command = Command(updateType: .update, parameters: [.platformiOS, .noBinaries], frameworks: [.lottie])
    static let updateFirstParty: Command = Command(updateType: .update, parameters: [.platformiOS, .noBuild], frameworks: [.carswaddleUI, .carswaddleData])
    
}
