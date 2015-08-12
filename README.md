
![image](https://github.com/gitdoapp/Realm.rel/blob/master/assets/logo.png?raw=true)
# Realm.rel
Realm.rel extends Realm models adding custom relationships getters.
This library is highly inspired in [Backbone.Rel](https://github.com/masylum/Backbone.Rel)

### Problem
When you deal with multiple models locally that have dependencies between them, replicating these relationships in local can be a bit complex if the API you're you are fetching the data from doesn't return all the data you need to create models and set the relationships. It leads to multiple requests, and *temporary* models waiting for the relationship to be set. 

The purpose of this Realm extension is isolating collections of models *(not using Realm native relationships)*. It defines relationship getters that **using the primary key** fetch the relationships when they are needed. The model then only keeps a reference to the other model primary key identifier.

### How to add to your project.
In order to use Realm.rel in your projects you can add the file `RelObject.swift` in your project target. Very easy! :)

Once Swift2.0 gets launched we'll officially support **Carthage** and **Cocoapods**

### API

**Primary Key Attribute**
Models that include `Realm.rel` relationships must implement the method `primaryKeyAttribute` that returns the current model attribute that contains de relationship/s references

```swift
func primaryKeyAttribute(forRelationship name: String, type: RelationShip) -> String {
  if name == "exercises" && {
    return "exercisesIds
  }
}
```

*Note: The Realm Model fields using to keep the relationship reference must be of type String (even if represents a ToManY) relationship. Realm doesn't support a field of type Array and what Realm.Rel does is convert an array of identifiers into an String concatenating identifiers*

**Relationship Getters and Setters**

Use them to set/get relationships OneToOne/OneToMany
```swift
func getRel<T: Object>(name: String) throws -> T?
func setRel<T: Object>(relationship: T, name: String) throws
func setRels<T: Object>(relationships: [T], name: String) throws
func getRels<T: Object>(name: String) throws -> [T]
func primaryKeyAttribute(forRelationship name: String) -> String
```
*Note: This method throws a RelObjectError if something goes wrong fetching or setting the relationship.*

```swift
enum RelObjectError: ErrorType {
    case InvalidRelationship
    case NoPrimaryKey
    case NoPrimaryKeyValue
}
```

### Example

```swift
/// NOTIFICATION ///
public final class Notification: Object, RelObject {
  /// Github identifier
  public dynamic var githubId: String = ""
  
  /// Issue Github identifier
  public dynamic var issueId: String = ""
    
  // MARK:  RelObject
  func primaryKeyAttribute(forRelationship name: String) -> String {
        if name == "issue" {
            return "issueId"
        }
        return ""
  }
}

/// ISSUE ///
public final class Issue: Object, RelObject {
  /// Isuse Github identifier
  public dynamic var githubId: String = ""
  
  override public static func primaryKey() -> String? {
     return "githubId"
  }
}

// Saving data
let issue: Issue = Issue()
issue.githubId = "iiiii"
let notification: Notification = Notification()
notification.githubId = "nnnn"
notification.issueId = issue.githubId
Realm()?.write {
  realm.add(issue)
  realm.add(notification)
}

// Fetching data
let notification: Notification? = Realm()?.objectForPrimaryKey(Notification, "nnnn")
var issue: Issue?
do {
  issue = try notification.getRel("issue")
}
catch {
  // Couldn't get the relationship
}
```

### Limitations
- It uses the same object's Realm to fetch the relationship so it's very important to call the getter in the same thread the object Realm belongs to.


### License
The MIT License (MIT)

Copyright (c) 2015 pedro@gitdo.io

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
