/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Controller Class:S3Test
* Created by Sagar: 21/09/2017
*
* - Test class S3

* - Modifications:
* - Sagar, 21/09/2017 – Initial Development
************************************************************************** */
@isTest
public with sharing class S3Test {
   public static testmethod void test1() {
       Test.StartTest();
        // Setting mock response for test class
        Test.setMock(WebServiceMock.class, new BT_MockResponseGeneratorForWebService());
        S3.AmazonS3 amazonS3 = new S3.AmazonS3(); 
        S3.Status deleteObjectResponse = amazonS3.DeleteObject( '','','',system.now(),'','');
        System.assertEquals(deleteObjectResponse == null , true);
        Test.StopTest();
   }
   
    public static testmethod void test2() {
    Test.StartTest();
        // Setting mock response for test class
        Test.setMock(WebServiceMock.class, new BT_MockResponseGeneratorForWebService());
        S3.AmazonS3 amazonS3 = new S3.AmazonS3();
        amazonS3.secret = '42';
        S3.ListBucketResult listBucketResponseElement = amazonS3.ListBucket( '','','', 3,'','key',system.now(),'sig','cred');   
        System.assertEquals(listBucketResponseElement != null , true); 
        Test.StopTest();
    }
 
    public static testmethod void test3() {
    Test.StartTest();
        // Set mock callout class
        Test.setMock(WebServiceMock.class, new BT_MockResponseGeneratorForWebService());
        S3.AmazonS3 S3 = new S3.AmazonS3();
        S3.secret = '42';
        S3.ListAllMyBucketsResult listAllMyBucketResponseElement = S3.ListAllMyBuckets('key',system.now(),'sig');
        System.assertEquals(listAllMyBucketResponseElement != null , true);
        Test.StopTest();
    }  
   
    public static testmethod void test4() {
    Test.StartTest();
        // Setting mock response for test class
        Test.setMock(WebServiceMock.class, new BT_MockResponseGeneratorForWebService());
        S3.AmazonS3 S3 = new S3.AmazonS3();
        S3.secret = '42';
        s3.AccessControlList acl = new s3.AccessControlList();
        S3.CreateBucketResult createBucketResponseElement = S3.CreateBucket('bucket',acl,'key',system.now(),'sig');
        System.assertEquals(createBucketResponseElement != null , true);
        Test.StopTest();
    }
   
    public static testmethod void test5() {
    Test.StartTest();
        // Setting mock response for test class
        Test.setMock(WebServiceMock.class, new BT_MockResponseGeneratorForWebService());
        S3.AmazonS3 S3 = new S3.AmazonS3();
        S3.secret = '42';
        S3.Status deleteBucketResponse = S3.DeleteBucket('bucket','key',system.now(),'sig','cred');
        System.assertEquals(deleteBucketResponse == null , true);
        Test.StopTest();
    }
      
    public static testmethod void test6(){
    Test.StartTest();
       S3.AmazonS3 amazonS3 = new S3.AmazonS3();
       System.assertEquals(amazonS3 != null , true);
       Test.StopTest();
    }
  
    public static testmethod void test7(){
    Test.StartTest();
      S3.AmazonS3 S3 = new S3.AmazonS3('key','secret');
      try{
        Boolean isSuccess = S3.PutObjectInline_ACL('bucket','key',null,'datatesting',6,'public-read','keyid',System.now(),S3.signature('PutObjectInline_ACL', DateTime.now()),'cred', 'ownerid') ;
        System.assertEquals(isSuccess , true);
      } catch(Exception ex){
      }
      Test.StopTest();
    }
    
    public static testmethod void test8(){
    Test.StartTest();
      S3.AmazonS3 S3 = new S3.AmazonS3();
      S3.secret = '42';
      try{
        Boolean isSuccess = S3.CopyObject_ACL('sourcebucket','sourcekey','destbucket','destkey',null, 'public-read','keyid',System.now(),'sig','cred', 'ownerid') ;
        System.assertEquals(isSuccess , true);
      } catch(Exception ex){
      }
      Test.StopTest();
    }
    
}