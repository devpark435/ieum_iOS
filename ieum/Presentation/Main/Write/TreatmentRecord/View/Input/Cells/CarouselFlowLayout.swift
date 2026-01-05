import UIKit

final class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - Properties
    
    private let activeDistance: CGFloat = 140
    private let zoomFactor: CGFloat = 0.4 // 1.0 - 0.4 = 0.6 (최소 스케일)
    
    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = 20
        itemSize = CGSize(width: 140, height: 140)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        // 중앙 정렬을 위한 Inset 설정
        let horizontalInset = (collectionView.bounds.width - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
    
    // 스크롤 시 레이아웃 갱신
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // 각 셀의 레이아웃 속성 계산 (줌 효과)
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let centerX = visibleRect.midX
        
        // 속성 복사본 사용 (경고 방지)
        let layoutAttributes = attributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        for attribute in layoutAttributes {
            let distance = abs(attribute.center.x - centerX)
            
            if distance < activeDistance {
                let scale = 1 - zoomFactor * (distance / activeDistance)
                attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
                attribute.alpha = scale
            } else {
                let scale = 1 - zoomFactor
                attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
                attribute.alpha = scale
            }
        }
        
        return layoutAttributes
    }
    
    // 스냅 효과 (페이징)
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        
        // 타겟 영역의 중앙
        let horizontalCenter = proposedContentOffset.x + collectionView.bounds.width / 2
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        
        guard let attributes = super.layoutAttributesForElements(in: targetRect) else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        
        // 중앙에 가장 가까운 아이템 찾기
        for layoutAttributes in attributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment) {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}

