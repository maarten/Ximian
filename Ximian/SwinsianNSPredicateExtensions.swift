import Foundation

internal extension NSPredicate {
    func toSQL() -> String {
        return SQLWhereClauseForPredicate(predicate: self)
    }

    private func SQLWhereClauseForPredicate(predicate: NSPredicate) -> String {
        if type(of: predicate) == NSCompoundPredicate.self {
            return SQLWhereClauseForCompoundPredicate(predicate: predicate as! NSCompoundPredicate)
        } else if type(of: predicate) == NSComparisonPredicate.self {
            return SQLWhereClauseForComparisonPredicate(predicate: predicate as! NSComparisonPredicate)
        } else {
            assert(false, "predicate \(self) cannot be converted to SQL because it is not of a convertible class")
        }
    }
    
    private func SQLWhereClauseForCompoundPredicate(predicate: NSCompoundPredicate) -> String {
        var subPredicates = [String]()
        
        for sub in predicate.subpredicates {
            subPredicates.append(SQLWhereClauseForPredicate(predicate: sub as! NSPredicate))
        }
        
        let conjunction: String = {
            switch predicate.compoundPredicateType {
            case NSCompoundPredicate.LogicalType.and:
                return " AND "
            case NSCompoundPredicate.LogicalType.or:
                return " OR "
            case NSCompoundPredicate.LogicalType.not:
                return " NOT "
            }
        }()
        
        return subPredicates.joined(separator: conjunction)
    }
    
    private func SQLWhereClauseForComparisonPredicate(predicate: NSComparisonPredicate) -> String {
        let comparator: String = {
            switch predicate.predicateOperatorType {
            case NSComparisonPredicate.Operator.lessThan:
                return "<"
            case NSComparisonPredicate.Operator.lessThanOrEqualTo:
                return "<"
            case NSComparisonPredicate.Operator.greaterThan:
                return ">"
            case NSComparisonPredicate.Operator.greaterThanOrEqualTo:
                return ">="
            case NSComparisonPredicate.Operator.equalTo:
                return "IS"
            case NSComparisonPredicate.Operator.notEqualTo:
                return "IS NOT"
            case NSComparisonPredicate.Operator.contains:
                return "LIKE '%@%'"
            case NSComparisonPredicate.Operator.beginsWith:
                return "LIKE '@%'"
            case NSComparisonPredicate.Operator.endsWith:
                return "LIKE '%@'"
            default:
                return "UNDEFINED"
            }
        }()
        
        let fieldName:String = {
            if predicate.leftExpression.keyPath.hasSuffix("Length") {
                return "length('\(predicate.leftExpression.keyPath)')"
            } else {
                return predicate.leftExpression.keyPath
            }
        }()
        
        if(comparator.contains("@")) {
            return "\(fieldName) \(comparator.replacingOccurrences(of: "@", with: String(describing: predicate.rightExpression.constantValue!)))"
        } else if let rightExpression = predicate.rightExpression.constantValue as? NSNumber {
            return "\(fieldName) \(comparator) \(rightExpression.intValue)"
        } else {
            return "\(fieldName) \(comparator) '\(predicate.rightExpression.constantValue!)'"
        }
    }
    
    private func SQLExpressionForNSExpression(expression: NSExpression) -> String {
        switch expression.expressionType {
        case NSExpression.ExpressionType.constantValue:
            return "constantValue"
        case NSExpression.ExpressionType.keyPath:
            return "keyPath"
        default:
            return "unknown"
        }
    }
}
