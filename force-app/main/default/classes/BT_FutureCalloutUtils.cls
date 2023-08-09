/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Util Class: BT_FutureCalloutUtils
* Created by Sagar
*
* - All future method utils

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_FutureCalloutUtils {
    /*
    *   Executed:   After downlaoding the private files, access for that file need to be revoked.
    *   Parameters: bucketName  : Bucket Name of the file
                    filePath    : File Path whose access needs to be revoked
    *   UnitTests:  
    */
    @future(callout=true)
    public static void revokeFileAccessControl(String bucketName, String filePath){
        // Revoke the access in future method
        Datetime now = DateTime.now();
        
        // Get the credentials
        AmazonS3Credential s3LinkConfig = new AmazonS3Credential();
        S3.AmazonS3 amazonS3 = new S3.AmazonS3(s3LinkConfig.key,s3LinkConfig.secret);
        
        // The canonical user Id. This is the owner of the files. Access will be revoked from everyone and granted only to file owner.
        String canonicalUserId = BT_HomeUtils.getAmazonCanonicalUserId();
        
        // Revoke the file access.
        amazonS3.SetObjectAccessControlPolicy(bucketName, filePath, null, amazonS3.key, now, amazonS3.signature('SetObjectAccessControlPolicy', now), amazonS3.secret, canonicalUserId);
        return;
    }
}