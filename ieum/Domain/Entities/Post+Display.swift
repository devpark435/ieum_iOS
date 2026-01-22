import Foundation

extension Post {
    enum DisplayItemType {
        case basic
        case medication(isTaken: Bool)
        case diet(amount: AmountEaten)
    }

    struct DisplayItem {
        let iconName: String
        let title: String
        let content: String
        let type: DisplayItemType
    }
    
    var displayItems: [DisplayItem] {
        var items: [DisplayItem] = []
        
        // 1. 특이증상
        if let unusualSymptoms = unusualSymptoms, !unusualSymptoms.isEmpty {
            items.append(DisplayItem(
                iconName: "symptom-icon",
                title: "특이증상",
                content: unusualSymptoms,
                type: .basic
            ))
        }
        
        // 2. 복약 (wellness 타입일 때만)
        if type == .wellness, let medicationTaken = medicationTaken {
            items.append(DisplayItem(
                iconName: "medication-icon",
                title: "복약",
                content: "",
                type: .medication(isTaken: medicationTaken)
            ))
        }
        
        // 3. 식이상태
        if let diet = diet {
            items.append(DisplayItem(
                iconName: "meal-icon",
                title: "식이상태",
                content: diet.mealContent ?? "",
                type: .diet(amount: diet.amountEaten)
            ))
        }
        
        // 4. 메모
        if let memo = memo, !memo.isEmpty {
            items.append(DisplayItem(
                iconName: "memo-icon",
                title: "메모",
                content: memo,
                type: .basic
            ))
        }
        
        return items
    }
}
