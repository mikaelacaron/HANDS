import Accelerate
import ARKit
import RealityKit

/// Enumerates the digits of the hand.
public enum HandDigit {
    case thumb
    case index
    case middle
    case ring
    case littleFinger
    
    /// Provides the joint name corresponding to the digit of the ``HandSkeleton``.
    var jointName: HandSkeleton.JointName {
        switch self {
        case .thumb: return .thumbTip
        case .index: return .indexFingerTip
        case .middle: return .middleFingerTip
        case .ring: return .ringFingerTip
        case .littleFinger: return .littleFingerTip
        }
    }
}

/// Provides functionality to compute distances between hand digits.
public class HandGestureTracker {
    
    public init() { }
    
    /// Computes the distance between two specified digits, which can be on the same or different hands.
    /// - Parameters:
    ///   - firstAnchor: The anchor of the first hand.
    ///   - firstDigit: The digit of the first hand.
    ///   - secondAnchor: The anchor of the second hand, optional. Defaults to the same as the first hand.
    ///   - secondDigit: The digit of the second hand.
    /// - Returns: The distance between the two specified digits, or nil if tracking data is unavailable.
    public static func computeDistanceBetweenDigits(firstAnchor: HandAnchor, firstDigit: HandDigit, secondAnchor: HandAnchor? = nil, secondDigit: HandDigit) -> Float? {
        let secondAnchor = secondAnchor ?? firstAnchor
        
        guard firstAnchor.isTracked, secondAnchor.isTracked,
              let firstJoint = firstAnchor.handSkeleton?.joint(firstDigit.jointName),
              let secondJoint = secondAnchor.handSkeleton?.joint(secondDigit.jointName),
              firstJoint.isTracked, secondJoint.isTracked else {
            return nil
        }
        
        let originFromFirstJoint = getXYZ(fromAnchor: firstAnchor, joint: firstJoint)
        let originFromSecondJoint = getXYZ(fromAnchor: secondAnchor, joint: secondJoint)
        
        return simd_distance(originFromFirstJoint, originFromSecondJoint)
    }
    
    /// Extracts the XYZ components from an anchor and its joint.
    /// - Parameters:
    ///   - anchor: The ``HandAnchor`` representing hand tracking data.
    ///   - joint: The ``HandSkeleton.Joint`` representing a specific joint in the hand.
    /// - Returns: A ``SIMD3<Float>``representing the xyz coordinates of the joint.
    private static func getXYZ(fromAnchor anchor: HandAnchor, joint: HandSkeleton.Joint) -> SIMD3<Float> {
        let jointTransform = matrix_multiply(anchor.originFromAnchorTransform, joint.anchorFromJointTransform)
        return SIMD3<Float>(jointTransform.columns.3.x, jointTransform.columns.3.y, jointTransform.columns.3.z)
    }
}
