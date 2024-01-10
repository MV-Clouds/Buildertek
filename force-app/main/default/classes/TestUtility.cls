public with sharing class TestUtility {
  
  // Create contact
  public Static List<Contact> con {
     get {
       if(con == null) {
         con = new List<Contact>{ 
            new Contact(LastName = 'Test1' , Compliance_Owner__c=userInfo.getUserId(), Email = 'abc@test.com', Compliance_Status__c = 'Cleared' , LEA__C = 'Yorkshire & Humberside', Current_LEA__c = 'Bristol' , Sub_LEA__c = 'Rotherham' , SGP_Team__c ='East Anglia' , TR1__State_Area__c = 'United Kingdom',TR1__Regional_Area__c = 'Devon', Sub_Regional_Area__c = 'Plymouth',Trained_As__c='Cover Supervisor',Subject__c='Art',Sector__c='College (6th)',Job_Titles__c='1-2-1 Tutor (Primary)',Assignment_Type__c='Day to Day'),
            new Contact(LastName = 'Test' ,Compliance_Owner__c=userInfo.getUserId(),  Email = 'abcd@test.com', Compliance_Status__c = 'Cleared' , LEA__C = 'Yorkshire & Humberside',Current_LEA__c = 'Bristol' , Sub_LEA__c = 'Rotherham' , SGP_Team__c ='East Anglia' , TR1__State_Area__c = 'United Kingdom',TR1__Regional_Area__c = 'Devon', Sub_Regional_Area__c = 'Plymouth',Trained_As__c='Cover Supervisor',Subject__c='Art',Sector__c='College (6th)',Job_Titles__c='1-2-1 Tutor (Primary)',Assignment_Type__c='Day to Day')
         };
         insert con;
       }
       return con;
     }
  }
public Static DateTime formatDateTimefromDate(Date dateVar,String startTime){
        
        String startDateTime = dateVar.format();            
        String startTimeHour = startTime.split(':')[0];
        String startTimeMinute = startTime.split(':')[1].remove(' AM').remove(' PM');
        
        if (startTime.contains(' AM') && startTimeHour=='12') {
            startTimeHour = '00';
        }
        
        Datetime returnDt = Datetime.newInstance(
            dateVar.year(),
            dateVar.month(),
            dateVar.day(),
            Integer.valueOf(startTimeHour),
            Integer.valueOf(startTimeMinute),
            00
        );
        
        if (startTime.contains(' PM') && startTimeHour !='12') {
            
            returnDt = returnDt.addHours(12);
        }
        
        return returnDt;        
    }  
  // Create a List of Account
  public static list<Account> accList {
        get {
           if(accList == null) {
             accList = new list<Account> {
               new Account(Name = 'Test' , Email__c = 'abc@test.com', Terms_Agreed__c = 'Yes' , ShippingStreet = 'Test', BillingCity = 'Test' , BillingPostalCode = '000' , ShippingState = 'Tes'), 
               new Account(Name = 'Test1', Email__c = 'abc@test.com', Terms_Agreed__c = 'Yes')
             };
             insert accList;
           }
           return accList;
        }
  }       
    Public Static User getUserDetail(){
         
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');

                insert r;
Profile objProfile = [select Id,name from Profile where name ='System Administrator' limit 1];
            User u1= new User(
                profileId = objProfile.id, 
                username = 'newUserok@yahoo.com', 
                email = 'pb@ff1.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname',
                UserRoleId = r.Id
               
            );
        insert u1;
        return u1;
        
    }

     public Static Account getAccountDetail(){
        Account acc = new Account(Name='CVP',BillingState='TEst',Account_Code_S__c='32323');
        insert acc;
         return acc;
     }
    //the following two methods are written as to make sure that previous test methods were following same coding
    // the following methods are written just to make life simplier if any mandatory fields are introduced in production.
     public Static Contact getContactDetailWithoutRT(User u1,Account acc){
    

       Contact cont = new Contact(Pay_Type__c = 'FE Qualified', LastName='CVP Contact',Subject__c='Art',Email='test@test.com',AccountId = acc.Id,TR1__Candidate_Status__c = 'Prospect',Compliance_Status__c = 'Vet Complete', Compliance_Owner__c=u1.Id,Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Job_Titles__c='1-2-1 Tutor (Primary)',Assignment_Type__c='Day to Day', Qualified_Schools_Candidate__c = 'YES');
       return cont;
    }
    public Static Contact getContactDetail(User u1,Account acc){
Id conCandidId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        

        Contact cont=      new Contact(LastName='CVP Contact',Subject__c='Art',Email='test@test.com',AccountId = acc.Id,RecordTypeId = conCandidId, Compliance_Status__c = 'Clearance Pending',Compliance_Owner__c=u1.Id,Payroll_Number__c='343434',Trained_As__c='Cover Supervisor',Sector__c='College (6th)',Job_Titles__c='1-2-1 Tutor (Primary)',Assignment_Type__c='Day to Day');
       return cont;
    }
  // Create Job
  public Static TR1__Job__c job {
     get {if(job == null) {job = new TR1__Job__c(TR1__Account__c = accList[0].id,TR1__Status__c = 'Open',TR1__Client_Description__c ='test',TR1__Education_Requirements__c='aaa',TR1__Experience_Requirements__c='bbb',TR1__Responsibilities__c='ccc',TR1__State_Area__c='test',TR1__Regional_Area__c='test',Booking_Type__c='test',TR1__Division__c='test',TR1__Primary_Background__c='test',TR1__Estimated_Start_Date__c = System.today().addDays(-30),TR1__Estimated_End_Date__c = System.today().addDays(90),RecordtypeId = TRS_vacancyhelper.CONSULTING_RTID,Friday_s_Shift__c = 'Full Day',Monday_s_Shift__c = 'Full Day',Saturday_s_Shift__c = 'Full Day',Sunday_s_Shift__c = 'Full Day',Thursday_s_Shift__c = 'Full Day',Tuesday_s_Shift__c = 'Full Day',Wednesday_s_Shift__c = 'Full Day');
        insert job;}return job;}}
  
  /*
  // Create Permanent Closing Report
  public Static TR1__Closing_Report__c permanentClosingReport {
     get {
       RecordType perm = [Select Id from RecordType where SObjectType = 'TR1__Closing_Report__c' and Name = :Invoicing_Constants.PERMANENT]; 
      System.assertEquals(true , perm != null);
      
      permanentClosingReport = new TR1__Closing_Report__c(TR1__Account__c = accList[0].id , TR1__Start_DAte__c = System.Today() ,TR1__END_DAte__c = System.Today()+14 ,
                            TR1__Person_Placed__c = con[0].id ,TR1__Job_Percentage__c =25 ,TR1__Candidate_Percentage__c = 25,
                            TR1__Administrative_Fee_Percentage__c = 20 ,TR1__Marketing_Percentage__c = 10 ,
                            TR1__Other_Percentage__c  =20 ,TR1__Other2_Percentage__c =20 ,TR1__Generate_Timesheet__c = true ,
                            TR1__Job__c = job.Id ,TR1__Rate_Change_Effective_Date__c = System.Today(), Invoice_Status__c = Invoicing_Constants.PENDING,
                            TR1__Conversion_Date__c = System.Today() +14,  TR1__Salary__c   = 500 ,TR1__Fee_Percentage__c = 10,
                            TR1__Discount_Amount__c = 200 , RecordTypeId = perm.id, TR1__Invoice_Date__c = System.today());
           
       insert permanentClosingReport;
       return permanentClosingReport;
     }
  }
   
  // Create Consulting Closing Report
  public Static TR1__Closing_Report__c consultingClosingReport {
     get {
       RecordType consulting = [Select Id from RecordType where SObjectType = 'TR1__Closing_Report__c' and Name = :Invoicing_Constants.CONSULTING]; 
      System.assertEquals(true , consulting != null);
      
      consultingClosingReport = new TR1__Closing_Report__c(TR1__Account__c = accList[0].id , TR1__Start_DAte__c = System.Today() ,TR1__END_DAte__c = System.Today()+14 ,
                            TR1__Person_Placed__c = con[0].id ,TR1__Job_Percentage__c =25 ,TR1__Candidate_Percentage__c  =25,
                            TR1__Administrative_Fee_Percentage__c = 20 ,TR1__Marketing_Percentage__c  = 10 ,
                            TR1__Other_Percentage__c  =20 ,TR1__Other2_Percentage__c =20 ,TR1__Generate_Timesheet__c = true ,
                            TR1__Job__c = job.Id ,TR1__Rate_Change_Effective_Date__c = System.Today(), Invoice_Status__c = Invoicing_Constants.PENDING,
                            TR1__Conversion_Date__c = System.Today() +14,  TR1__Salary__c   = 500 ,TR1__Fee_Percentage__c = 10,Invoicing_Period__c = 'Weekly',
                            TR1__Discount_Amount__c = 200 , RecordTypeId = consulting.id, TR1__Invoice_Date__c = System.today());
           
       insert consultingClosingReport;
       return consultingClosingReport;
     }
  }
  
  // Create TimeSheet
  public static List<TR1__Timesheet__c> timesheetList {
     get {
       if(timesheetList == null){
         timesheetList = new List<TR1__Timesheet__c> {
            new TR1__Timesheet__c(TR1__Closing_Report__c = consultingClosingReport.Id, TR1__Week_Ending__c = System.today(), TR1__Job_Order__c = job.Id,
                          TR1__Client__c = accList[0].id ,TR1__Status__c = 'Open', Invoice_Status__c = Invoicing_Constants.PENDING  ),
            new TR1__Timesheet__c(TR1__Closing_Report__c = consultingClosingReport.Id, TR1__Week_Ending__c = System.today(), TR1__Job_Order__c = job.Id,
                          TR1__Client__c = accList[0].id ,TR1__Status__c = 'Open', Invoice_Status__c = Invoicing_Constants.PENDING)
         };   
         insert timesheetList;
       }
       return timesheetList;
     }
  }
   
  //Create Other Utility
  public Static List<TR1__Other_Utility__c> utilityList {
     get {
       if(utilityList == null){
         utilityList = new List<TR1__Other_Utility__c> {
           new TR1__Other_Utility__c(Name = 'Invoice_Number', TR1__Value__c = '1'),
           new TR1__Other_Utility__c(Name = 'Education_BankDetails', TR1__Value__c = 'Lloyds TSB PLC'),
           new TR1__Other_Utility__c(Name = 'Education_AccountNo', TR1__Value__c = '00038437'),
           new TR1__Other_Utility__c(Name = 'Education_SortCode', TR1__Value__c = '30-95-89'),
           new TR1__Other_Utility__c(Name = 'Construction_BankDetails', TR1__Value__c = 'Lloyds TSB PLC'),
           new TR1__Other_Utility__c(Name = 'Construction_AccountNo', TR1__Value__c = '00038437'),
           new TR1__Other_Utility__c(Name = 'Construction_SortCode', TR1__Value__c = '30-95-89'),
           new TR1__Other_Utility__c(Name = 'VatRegNoForEngage', TR1__Value__c = '12345')
         };
         insert utilityList;
       }
       return utilityList;
     }
  }
  */ 
}