public with sharing class ProjectScheduler_AC { 
    public buildertek__Project_Scheduler__c projectSch{ get; set; }
    public list<Project_Scheduler_Resource_Junction__c> psrjunction{get;set;}
    public buildertek__Schedule__c schedule { get; set; }
   
    public string poId { get; set; }
    public string projectId { get; set; }
    public Integer Numberofresoures{ get; set; } 
    public Integer  Numberofpiecesofequipment{ get; set; }
    public String CustomsettingObject{ get; set; }
    public Date  StartDate{ get; set; }
    public Date EndDate{ get; set; } 
    public boolean ProjectWorkingDays {get;set;}
    public Boolean isError {get;set;} 
    public Boolean isError1 {get;set;}
    public Boolean isError2 {get;set;}
    public Boolean isError3 {get;set;}
    public Boolean isError4 {get;set;}
    public boolean Firstpage{ get; set; }
    public boolean Nextpage{ get; set; }
    public list<projectInnerClass>projectInnList{ get; set; }
    public list<projectInnerClass>projectInnList2{ get; set; }
    
    public List<string> selectedWorkingDays{get;set;}
    
    public  ProjectScheduler_Ac() {
         poId =ApexPages.currentPage().getParameters().get('id').escapeHtml4();
         projectId =ApexPages.currentPage().getParameters().get('pid').escapeHtml4();
         selectedWorkingDays =new List<String>{'Monday', 'Tuesday', 'Wednesday' , 'Thursday' , 'Friday'};
         Firstpage=true; 
         projectSch = new buildertek__Project_Scheduler__c(); 
         projectInnList=new list<projectInnerClass>();
         psrjunction = new list<Project_Scheduler_Resource_Junction__c>();
         projectSch.Project__c = projectId;
         projectSch.buildertek__Purchase_Order__c= poId;

    }
    public List<selectoption> getworkingDays()
    {           
        list<selectoption> options = new list<selectoption>();
        options.add(new SelectOption('Monday','Monday'));
        options.add(new SelectOption('Tuesday','Tuesday'));
        options.add(new SelectOption('Wednesday','Wednesday'));
        options.add(new SelectOption('Thursday','Thursday'));
        options.add(new SelectOption('Friday','Friday'));
        options.add(new SelectOption('Saturday','Saturday'));
        options.add(new SelectOption('Sunday','Sunday'));
        return options; 
        
    }
    
    
     public void chcekError(){
     if(projectSch.buildertek__Number_of_resoures__c == Null ||   projectSch.buildertek__Number_of_Project_Tasks__c ==null   || projectSch.buildertek__Project_Start_Date__c ==null  || projectSch.buildertek__Project_Duration_in_Days__c ==null || projectSch.buildertek__Project__c ==null) {
         
         if(projectSch.buildertek__Number_of_resoures__c == null || projectSch.buildertek__Number_of_resoures__c == 0){
           //  system.debug('@@@@@@@'+Numberofresoures);
            isError = true;
            if(projectSch.buildertek__Number_of_Project_Tasks__c !=null ){
                isError1 = false;
            }
             if(projectSch.buildertek__Project_Start_Date__c !=null){
                isError2 = false;
            }
            if(projectSch.buildertek__Project_Duration_in_Days__c !=null){
                isError3 = false;
            }
             if(projectSch.buildertek__Project__c != null){
                 isError4 = false;
                     }
                
            
         }
         
        if(projectSch.buildertek__Number_of_Project_Tasks__c == null  || projectSch.buildertek__Number_of_Project_Tasks__c == 0 ){
                isError1 = true;
             if(projectSch.buildertek__Number_of_resoures__c !=null){
            isError = false;
             }
            if(projectSch.buildertek__Project_Start_Date__c !=null){
                isError2 = false;
            }
            if(projectSch.buildertek__Project_Duration_in_Days__c !=null){
                isError3 = false;
            }
             if(projectSch.buildertek__Project__c != null){
                 isError4 = false;
                     }
         }
         
         
         if(projectSch.buildertek__Project_Start_Date__c == null ){
                isError2 = true;
            if(projectSch.buildertek__Number_of_Project_Tasks__c !=null ){  
                isError1 = false;
            }
             if(projectSch.buildertek__Number_of_resoures__c !=null){
            isError = false;
             }
            
            
            if(projectSch.buildertek__Project_Duration_in_Days__c !=null){
                isError3 = false;
            }
             if(projectSch.buildertek__Project__c != null){
                 isError4 = false;
                     }
         }
         
         
            if(projectSch.buildertek__Project_Duration_in_Days__c == null){
                isError3 = true;
            
                  if(projectSch.buildertek__Project_Start_Date__c !=null){
                        isError2 = false;
                  }
                    if(projectSch.buildertek__Number_of_Project_Tasks__c !=null ){
                        isError1 = false;
                    }
                     if(projectSch.buildertek__Number_of_resoures__c !=null){
                    isError = false;
                     }
                     if(projectSch.buildertek__Project__c != null){
                 isError4 = false;
                     }
         }
         
         if(projectSch.buildertek__Project__c == null  ){
            isError4 = true;
             if(projectSch.buildertek__Number_of_resoures__c !=null ){
                isError1 = false;
            }
            if(projectSch.buildertek__Number_of_Project_Tasks__c !=null ){
                isError1 = false;
            }
             if(projectSch.buildertek__Project_Start_Date__c !=null){
                isError2 = false;
            }
            if(projectSch.buildertek__Project_Duration_in_Days__c !=null){
                isError3 = false;
            }
                
            
         }
         
        } else{
         projectNextmethod();
     
     }
     }
public Integer noOfDays{get;set;}
public void projectNextmethod(){
    projectInnList=new list<projectInnerClass>();
     // if((Numberofresoures != Null ||   Numberofpiecesofequipment !=null )  && StartDate !=null  && EndDate !=null )  {
         Firstpage=false;
         Nextpage = true;
   // System.debug('---------projectSch.Project_Duration_Days__c'+projectSch.Project_Duration_Days__c);
      integer projectDays = integer.valueOf(projectSch.buildertek__Project_Duration_in_Days__c)-1; 
      
      projectSch.buildertek__Project_End_Date__c = projectSch.buildertek__Project_Start_Date__c.addDays(projectDays);
      noOfDays = projectSch.buildertek__Project_Start_Date__c.daysBetween(projectSch.buildertek__Project_End_Date__c)+1;
      system.debug('-------'+projectSch.buildertek__Project_End_Date__c);
      system.debug('-------'+noOfDays);
      integer i;
      integer j;
      integer k;
      
      Integer l=0;
      
      //for( i=1;i<=noOfDays;i++){
          list<buildertek__Project__c>  conlist=new  list<buildertek__Project__c> ();
      list<buildertek__Project_Scheduler_Task_Junction__c> Equlist = new list<buildertek__Project_Scheduler_Task_Junction__c>();
      List<Contact> contactList = new List<Contact>();
      List<buildertek__Project_Task__c> projectTaskList = new List<buildertek__Project_Task__c>();
          for(j=1;j<=projectSch.buildertek__Number_of_resoures__c;j++){
              buildertek__Project__c pro = new buildertek__Project__c();
              conlist.add(pro);
              /*buildertek__Project_Scheduler_Resource_Junction__c psr= new buildertek__Project_Scheduler_Resource_Junction__c();
              psrjunction.add(psr);*/
              Contact con = new Contact();
              contactList.add(con);
          }
          for(k=1;k<=projectSch.buildertek__Number_of_Project_Tasks__c;k++){
              /*buildertek__Project_Scheduler_Task_Junction__c equ =new buildertek__Project_Scheduler_Task_Junction__c();
              Equlist.add(equ);
              
              */
              buildertek__Project_Task__c projectTask = new buildertek__Project_Task__c();
              projectTaskList.add(projectTask);
          }
           projectInnList.add(new projectInnerClass(projectTaskList,conlist,i,projectSch.buildertek__Project_Start_Date__c.adddays(l)));
           l++;
      //}
     // }  

}


public PageReference Save(){
     
      if(Test.isRunningTest()){
          if (Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__purchase_order__c.isCreateable() && Schema.sObjectType.buildertek__Project_Scheduler__c.fields.project__c.isCreateable() &&
              Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__purchase_order__c.isUpdateable() && Schema.sObjectType.buildertek__Project_Scheduler__c.fields.project__c.isUpdateable()) {
            upsert projectSch;
          }
      }
      else{
          if (Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__purchase_order__c.isCreateable() && Schema.sObjectType.buildertek__Project_Scheduler__c.fields.project__c.isCreateable()) {
            insert projectSch;
          }
      }
    
      
    List<Contact> contactList = new List<Contact>();
    List<buildertek__Project_Task__c> equipmentList = new List<buildertek__Project_Task__c>();
    list<id> conids = new List<id>();
    list<id> equids = new List<id>(); 
    
    map<String, String> ContactTaskMap = new map<String, String>();
    
    for(projectInnerClass p : projectInnList){
        /*for(Contact  pj : p.psrjunction){
            conids.add(pj.Id);
            //resourceJunction.put(pj.Contact__c,pj);
        }*/
        for(buildertek__Project_Task__c c : p.EquRecord ){
            equids.add(c.buildertek__Dependency__c);
            conids.add(c.buildertek__Contractor_Resource__c);
            ContactTaskMap.put(c.buildertek__Dependency__c, c.buildertek__Contractor_Resource__c);
        }
    }
    List<buildertek__Project_Scheduler_Resource_Junction__c> psrList = new List<buildertek__Project_Scheduler_Resource_Junction__c>();
    List<buildertek__Project_Scheduler_Task_Junction__c> pseList = new List<buildertek__Project_Scheduler_Task_Junction__c>();
    List<buildertek__Project_Scheduler_Resource_Junction__c> dummypsrList = new List<buildertek__Project_Scheduler_Resource_Junction__c>();
    List<buildertek__Project_Scheduler_Task_Junction__c> dummypseList = new List<buildertek__Project_Scheduler_Task_Junction__c>();
    
    integer i;
   
    
    /*for(id conid : conids){ 
        dummypsrList = new List<buildertek__Project_Scheduler_Resource_Junction__c>();
    
        system.debug('-------conid'+conid); 
        system.debug('-------selectedWorkingDays'+selectedWorkingDays); 
        for(i=0; i<= 1000 ; i++){ 
            for(string s:selectedWorkingDays){ 
                system.debug('-------245'+i);
                Datetime  Dt = projectSch.buildertek__Project_Start_Date__c+i;
                Dt = Dt.addHours(12); 
                String dayOfWeek=Dt.format('EEEE');
                system.debug('-------248'+dayOfWeek);
                if(s == dayOfWeek){
                    system.debug('-------250'+dayOfWeek);
                    Contact psr = new buildertek__Project_Scheduler_Resource_Junction__c();
                    psr.Project_Scheduler__c = projectSch.id;
                    psr.Contact__c = conid;
                    psr.Date__c = projectSch.buildertek__Project_Start_Date__c+i;
                    //psr.Role__c = resourceJunction.get(conid).Role__c;
                    psrList.add(psr); 
                    dummypsrList.add(psr); 
                } 
                
            }
            if(dummypsrList.size() == noOfDays)
                break; 
        } 
    }*/
    system.debug('equids -----------> '+equids);
    
    /*for(id eid : equids){
      dummypseList = new List<buildertek__Project_Scheduler_Task_Junction__c>();
        for(i=0; i<= 1000 ; i++){ 
            for(string s:selectedWorkingDays){ 
                Datetime  Dt = projectSch.buildertek__Project_Start_Date__c+i;
                Dt = Dt.addHours(12); 
                String dayOfWeek=Dt.format('EEEE');
                if(s == dayOfWeek){    
                    system.debug('-------'+dayOfWeek);
                    buildertek__Project_Scheduler_Task_Junction__c pse = new buildertek__Project_Scheduler_Task_Junction__c();
                    pse.buildertek__Project_Scheduler__c = projectSch.id;
                    pse.buildertek__Project_Task__c = eid;
                    pse.Date__c = projectSch.buildertek__Project_Start_Date__c+i;
                    pseList.add(pse);
                    dummypseList.add(pse);
                } 
            }
            if(dummypseList.size() == noOfDays)
                break;
        }
    } 
    
     insert pseList;      
     insert psrList;*/ 
     
    /*List<Id> ids = new List<Id>();
    for(buildertek__Project_Scheduler_Resource_Junction__c psr : psrList){
        ids.add(psr.Contact__c);
        
    }
    
    List<Id> taskIds = new List<Id>(); 
    for(buildertek__Project_Scheduler_Task_Junction__c pst : pseList){
        taskIds.add(pst.buildertek__Project_Task__c);        
    }*/
    List<buildertek__Project_Task__c> taskList;
    if(Schema.sObjectType.buildertek__Project_Task__c.fields.Id.isAccessible() &&
        Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isAccessible()&&
        Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Resource__c.isAccessible() &&
        Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Dependency__c.isAccessible()){
         taskList = [select Id, Name, buildertek__Resource__c, buildertek__Dependency__c from buildertek__Project_Task__c where Id IN: equids];
            }
    system.debug('taskList -------> '+taskList.size());
    system.debug('taskList -------> '+taskList);
     buildertek__Purchase_Order__c PO ;
    if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isAccessible() ){
             PO = [select Id, buildertek__Description__c from buildertek__Purchase_Order__c where Id =: poId];
			}
     if(Schema.sObjectType.buildertek__Schedule__c.fields.Project__c.isCreateable() && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Description__c.isCreateable()){
            schedule = new buildertek__Schedule__c();
            schedule.Project__c = projectSch.Project__c;
            schedule.buildertek__Description__c = PO.buildertek__Description__c;
     }
    insert schedule;
    
    system.debug('ids -------> '+conids);
    List<Contact> contList;
    if(Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible()){
     contList= [select Id, Name from Contact where Id IN: conids];
    }
    system.debug('contList ----------> '+contList.size());
    
    system.debug('TaskConMap ------------> '+ContactTaskMap);
    List<buildertek__Project_Task__c> projectTaskList = new List<buildertek__Project_Task__c>();
    for(buildertek__Project_Task__c tasks : taskList){
        if(Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Schedule__c.isCreateable()
           && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Start__c.isCreateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Finish__c.isCreateable()
           && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Resource__c.isCreateable()){
            buildertek__Project_Task__c projectTask = new buildertek__Project_Task__c();
            projectTask.Name = tasks.Name;
            projectTask.buildertek__Schedule__c = schedule.Id;
            projectTask.buildertek__Start__c = projectSch.Project_Start_Date__c;
            projectTask.buildertek__Finish__c = projectSch.Project_End_Date__c;
            projectTask.buildertek__Resource__c = ContactTaskMap.get(tasks.Id);
            projectTaskList.add(projectTask);
        }  
    }
    insert projectTaskList;

    pageReference p = new pageReference('/apex/CustomCalendar_VF');
    p.setRedirect(true);
    return p;
}

 public void back(){
       
       Firstpage = true;
       Nextpage = false;
        
    }
 
public class projectInnerClass{
    
        public list<buildertek__Project_Task__c> EquRecord{get;set;}
        public list<Project__c> ConRecord{get;set;}
        public integer count{get;set;}
        public Date dt{get;set;}
        public list<Contact> psrjunction{get;set;}
        public projectInnerClass(list<buildertek__Project_Task__c> EquRecord,list<Project__c>  ConRecord,integer count,Date dt){
            this.EquRecord = EquRecord;
            this.ConRecord = ConRecord;
            this.count = count;
            this.dt=dt;
            this.psrjunction = psrjunction;
            
        }
    }
    
    
}