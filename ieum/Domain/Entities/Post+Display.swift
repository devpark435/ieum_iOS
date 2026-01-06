import Foundation

extension Post {
    struct DisplayItem {
        let iconName: String
        let title: String
        let content: String
    }
    
    var displayItems: [DisplayItem] {
        var items: [DisplayItem] = []
        
        // 1. 특이증상
        if let unusualSymptoms = unusualSymptoms, !unusualSymptoms.isEmpty {
            items.append(DisplayItem(
                iconName: "symptom-icon",
                title: "특이증상",
                content: unusualSymptoms
            ))
        }
        
        // 2. 복약
        if type == .treatment || type == .wellness { // 치료/건강 기록일 경우에만 표시
             // medicationTaken is non-optional Bool, always display?
             // Or display only if explicitly recorded?
             // Assuming always display for treatment type.
            let medicationText = medicationTaken ? "복용 완료" : "미복용"
            items.append(DisplayItem(
                iconName: "medication-icon",
                title: "복약",
                content: medicationText
            ))
        }
        
        // 3. 식이상태
        if let diet = diet {
            let dietText = "\(diet.amountEaten.displayName)\n\(diet.mealContent)"
            items.append(DisplayItem(
                iconName: "meal-icon",
                title: "식이상태",
                content: dietText
            ))
        }
        
        // 4. 메모
        if let memo = memo, !memo.isEmpty {
            items.append(DisplayItem(
                iconName: "memo-icon",
                title: "메모",
                content: memo
            ))
        }
        
        return items
    }
}
