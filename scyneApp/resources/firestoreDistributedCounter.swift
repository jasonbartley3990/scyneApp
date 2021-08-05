//
//  firestoreDistributedCounter.swift
//  scyneApp
//
//  Created by Jason bartley on 6/4/21.
//

import Foundation
import FirebaseFirestore

struct firestoreDistributedCounterKey {
    static let numShards = "numShards"
    static let shards = "shards"
    static let count = "count"
}

struct firestoreDistributedArrayKey {
    static let numShards = "arrayShards"
    static let shards = "shards"
    static let array = "array"
}

class firestoreDistributedCounter {
    
    static func createCounter(ref: DocumentReference, numShards: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
                                
        let batch = Firestore.firestore().batch()
        
        batch.setData([firestoreDistributedCounterKey.numShards: numShards], forDocument: ref)
        
        for i in 0...numShards-1 {
            let shardsRef = ref.collection(firestoreDistributedCounterKey.shards).document(String(i))
            batch.setData([firestoreDistributedCounterKey.count: 0], forDocument: (shardsRef))
            
        }
        
        batch.commit(completion: { (err) in
            if let err = err {
                completion(.failure(err))
            }
            completion(.success(true))
        })
        
    }
    
    static func incrementCounter(by: Int, ref: DocumentReference, numShards: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        let shardId = Int.random(in: 0..<numShards)
        let shardRef = ref.collection(firestoreDistributedCounterKey.shards).document(String(shardId))
        
        shardRef.updateData([ firestoreDistributedCounterKey.count: FieldValue.increment(Int64(by))]) { err in
            
            if let err = err {
                completion(.failure(err))
            }
            completion(.success(true))
        }
    }
    
    static func getCount(ref: DocumentReference, completion: @escaping (Result<Int, Error>) -> ()) {
        ref.collection(firestoreDistributedCounterKey.shards).getDocuments(completion: {
            snapshot, error in
            var totalCount = 0
            if let err = error {
                completion(.failure(err))
            }
            
            for document in snapshot!.documents {
                guard let count = document.data()[firestoreDistributedCounterKey.count] as? Int else {return}
                totalCount = totalCount + count
            }
            completion(.success(totalCount))
        })
    }
}

class firestoreDistributedArray {
    
    static func createArrays(ref: DocumentReference, numShards: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
                                
        let batch = Firestore.firestore().batch()
        
        batch.setData([firestoreDistributedArrayKey.numShards: numShards], forDocument: ref)
        
        for i in 0...numShards-1 {
            let shardsRef = ref.collection(firestoreDistributedArrayKey.shards).document(String(i))
            batch.setData([firestoreDistributedArrayKey.array: [String]()], forDocument: (shardsRef))
            
        }
        
        batch.commit(completion: { (err) in
            if let err = err {
                completion(.failure(err))
            }
            completion(.success(true))
        })
        
    }
    
    static func appendArray(with email: String, ref: DocumentReference, numShards: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        let shardId = Int.random(in: 0..<numShards)
        let shardRef = ref.collection(firestoreDistributedArrayKey.shards).document(String(shardId))
        
        shardRef.updateData([ firestoreDistributedArrayKey.array : FieldValue.arrayUnion([email])]) { err in
            
            if let err = err {
                completion(.failure(err))
            }
            completion(.success(true))
        }
    }
    
    static func removeFromArray(with email: String, ref: DocumentReference, numShards: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        for document in 0..<numShards {
            let docId = String(document)
            let shardRef = ref.collection(firestoreDistributedArrayKey.shards).document(docId)
            shardRef.updateData([ firestoreDistributedArrayKey.array: FieldValue.arrayRemove([email])]) { err in
                if let err = err {
                    completion(.failure(err))
                }
                completion(.success(true))
            }
        }
    }
    
    
    
    static func getArrayCount(ref: DocumentReference, completion: @escaping (Result<[String], Error>) -> ()) {
        ref.collection(firestoreDistributedArrayKey.shards).getDocuments(completion: {
            snapshot, error in
            var finalArray = [String]()
            if let err = error {
                completion(.failure(err))
            }
            
            for document in snapshot!.documents {
                guard let array = document.data()[firestoreDistributedArrayKey.array] as? [String] else {return}
                finalArray = finalArray + array
            }
            completion(.success(finalArray))
        })
    }
}
