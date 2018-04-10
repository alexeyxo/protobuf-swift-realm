# ProtocolBuffers Swift Realm

An implementation of Protocol Buffers for Realm Data Models in Swift.

Protocol Buffers are a way of encoding structured data in an efficient yet extensible format. This project is based on an implementation of Protocol Buffers from Google. See the [Google protobuf project](https://developers.google.com/protocol-buffers/docs/overview) for more information.

#### Required [Protobuf Swift Realm Compiler](https://github.com/alexeyxo/protobuf-swift-realm-compiler)

## 📖 Table of content
<!--ts-->
   * [How to install](#-how-to-install)
     * [CocoaPods](#cocoapods)
   * [Compile proto files](#-compile-proto-files)
   * [Usage](#-usage)
     * [Get started](#-get-started)
     * [Primary Keys](#-primary-keys)    
     * [Indexing Properties](#-indexing-properties)
     * [Linking Objects](#-linking-objects)     
     * [Enums](#-enums) 
   * [Credits](#-credits)   
<!--te-->

## 🔨 How to install

### Cocoapods

```pod
use_frameworks!
pod 'ProtocolBuffers-Swift-Realm'
```

## 🚧 Compile proto files
Required [Protobuf Swift Realm Compiler](https://github.com/alexeyxo/protobuf-swift-realm-compiler)

```
protoc -I <FILENAME>.proto --swift_realm_out="./<OUT_DIR>"
```

## 👨‍💻 Usage
### 🚀 Get started
First of all you need to import swift-descriptor into your .proto files for using custom options:
```protobuf
import 'google/protobuf/swift-descriptor.proto';
```

Then, you need to add a custom option to generate [Realm Data Model Swift Classes](https://realm.io/docs/swift/latest/#models):
```protobuf
option (.google.protobuf.swift_message_options) = { generate_realm_object : true};
```

#### Example:

```Employee.proto``` will be generated into ```Example.Employee.realm.swift```

```protobuf
syntax = "proto2";
import "google/protobuf/swift-descriptor.proto";

package Example;

message Employee {
    option (.google.protobuf.swift_message_options) = { generate_realm_object : true };
    required string firstName = 1;
    required string lastName = 2;
    required double rank = 3;
    optional int32 level = 4;
}
```

#### Generated:
```swift
public class Example_Employee:Object {
    @objc dynamic var firstName:String = ""
    @objc dynamic var lastName:String = ""
    @objc dynamic var rank:Double = 0.0
    let level:RealmOptional<Int> = RealmOptional<Int>()
}
extension Example_Employee:ProtoRealm {
    public typealias PBType = Example.Employee
    public typealias RMObject = Example_Employee
    public typealias RepresentationType = Dictionary<String,Any>
    public static func map(_ proto: Example.Employee) -> Example_Employee {
        let rmModel = Example_Employee()
        rmModel.firstName = proto.firstName
        rmModel.lastName = proto.lastName
        rmModel.rank = proto.rank
        if proto.hasLevel {
            rmModel.level.value = Int(proto.level)
        } else {
            rmModel.level.value = nil
        }
        return rmModel
    }
    public func protobuf() throws -> Example.Employee {
        let proto = Example.Employee.Builder()
        proto.firstName = self.firstName
        proto.lastName = self.lastName
        proto.rank = self.rank
        if let valueLevel = self.level.value {
            proto.level = Int32(valueLevel)
        }
        return try proto.build()
    }
}
```

### 🔑 Primary Keys
Protobuf Swift Realm Compiler supports 2 ways to generate a [primary key](https://realm.io/docs/swift/latest/#primary-keys):

Add a field of supported type (```string``` or ```int```) with name "id" which will be automatically translated into a primary key:
```protobuf
message Employee {
    option (.google.protobuf.swift_message_options) = { generate_realm_object : true };
    required string id = 1;
    required string firstName = 2;
    required string lastName = 3;
}
```

or you can manually set a custom option for a necessary field:
#### Example:
```protobuf
message Employee {
    option (.google.protobuf.swift_message_options) = { generate_realm_object : true };
    required string key = 1 [(.google.protobuf.swift_field_options).realm_primary_key = true];
    required string firstName = 2;
    required string lastName = 3;
}
```

#### Generated:
```swift
public class Example_Employee:Object {
    @objc dynamic var key:String = ""
    @objc dynamic var firstName:String = ""
    @objc dynamic var lastName:String = ""
    public override class func indexedProperties() -> [String] {
        return ["key"]
    }
    public override class func primaryKey() -> String? {
        return "key"
    }
}

extension Example_Employee:ProtoRealm {
    public typealias PBType = Example.Employee
    public typealias RMObject = Example_Employee
    public typealias RepresentationType = Dictionary<String,Any>
    public static func map(_ proto: Example.Employee) -> Example_Employee {
        let rmModel = Example_Employee()
        rmModel.key = proto.key
        rmModel.firstName = proto.firstName
        rmModel.lastName = proto.lastName
        return rmModel
    }
    public func protobuf() throws -> Example.Employee {
        let proto = Example.Employee.Builder()
        proto.key = self.key
        proto.firstName = self.firstName
        proto.lastName = self.lastName
        return try proto.build()
    }
}
```

## 👉 Indexing Properties
To [index](https://realm.io/docs/swift/latest/#indexing-properties) a property use a custom option:

```protobuf
option (.google.protobuf.swift_field_options).realm_indexed_propertie = true;
```
#### Example:

```protobuf
message Employee {
    option (.google.protobuf.swift_message_options) = { generate_realm_object : true };
    required string id = 1 [(.google.protobuf.swift_field_options).realm_indexed_propertie = true];
    required string firstName = 2;
    required string lastName = 3;
}
```

#### Generated:
```swift
public class Example_Employee:Object {
    @objc dynamic var id:String = ""
    @objc dynamic var firstName:String = ""
    @objc dynamic var lastName:String = ""
    public override class func indexedProperties() -> [String] {
        return ["id"]
    }
    public override class func primaryKey() -> String? {
        return "id"
    }
}
extension Example_Employee:ProtoRealm {
    public typealias PBType = Example.Employee
    public typealias RMObject = Example_Employee
    public typealias RepresentationType = Dictionary<String,Any>
    public static func map(_ proto: Example.Employee) -> Example_Employee {
        let rmModel = Example_Employee()
        rmModel.id = proto.id
        rmModel.firstName = proto.firstName
        rmModel.lastName = proto.lastName
        return rmModel
    }
    public func protobuf() throws -> Example.Employee {
        let proto = Example.Employee.Builder()
        proto.id = self.id
        proto.firstName = self.firstName
        proto.lastName = self.lastName
        return try proto.build()
    }
}
```

### 🔗 Linking Objects
To create a [link](https://realm.io/docs/swift/latest/api/Classes/LinkingObjects.html) between an object and his owning model object you need to add a custom option:
```protobuf
option (.google.protobuf.swift_message_options) = {
    linkedObjects : [{
        fieldName : "department"
        fromType : "Department"
        propertyName : "employees"
        packageName : "Example"
    }]
};
```

* **fieldName**: field name in owned object
* **fromType**: class name of owner object
* **propertyName**: field name in owner object
* **packageName**: a name of your protobuf package

#### Example:
```protobuf
syntax = "proto2";
import "google/protobuf/swift-descriptor.proto";
package Example;

message Employee {
    option (.google.protobuf.swift_message_options) = {
        generate_realm_object : true
        linkedObjects : [{
            fieldName : "department"
            fromType : "Department"
            propertyName : "employees"
            packageName : "Example"
        }]
    };
    required string id = 1;
    required string firstName = 2;
    required string lastName = 3;
}

message Department {
    option (.google.protobuf.swift_message_options) = { generate_realm_object : true};
    required string id = 1;
    required string name = 2;
    repeated Employee employees = 3;
}
```

#### Generated:
```swift
public class Example_Employee:Object {
    @objc dynamic var id:String = ""
    @objc dynamic var firstName:String = ""
    @objc dynamic var lastName:String = ""
    let department = LinkingObjects(fromType: Department.self, property:"employees")
    public override class func indexedProperties() -> [String] {
        return ["id"]
    }
    public override class func primaryKey() -> String? {
        return "id"
    }
}
public class Example_Department:Object {
    @objc dynamic var id:String = ""
    @objc dynamic var name:String = ""
    let employees:List<Example_Employee> = List<Example_Employee>()
    public override class func indexedProperties() -> [String] {
        return ["id"]
    }
    public override class func primaryKey() -> String? {
        return "id"
    }
}
extension Example_Employee:ProtoRealm {
    public typealias PBType = Example.Employee
    public typealias RMObject = Example_Employee
    public typealias RepresentationType = Dictionary<String,Any>
    public static func map(_ proto: Example.Employee) -> Example_Employee {
        let rmModel = Example_Employee()
        rmModel.id = proto.id
        rmModel.firstName = proto.firstName
        rmModel.lastName = proto.lastName
        return rmModel
    }
    public func protobuf() throws -> Example.Employee {
        let proto = Example.Employee.Builder()
        proto.id = self.id
        proto.firstName = self.firstName
        proto.lastName = self.lastName
        return try proto.build()
    }
}
extension Example_Department:ProtoRealm {
    public typealias PBType = Example.Department
    public typealias RMObject = Example_Department
    public typealias RepresentationType = Dictionary<String,Any>
    public static func map(_ proto: Example.Department) -> Example_Department {
        let rmModel = Example_Department()
        rmModel.id = proto.id
        rmModel.name = proto.name
        rmModel.employees.append(objectsIn:Example_Employee.map(proto.employees))
        return rmModel
    }
    public func protobuf() throws -> Example.Department {
        let proto = Example.Department.Builder()
        proto.id = self.id
        proto.name = self.name
        proto.employees += try self.employees.map({ value in
            return try value.protobuf()
        })
        return try proto.build()
    }
}

```


### 🔣 Enums

> Realm actually doesn't support Enums, but we do!

To work with enums add a custom option:
```protobuf
option (.google.protobuf.swift_enum_options) = { generate_realm_object : true};
```

#### Example:

```protobuf
enum DepartmentType {
    option (.google.protobuf.swift_enum_options) = { generate_realm_object : true };
    DELIVERY = 0;
    MANAGEMENT = 1;
    SUPPORT = 2;
}	
```

#### Generated:
```swift
public class Example_DepartmentType:Object {
    @objc dynamic var rawValue:String = ""
    public override class func primaryKey() -> String? {
        return "rawValue"
    }
    public override class func indexedProperties() -> [String] {
        return ["rawValue"]
    }
}

extension Example_DepartmentType:ProtoRealm {
    public typealias PBType = Example.DepartmentType
    public typealias RMObject = Example_DepartmentType
    public typealias RepresentationType = String
    public static func map(_ proto: Example.DepartmentType) -> Example_DepartmentType {
        let rmModel = Example_DepartmentType()
        rmModel.rawValue = proto.toString()
        return rmModel
    }
    public func protobuf() throws -> Example.DepartmentType {
        return try Example.DepartmentType.fromString(self.rawValue)
    }
}
```

## 👏 Credits


Developer - Alexey Khokhlov

Google Protocol Buffers - Cyrus Najmabadi, Sergey Martynov, Kenton Varda, Sanjay Ghemawat, Jeff Dean, and others




