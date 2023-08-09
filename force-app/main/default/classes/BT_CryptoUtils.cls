/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Util Class: BT_CryptoUtils
* Created by Sagar
*
* - Handles all Crypto methods

* - Modifications:
* - Sagar– Initial Development
************************************************************************** */
public with sharing class BT_CryptoUtils {
    public static string encrypt(String algorithmName, String key, String stringToEncrypt){
        //16 byte string. since characters used are ascii, each char is 1 byte.
        Blob blobKey = Blob.valueOf(key);
        //encrypted blob
        Blob cipherText = Crypto.encryptWithManagedIV(algorithmName, blobKey, Blob.valueOf(stringToEncrypt));
        //encrypted string
        return EncodingUtil.base64Encode(cipherText);
    }
    
    public static string decrypt(String algorithmName, String key, String encodedCipherText){
        //encrypted blob
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encodedCipherText);
        Blob blobKey = Blob.valueOf(key);
        //decrypted blob
        Blob decryptedBlob = Crypto.decryptWithManagedIV(algorithmName, blobKey, encodedEncryptedBlob);
        //decrypted string
        return decryptedBlob.toString();
    }
    
    /*
    *   Executed:   When user will click download link
    *   Purpose:    This will be used to sign the request user made.
    *   Parameters: canonicalBuffer: Body of the requiest with the required credentials 
    *   UnitTests:  
    */
    public static String createSignature(string canonicalBuffer, String secret) {        
        String signature ;
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(secret));
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(secret)); 
        signature = EncodingUtil.base64Encode(mac);                
        return signature;
    }
}