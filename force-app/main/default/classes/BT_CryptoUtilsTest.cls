/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class:BT_CryptoUtilsTest
* Created by Sagar
*
* - Test class for BT_CryptoUtils

* - Modifications:
* - Sagar - Initial Development
************************************************************************** */
@isTest
public with sharing class BT_CryptoUtilsTest {
    public static testmethod void testAllMethods() {
        // Encrypt the string
        String encryptedString = BT_CryptoUtils.encrypt('AES256', String.valueOf(UserInfo.getUserId())+'01234567890123', 'String To Encrypt');
        // Decrypt the string
        String decryptedString = BT_CryptoUtils.decrypt('AES256', String.valueOf(UserInfo.getUserId())+'01234567890123', encryptedString);
        System.assertEquals(decryptedString, 'String To Encrypt');
        // Create signature
        BT_CryptoUtils.createSignature('GET\n\n\n01-12-2016-11:22:33\n/Bucket_Test_1/File1', 'Aqw3455343rereDdsdsggr1234567654');
    }
}