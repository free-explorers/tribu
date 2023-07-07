//
//  NotificationService.swift
//  TribuNotificationServiceExtension
//
//  Created by Tribu on 23/05/2022.
//

import UserNotifications
import CommonCrypto
import CryptoSwift

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let defaults = UserDefaults(suiteName: "group.com.tribu.default")
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let bestAttemptContent = bestAttemptContent {
            if(bestAttemptContent.threadIdentifier != ""){
                let encryptionKey = getSecureKey(key: bestAttemptContent.threadIdentifier);
                if bestAttemptContent.title != "" {
                    bestAttemptContent.title = (try? decryptData(encryptedTextWithIV: bestAttemptContent.title, encryptionKey: encryptionKey)) ?? bestAttemptContent.title
                }
                if bestAttemptContent.subtitle  != "" {
                    bestAttemptContent.subtitle = (try? decryptData(encryptedTextWithIV: bestAttemptContent.subtitle, encryptionKey: encryptionKey)) ?? bestAttemptContent.subtitle
                }
                if bestAttemptContent.body != "" {
                    bestAttemptContent.body = (try? decryptData(encryptedTextWithIV: bestAttemptContent.body, encryptionKey: encryptionKey)) ?? bestAttemptContent.body
                }
                if bestAttemptContent.badge as! Int > 0 {
                    var count: Int = defaults?.value(forKey: "count") as! Int
                    count = count + (bestAttemptContent.badge as! Int);
                    bestAttemptContent.badge = (count) as NSNumber
                    defaults?.set(count, forKey:"count")
                }
            }
            // Modify the notification content here... "JYPJOAz1glVyNO1UpgIFbaskig3uIkjC7ljncwNKqYM="
            
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func getSecureKey(key: String) ->String {
        let getquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrService as String: "flutter_secure_storage_service",
                                       kSecAttrAccount as String: key,
                                       kSecReturnData as String: kCFBooleanTrue!,
                                       kSecMatchLimit as String: kSecMatchLimitOne,
                                       kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
                                       kSecAttrSynchronizable as String: kCFBooleanFalse!,
                                       kSecAttrAccessGroup as String: "B54HUBPLW2.com.tribu.shared"
        ]
        var item: AnyObject?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else {  return "NoSuccess \(status)" }
        
        guard let data = item as? Data else {
            return "ItemNotData";
        };
        return String(data: data  , encoding:.utf8) ?? "FailedDecode";
    }
    
    func decryptData(encryptedTextWithIV: String, encryptionKey: String)throws ->String?{
        guard encryptedTextWithIV.count > 24 else {throw DecryptionError.tooShortToBeEncrypted}
        let encryptedText =
        String(encryptedTextWithIV.prefix(encryptedTextWithIV.count - 24));
        let iv = String(encryptedTextWithIV.suffix(24));
        guard let keyData = Data(base64Encoded: encryptionKey) else { throw DecryptionError.failedToDecodeKey }
        guard let ivData = Data(base64Encoded: iv) else { throw DecryptionError.failedToDecodeIv }

        let aes = try AES(key: keyData.bytes, blockMode: CTR(iv: ivData.bytes), padding: .pkcs7)
        
        let decryptedBytes = try aes.decrypt(Data(base64Encoded: encryptedText)!.bytes)
        let decryptedData = Data(decryptedBytes)
        let res = String(bytes: decryptedData, encoding: .utf8)
        return res;
    }

    /* func updateBadge(tribuId: String, badgeNumber: Int){
        let jsonString = defaults?.value(forKey: "\(tribuId)TribuInfo") as! String;
        let jsonData = jsonString?.data(using: .utf8);
        let tribuInfo: TribuInfo = try! JSONDecoder().decode(TribuInfo.self, from: jsonData);
        tribuInfo.unreadMessage += badgeNumber;
                let tribuInfo: TribuInfo = try! JSONEncoder().encode(TribuInfo.self, from: jsonData);

        defaults?.set(count, forKey:"count");
    } */
    
    
}

enum DecryptionError: Error {
    case tooShortToBeEncrypted
    case failedToDecodeKey
    case failedToDecodeIv
    case failedToDecrypt
}

struct TribuInfo: Decodable {
    let unreadMessage: Int
}