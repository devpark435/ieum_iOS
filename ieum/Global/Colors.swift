import UIKit

enum Colors {
    static let transparent = UIColor.clear
    static let black = UIColor(hex: "#000000")
    static let white = UIColor(hex: "#FFFFFF")
    
    // MARK: - Brand Colors
    enum Primary {
        static let green = UIColor(hex: "#009966")
        static let lightGreen = UIColor(hex: "#D8F999")
        static let navy = UIColor(hex: "#052F4A")
    }
    
    enum Slate {
        static let s50 = UIColor(hex: "#F8FAFC")
        static let s100 = UIColor(hex: "#F1F5F9")
        static let s200 = UIColor(hex: "#E2E8F0")
        static let s300 = UIColor(hex: "#CBD5E1")
        static let s400 = UIColor(hex: "#94A3B8")
        static let s500 = UIColor(hex: "#64748B")
        static let s600 = UIColor(hex: "#475569")
        static let s700 = UIColor(hex: "#334155")
        static let s800 = UIColor(hex: "#1E293B")
        static let s900 = UIColor(hex: "#0F172A")
        static let s950 = UIColor(hex: "#020617")
    }
    
    enum Gray {
        static let g50 = UIColor(hex: "#F9FAFB")
        static let g100 = UIColor(hex: "#F3F4F6")
        static let g200 = UIColor(hex: "#E5E7EB")
        static let g300 = UIColor(hex: "#D1D5DB")
        static let g400 = UIColor(hex: "#9CA3AF")
        static let g500 = UIColor(hex: "#6B7280")
        static let g600 = UIColor(hex: "#4B5563")
        static let g700 = UIColor(hex: "#374151")
        static let g800 = UIColor(hex: "#1F2937")
        static let g900 = UIColor(hex: "#111827")
        static let g950 = UIColor(hex: "#030712") // Default Text
    }
    
    enum Zinc {
        static let z50 = UIColor(hex: "#FAFAFA")
        static let z100 = UIColor(hex: "#F4F4F5")
        static let z200 = UIColor(hex: "#E4E4E7")
        static let z300 = UIColor(hex: "#D4D4D8")
        static let z400 = UIColor(hex: "#A1A1AA")
        static let z500 = UIColor(hex: "#71717A")
        static let z600 = UIColor(hex: "#52525B")
        static let z700 = UIColor(hex: "#3F3F46")
        static let z800 = UIColor(hex: "#27272A")
        static let z900 = UIColor(hex: "#18181B")
        static let z950 = UIColor(hex: "#09090B")
    }
    
    enum Neutral {
        static let n50 = UIColor(hex: "#FAFAFA")
        static let n100 = UIColor(hex: "#F5F5F5")
        static let n200 = UIColor(hex: "#E5E5E5")
        static let n300 = UIColor(hex: "#D4D4D4")
        static let n400 = UIColor(hex: "#A3A3A3")
        static let n500 = UIColor(hex: "#737373")
        static let n600 = UIColor(hex: "#525252")
        static let n700 = UIColor(hex: "#404040")
        static let n800 = UIColor(hex: "#262626")
        static let n900 = UIColor(hex: "#171717")
        static let n950 = UIColor(hex: "#0A0A0A")
    }
    
    enum Stone {
        static let s50 = UIColor(hex: "#FAFAF9")
        static let s100 = UIColor(hex: "#F5F5F4")
        static let s200 = UIColor(hex: "#E7E5E4")
        static let s300 = UIColor(hex: "#D6D3D1")
        static let s400 = UIColor(hex: "#A8A29E")
        static let s500 = UIColor(hex: "#78716C")
        static let s600 = UIColor(hex: "#57534E")
        static let s700 = UIColor(hex: "#44403C")
        static let s800 = UIColor(hex: "#292524")
        static let s900 = UIColor(hex: "#1C1917")
        static let s950 = UIColor(hex: "#0C0A09")
    }
    
    enum Red {
        static let r50 = UIColor(hex: "#FEF2F2")
        static let r100 = UIColor(hex: "#FEE2E2")
        static let r200 = UIColor(hex: "#FECACA")
        static let r300 = UIColor(hex: "#FCA5A5")
        static let r400 = UIColor(hex: "#F87171")
        static let r500 = UIColor(hex: "#EF4444")
        static let r600 = UIColor(hex: "#DC2626")
        static let r700 = UIColor(hex: "#B91C1C")
        static let r800 = UIColor(hex: "#991B1B")
        static let r900 = UIColor(hex: "#7F1D1D")
        static let r950 = UIColor(hex: "#450A0A")
    }
    
    enum Orange {
        static let o50 = UIColor(hex: "#FFF7ED")
        static let o100 = UIColor(hex: "#FFEDD5")
        static let o200 = UIColor(hex: "#FED7AA")
        static let o300 = UIColor(hex: "#FDBA74")
        static let o400 = UIColor(hex: "#FB923C")
        static let o500 = UIColor(hex: "#F97316")
        static let o600 = UIColor(hex: "#EA580C")
        static let o700 = UIColor(hex: "#C2410C")
        static let o800 = UIColor(hex: "#9A3412")
        static let o900 = UIColor(hex: "#7C2D12")
        static let o950 = UIColor(hex: "#431407")
    }
    
    enum Amber {
        static let a50 = UIColor(hex: "#FFFBEB")
        static let a100 = UIColor(hex: "#FEF3C7")
        static let a200 = UIColor(hex: "#FDE68A")
        static let a300 = UIColor(hex: "#FCD34D")
        static let a400 = UIColor(hex: "#FBBF24")
        static let a500 = UIColor(hex: "#F59E0B")
        static let a600 = UIColor(hex: "#D97706")
        static let a700 = UIColor(hex: "#B45309")
        static let a800 = UIColor(hex: "#92400E")
        static let a900 = UIColor(hex: "#78350F")
        static let a950 = UIColor(hex: "#451A03")
    }
    
    enum Green {
        static let g50 = UIColor(hex: "#F0FDF4")
        static let g100 = UIColor(hex: "#DCFCE7")
        static let g200 = UIColor(hex: "#BBF7D0")
        static let g300 = UIColor(hex: "#86EFAC")
        static let g400 = UIColor(hex: "#4ADE80")
        static let g500 = UIColor(hex: "#22C55E")
        static let g600 = UIColor(hex: "#16A34A")
        static let g700 = UIColor(hex: "#15803D")
        static let g800 = UIColor(hex: "#166534")
        static let g900 = UIColor(hex: "#14532D")
        static let g950 = UIColor(hex: "#052E16")
    }
    
    enum Blue {
        static let b50 = UIColor(hex: "#EFF6FF")
        static let b100 = UIColor(hex: "#DBEAFE")
        static let b200 = UIColor(hex: "#BFDBFE")
        static let b300 = UIColor(hex: "#93C5FD")
        static let b400 = UIColor(hex: "#60A5FA")
        static let b500 = UIColor(hex: "#3B82F6")
        static let b600 = UIColor(hex: "#2563EB")
        static let b700 = UIColor(hex: "#1D4ED8")
        static let b800 = UIColor(hex: "#1E40AF")
        static let b900 = UIColor(hex: "#1E3A8A")
        static let b950 = UIColor(hex: "#172554")
    }
    
    // MARK: - Lime
    enum Lime {
        static let l500 = UIColor(hex: "#7CCF00")
    }
    
    static let ieumBackground = UIColor(hex: "#FBFDF4")
}
