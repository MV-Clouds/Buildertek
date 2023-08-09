/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_TestUtils
* Created by Sagar: 26/05/2017
*
* - Used to create the test data.

* - Modifications:
* - Sagar, 26/05/2017 – Initial Development
************************************************************************** */
@isTest
public class BT_TestUtils {
    public static User createUser(String alias, String emailAddress, String userName){
        // create a user
        Profile p = [Select Id From Profile Where Name = 'System Administrator'];
        User testUser = new User(alias=alias, email=emailAddress, 
                    emailencodingkey='UTF-8', lastname='testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid=p.id, 
                    timezonesidkey='America/Los_Angeles', username=userName);
        insert testUser;
        System.assertEquals(testUser.Id != null, true);
        return testUser;
    }
    
    public static List<Folder__c> createFoldersForBuckets(){
        List<Folder__c> bucketFolders = new List<Folder__c>();
        Folder__c bucket1 = new Folder__c(Name='Test_Bucket1');
        bucket1.Parent__c = null;
        bucket1.Active__c = true;
        bucket1.Default__c = true;
        bucketFolders.add(bucket1);
        Folder__c bucket2 = new Folder__c(Name='Test_Bucket2');
        bucket2.Parent__c = null;
        bucket2.Active__c = true;
        bucketFolders.add(bucket2);
        Folder__c bucket3 = new Folder__c(Name='Test_Bucket3');
        bucket3.Parent__c = null;
        bucket3.Active__c = true;
        bucketFolders.add(bucket3);
        insert bucketFolders;
        return bucketFolders;
    }
    
    public static List<Folder__c> createSubfolders(Folder__c parentFolder, Account account){
        List<Folder__c> subFolders = new List<Folder__c>();
        Folder__c sub1 = new Folder__c(Name= parentFolder.Name+'_Sub_Folder1');
        sub1.Bucket_Name__c = parentFolder.Name;
        sub1.Parent__c = parentFolder.Id;
        if(account != null){
            sub1.Account__c = account.Id;
        }
        subFolders.add(sub1);
        Folder__c sub2 = new Folder__c(Name= parentFolder.Name+'_Sub_Folder2');
        sub2.Bucket_Name__c = parentFolder.Name;
        sub2.Parent__c = parentFolder.Id;
        if(account != null){
            sub2.Account__c = account.Id;
        }
        subFolders.add(sub2);
        Folder__c sub3 = new Folder__c(External_Folder_Name__c = parentFolder.Name+'_Sub_Folder3',Name= parentFolder.Name+'_Sub_Folder3');
        sub3.Bucket_Name__c = parentFolder.Name;
        sub3.Parent__c = parentFolder.Id;
        if(account != null){
            sub3.Account__c = account.Id;
        }
        subFolders.add(sub3);
        insert subFolders;
        return subFolders;
    }
    
    public static List<File__c> createFiles(Folder__c folder, Account account){
        
        // Create AWS credentials
        createAWSCredentials(); 
        
        // Create files
        List<File__c> files = new List<File__c>();
        File__c file1 = new File__c(Name= 'File1.png');
        file1.Folder__c = folder.Id;
        file1.Bucket_Name__c = 'Test_Bucket1';
        file1.Extension__c = '.png';
        file1.Size__c = 5000;
        file1.Content_Type__c = 'image/png';
        file1.Track_Download_History__c = true;
        if(account != null){
            file1.Account__c = account.Id;
        }
        files.add(file1);
        File__c file2 = new File__c(Name= 'File2.png');
        file2.Folder__c = folder.Id;
        file2.Bucket_Name__c = 'Test_Bucket1';
        file2.Extension__c = '.jpg';
        file2.Size__c = 5001;
        file2.Content_Type__c = 'image/jpg';
        if(account != null){
            file2.Account__c = account.Id;
        }
        files.add(file2);
        File__c file3 = new File__c(Name= 'File3.png');
        file3.Folder__c = folder.Id;
        file3.Bucket_Name__c = 'Test_Bucket1';
        file3.Extension__c = '.pdf';
        file3.Size__c = 5000;
        file3.Content_Type__c = 'image/pdf';
        if(account != null){
            file3.Account__c = account.Id;
        }
        files.add(file3);
        insert files;
        return files;
    }
    
    public static List<File_Access_Control__c> createFileAccessControls(File__c file){
        List<File_Access_Control__c> fileAccessControls = new List<File_Access_Control__c>();
        fileAccessControls.add(new File_Access_Control__c(File__c = file.Id, Grantee__c = UserInfo.getUserId(), Download__c = true));
        insert fileAccessControls;
        return fileAccessControls;
    }
    
    public static List<File_Download_History__c> createFileDownloadHistory(File__c file){
            List<File_Download_History__c> fileDownloadHistories = new List<File_Download_History__c>();
            fileDownloadHistories.add(new File_Download_History__c(File__c = file.Id, Type__c = 'Download', DownloadedBy__c = UserInfo.getUserId(), DownloadedDate__c = System.now()));
            insert fileDownloadHistories;
            return fileDownloadHistories;
    }
    
    public static Account createAccount(){
        Account testAccount = new Account(name='testAccount');
        insert testAccount;
        return testAccount;
    }
    public static void createAWSCredentials(){
        //Check if AWS credentilals are already created
        Map<String, Amazon_S3_Key__c> appConfigurationMap = Amazon_S3_Key__c.getAll();
        Amazon_S3_Key__c configForPublicKey = appConfigurationMap.get(BT_Constants.AWS_PUBLIC_KEY);
        Amazon_S3_Key__c configForSecretKey = appConfigurationMap.get(BT_Constants.AWS_SECRET_KEY);
        
        if(configForPublicKey != null){
            return;
        }
        
        //Creating AMazn S3 credentials
        Amazon_S3_Key__c credentialObjForKey = new Amazon_S3_Key__c(Name=BT_Constants.AWS_PUBLIC_KEY);
        credentialObjForKey.Configured_Value__c ='Ad2sdadf41212wsas2ed';
        insert credentialObjForKey;
        Amazon_S3_Key__c credentialObjForSecret = new Amazon_S3_Key__c(Name=BT_Constants.AWS_SECRET_KEY);
        credentialObjForSecret.Configured_Value__c ='232dasaweg34r45bwergr6t';
        insert credentialObjForSecret;
    }
    
    public static void enableFileDownloadHistory(){
        //Enabling download history
        Application_Configuration__c enableDownlaodHistoryObj = new Application_Configuration__c(Name=BT_Constants.ENABLE_FILE_DOWNLOAD_HISTORY);
        enableDownlaodHistoryObj.Configured_Value__c ='true';
        insert enableDownlaodHistoryObj;
    }
    
    public static void createFileExplorerConfiguration(){
        //File Explorer configuration
        BT_FileExplorerPageConfigController con = new BT_FileExplorerPageConfigController();
        con.initialize();
    }
    
    public static void createFileUploadConfiguration(){
        //File upload configuration
        BT_FileUploadPageConfigurationController con = new BT_FileUploadPageConfigurationController();
        con.initialize();
    }
}