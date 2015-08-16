//
//  LazyRealmObject.swift
//  GitDoCore
//
//  Created by Pedro Piñera Buendía on 08/08/15.
//  Copyright © 2015 GitDo. All rights reserved.
//

import Foundation
import RealmSwift

/**
Errors caused by lazy relationships

- InvalidRelationship: the provided relationship is invalid
- NoPrimaryKey:        the relationship provided doesn't have primary key defined
- NoPrimaryKeyValue:   the relationship provided doesn't have primary key value
*/
enum RelObjectError: ErrorType {
    case InvalidRelationship
    case NoPrimaryKey
    case NoPrimaryKeyValue
}

/**
*  Protocol that defines the lazy relationships for Realm
*/
protocol RelObject {
    func getRel<T: Object>(name: String) throws -> T?
    func setRel<T: Object>(relationship: T, name: String) throws
    func setRels<T: Object>(relationships: [T], name: String) throws
    func getRels<T: Object>(name: String) throws -> [T]
    func primaryKeyAttribute(forRelationship name: String) -> String
}

extension RelObject where Self:Object {
    
    /**
    Get the relationship with the given name.
    Note: The relationship identifer field should have the format "{name}Id"
    
    :param: name relationship name
    
    :returns: relationship
    */
    func getRel<T: Object>(name: String) throws -> T? {
        let field = primaryKeyAttribute(forRelationship: name)
        guard let primaryKey = (self as Object).valueForKey(field) else {
            throw RelObjectError.InvalidRelationship
        }
        return realm?.objectForPrimaryKey(T.self, key: primaryKey)
    }
    
    /**
    Set the given relationship
    
    :param: relationship relationship model
    :param: name         relationship name
    */
    func setRel<T: Object>(relationship: T, name: String) throws {
        guard let primaryKey = T.primaryKey() else { throw RelObjectError.NoPrimaryKey }
        let primaryKeyValue = (relationship as Object).valueForKey(primaryKey) as? String
        let field = primaryKeyAttribute(forRelationship: name)
        let mirror = Mirror(reflecting: self)
        guard let _ = mirror.children.filter({$0.label == field}).first?.value as? String else {
            throw RelObjectError.InvalidRelationship
        }
        (self as Object).setValue(primaryKeyValue, forKey: field)
    }
    
    /**
    Set the relationships
    
    :param: relationships relationships array
    :param: name          name of the relationships
    */
    func setRels<T: Object>(relationships: [T], name: String) throws {
        var primaryKeysValues: [String] = [String]()
        for relationship in relationships {
            guard let primaryKey = T.primaryKey() else { continue }
            guard let primaryKeyValue = (relationship as Object).valueForKey(primaryKey) as? String else { continue }
            primaryKeysValues.append(primaryKeyValue)
        }
        let field = primaryKeyAttribute(forRelationship: name)
        let mirror = Mirror(reflecting: self)
        guard let _ = mirror.children.filter({$0.label == field}).first?.value as? [String] else {
            throw RelObjectError.InvalidRelationship
        }
        (self as Object).setValue(primaryKeysValues, forKey: field)
    }
    
    /**
    Get the relationships under a given name
    
    :param: name relationships name
    
    :returns: array with relationships
    */
    func getRels<T: Object>(name: String) throws -> [T]  {
        let field = primaryKeyAttribute(forRelationship: name)
        guard let primaryKeys = (self as Object).valueForKey(field) as? [String] else {
            throw RelObjectError.InvalidRelationship
        }
        var objects: [T] = [T]()
        for primaryKey in primaryKeys {
            if let object = realm?.objectForPrimaryKey(T.self, key: primaryKey) {
                objects.append(object)
            }
        }
        return objects
    }
}