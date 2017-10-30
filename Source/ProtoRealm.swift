//
//  ProtoRealm.swift
//
//  Created by Alexey Khokhlov on 06.04.17.
//

import Foundation
import ProtocolBuffers
import RealmSwift

public protocol ProtoRealm {
    associatedtype PBType
    associatedtype RMObject:Object
    associatedtype RepresentationType
    static func map( _ proto: PBType) -> RMObject
    static func map( _ proto: [PBType]) -> [RMObject]
    func protobuf() throws -> PBType
    func merge( _ from: List<RMObject>, _ to: List<RMObject>)
    func represent() throws -> RepresentationType
}

public extension ProtoRealm {
    public func merge( _ from: List<RMObject>, _ to: List<RMObject>) {
        from.forEach { object in
            to.append(object)
        }
    }
    public static func map( _ proto: [PBType]) -> [RMObject] {
        return proto.map({ return self.map($0)})
    }
}

public extension ProtoRealm where PBType:GeneratedMessageProtocol, RepresentationType == Dictionary<String,Any> {
    public func represent() throws -> RepresentationType {
        return try self.protobuf().encode()
    }
    static func modelFrom(data:Data) throws -> RMObject {
        return try Self.map(PBType.parseFrom(data: data))
    }
    static func modelFrom(json:[String:Any]) throws -> RMObject {
        return try Self.map(PBType.decode(jsonMap: json))
    }
}

public extension ProtoRealm where PBType:GeneratedEnum, RepresentationType == String {
    public func represent() throws -> RepresentationType {
        return try self.protobuf().toString()
    }
}

public extension Results where Element: ProtoRealm {
    func protobuf() throws -> [Element.PBType] {
        return try self.map({
            return try $0.protobuf()
        })
    }
}

public extension Array where Element:ProtoRealm {
    func protobuf() throws -> [Element.PBType] {
        return try self.map({
            return try $0.protobuf()
        })
    }
}
