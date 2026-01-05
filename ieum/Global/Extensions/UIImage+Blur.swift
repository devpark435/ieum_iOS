import UIKit
import CoreImage

extension UIImage {
    func applyBlur(radius: CGFloat) -> UIImage? {
        let context = CIContext(options: nil)
        guard let inputImage = CIImage(image: self),
              let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        
        // 이미지 스케일을 고려하여 radius 조정 (Retina 디스플레이 대응)
        let scale = self.scale
        let inputRadius = radius * scale
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputRadius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // 원본 크기 유지 (블러로 인해 가장자리가 흐려지는 것 방지하려면 clamp 필요하지만, 여기서는 전체 화면이라 무방할 수 있음)
        // 안전하게 rect 설정
        guard let cgImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: self.imageOrientation)
    }
}

