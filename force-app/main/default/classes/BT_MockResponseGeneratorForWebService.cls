/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_MockResponseGeneratorForWebService
* Created by Sagar: 21/09/2017
*
* - This class will be used to generate the mock response for web service callouts

* - Modifications:
* - Sagar, 21/09/2017 – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_MockResponseGeneratorForWebService implements WebServiceMock {
    public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        if(requestName == 'ListBucket'){
            S3.ListBucketResponse_element listBucketResponseElement = new S3.ListBucketResponse_element();
            S3.ListBucketResult listBucketResponse = new S3.ListBucketResult();
            listBucketResponse.Metadata = new List<S3.MetadataEntry>{new S3.MetadataEntry()};
            S3.ListEntry listEntry = new S3.ListEntry();
            listEntry.Key = 'Test_Bucket1_Sub_Folder1/File1.jpg';
            listBucketResponse.Contents = new List<S3.ListEntry>{listEntry};
            listBucketResponse.CommonPrefixes = new List<S3.PrefixEntry>{new S3.PrefixEntry()};
            listBucketResponseElement.ListBucketResponse = listBucketResponse;
            response.put('response_x', listBucketResponseElement); 
        } else if(requestName == 'DeleteObject'){
            response.put('response_x', new S3.DeleteObjectResponse_element()); 
        } else if(requestName == 'ListAllMyBuckets'){
            S3.ListAllMyBucketsResponse_element listAllMyBucketResponseElement = new S3.ListAllMyBucketsResponse_element();
            S3.ListAllMyBucketsResult listAllMyBucketsResponse = new S3.ListAllMyBucketsResult();
            S3.ListAllMyBucketsList listAllMyBucketsList = new S3.ListAllMyBucketsList();
            S3.ListAllMyBucketsEntry bucketEntry = new S3.ListAllMyBucketsEntry();
            bucketEntry.Name = 'Test_Bucket1';
            listAllMyBucketsList.Bucket = new List<S3.ListAllMyBucketsEntry>{bucketEntry};
            listAllMyBucketsResponse.Buckets = listAllMyBucketsList;
            listAllMyBucketsResponse.Owner = new S3.CanonicalUser();
            listAllMyBucketResponseElement.ListAllMyBucketsResponse = listAllMyBucketsResponse;
            response.put('response_x', listAllMyBucketResponseElement); 
        } else if(requestName == 'CreateBucket'){
            S3.CreateBucketResponse_element createBucketResponseElement = new S3.CreateBucketResponse_element();
            createBucketResponseElement.CreateBucketResponse = new S3.CreateBucketResult();
            response.put('response_x', createBucketResponseElement); 
        } else if(requestName == 'DeleteBucket'){
            response.put('response_x', new S3.DeleteBucketResponse_element());
        } else{
            response.put('response_x', 'No result'); 
        }
        System.assertEquals(response.get('response_x') != null, true);
   }
}